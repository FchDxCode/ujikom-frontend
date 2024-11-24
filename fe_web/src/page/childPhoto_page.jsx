import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { photoAPI } from '../service/photo_api';
import ContentGridDetail from '../components/contentGridDetail';
import StatusHandler from '../components/statusHandler';
import AOS from "aos";
import "aos/dist/aos.css";

const ChildPhotoPage = () => {
  const { photoSlug } = useParams();
  const [photo, setPhoto] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    AOS.init({
      duration: 800,
      easing: "ease-in-out",
      delay: 100,
      mirror: true, // Animasi berjalan kembali saat di-scroll ke atas
      once: false, // Animasi diputar ulang setiap kali elemen muncul di viewport
    });
    AOS.refresh(); // Memastikan semua elemen diperbarui
  }, []);

  useEffect(() => {
    const fetchPhotoDetail = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const photoId = localStorage.getItem('photo_id');
        if (!photoId) {
          throw new Error("ID foto tidak ditemukan");
        }

        const response = await photoAPI.getPhotoDetail(photoId);

        if (response.status === "success") {
          setPhoto({
            title: response.data.title,
            photo: response.data.photo,
            description: response.data.description,
            uploaded_at: response.data.uploaded_at,
            uploaded_by: response.data.uploaded_by,
            likes: response.data.likes
          });
        } else {
          throw new Error("Gagal memuat detail foto");
        }
      } catch (error) {
        console.error("Error fetching photo detail:", error);
        setError(error.message || "Gagal memuat detail foto. Silakan coba lagi nanti.");
      } finally {
        setLoading(false);
      }
    };

    fetchPhotoDetail();
  }, [photoSlug]);

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
      <h1 className="text-[4rem] md:text-[5rem] leading-[4rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[6rem] md:mb-[3rem] mb-[2rem]" data-aos="fade-down">
          Detail Foto.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat detail foto, mohon tunggu sebentar..."
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
        {!loading && !error && !photo && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Data foto tidak ditemukan."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && photo && (
          <div className="animate-fadeIn">
            <ContentGridDetail
              title={photo.title}
              image={photo.photo}
              description={photo.description}
              date={photo.uploaded_at ? new Date(photo.uploaded_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric'
              }) : ''}
              author={photo.uploaded_by}
              likes={photo.likes}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default ChildPhotoPage;
