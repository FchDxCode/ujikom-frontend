import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { photoAPI } from '../service/photo_api';
import CardContainer from '../components/container_card';
import CardWithLike from '../components/cardWithLike';
import StatusHandler from '../components/statusHandler';

const PhotoPage = () => {
  const { categorySlug, albumSlug } = useParams();
  const [photos, setPhotos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" },
    { label: "Terpopuler", value: "terpopuler" }
  ];

  useEffect(() => {
    const fetchPhotos = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const albumId = localStorage.getItem('album_id');
        if (!albumId) {
          throw new Error("ID album tidak ditemukan");
        }

        const response = await photoAPI.getPhotosByAlbum(albumId);
        
        if (response.status === "success") {
          const formattedPhotos = response.data.map(photo => {
            const isLiked = document.cookie.includes(`photo_like_${photo.id}=true`);
            
            return {
              id: photo.id,
              title: photo.title || '',
              description: photo.description || '',
              image: photo.photo || '',
              created_by: photo.uploaded_by || '',
              updated_at: photo.uploaded_at || new Date().toISOString(),
              likes: photo.likes || 0,
              isLiked: isLiked,
              popularity: photo.likes || 0
            };
          });
          setPhotos(formattedPhotos);
        } else {
          throw new Error("Gagal memuat foto");
        }
      } catch (error) {
        console.error("Error fetching photos:", error);
        setError(error.message || "Gagal memuat foto. Silakan coba lagi nanti.");
      } finally {
        setLoading(false);
      }
    };

    fetchPhotos();
  }, [albumSlug]);

  const handleLikeClick = async (photo) => {
    try {
      const action = photo.isLiked ? 'unlike' : 'like';
      const response = await photoAPI.likePhoto(photo.id, action);
      
      if (response.status === "success") {
        const likedPhotos = JSON.parse(localStorage.getItem('likedPhotos') || '{}');
        if (action === 'like') {
          likedPhotos[photo.id] = true;
        } else {
          delete likedPhotos[photo.id];
        }
        localStorage.setItem('likedPhotos', JSON.stringify(likedPhotos));
  
        setPhotos(prevPhotos => 
          prevPhotos.map(p => 
            p.id === photo.id 
              ? { 
                  ...p, 
                  likes: response.data.likes,
                  isLiked: action === 'like'
                }
              : p
          )
        );
      }
    } catch (error) {
      console.error("Error toggling like:", error);
    }
  };
  
  const handleCardClick = (photo) => {
    const slug = photo.title
      .toLowerCase()
      .replace(/ /g, '-')
      .replace(/[^\w-]+/g, '');
    
    localStorage.setItem('photo_id', photo.id);
    navigate(`/galeri/${categorySlug}/${albumSlug}/${slug}`);
  };

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
        <h1 className="text-[4rem] md:text-[5rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[4rem] md:mb-[3rem] mb-[2rem]">
          Foto.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat foto-foto album, mohon tunggu sebentar..."
            />
          </div>
        )}

        {/* Error State */}
        {!loading && error && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message={error}
            />
          </div>
        )}

        {/* Empty State */}
        {!loading && !error && photos.length === 0 && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Tidak ada foto yang tersedia dalam album ini."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && photos.length > 0 && (
          <div className="animate-fadeIn">
            <CardContainer 
              data={photos}
              emptyMessage="Tidak ada foto yang tersedia dalam album ini."
              dropdownOptions={dropdownOptions}
              buttonLabel="Terbaru"
              showProfile={true}
              CardComponent={CardWithLike}
              onLikeClick={handleLikeClick}
              onCardClick={handleCardClick}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default PhotoPage;
