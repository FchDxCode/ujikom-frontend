import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { albumAPI } from '../service/album_api';
import CardContainer from '../components/container_card';
import StatusHandler from '../components/statusHandler';

const AlbumPage = () => {
  const { categorySlug } = useParams();
  const navigate = useNavigate();
  const [albums, setAlbums] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchAlbums = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await albumAPI.getAlbumsByCategory(categorySlug);
        
        console.log('API Response:', response);
        
        if (response.status === "success") {
          const formattedAlbums = response.data
            .filter(album => album.is_active === true)
            .map(album => {
              console.log('Processing album:', album);
              return {
                id: album.id,
                title: album.title || '',
                description: album.description || '',
                image: album.cover_photo_url || '',
                created_by: album.created_by || '',
                updated_at: album.created_at || new Date().toISOString(),
                slug: album.title.toLowerCase().replace(/ /g, '-').replace(/[^\w-]+/g, ''),
                is_active: album.is_active
              };
            });
          setAlbums(formattedAlbums);
        } else {
          throw new Error("Gagal memuat data album");
        }
      } catch (error) {
        console.error("Error fetching albums:", error);
        setError(error.message || "Gagal memuat album. Silakan coba lagi nanti.");
      } finally {
        setLoading(false);
      }
    };

    fetchAlbums();
  }, [categorySlug]);

  const handleAlbumClick = (album) => {
    localStorage.setItem('album_id', album.id);
    navigate(`/galeri/${categorySlug}/${album.slug}`);
  };

  const dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" }
  ];

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
        <h1 className="text-[4rem] md:text-[5rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[4rem] md:mb-[3rem] mb-[2rem]">
          Album.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat data album, mohon tunggu sebentar..."
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
        {!loading && !error && albums.length === 0 && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Tidak ada album yang tersedia dalam kategori ini."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && albums.length > 0 && (
          <div className="animate-fadeIn">
            <CardContainer 
              data={albums}
              emptyMessage="Tidak ada album yang tersedia dalam kategori ini."
              dropdownOptions={dropdownOptions}
              showProfile={true}
              onCardClick={handleAlbumClick}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default AlbumPage;
