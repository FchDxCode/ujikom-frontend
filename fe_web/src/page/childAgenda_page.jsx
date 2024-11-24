import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { contentBlockAPI } from '../service/contentblock_api';
import ContentGridDetail from '../components/contentGridDetail';
import StatusHandler from '../components/statusHandler';
import AOS from "aos";
import "aos/dist/aos.css";

const ChildAgendaPage = () => {
  const { slug } = useParams();
  const [agenda, setAgenda] = useState(null);
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
    const fetchAgendaDetail = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const agendaId = localStorage.getItem('agenda_id');
        if (!agendaId) {
          throw new Error("ID agenda tidak ditemukan");
        }

        const response = await contentBlockAPI.getContentBlockDetail(agendaId);

        if (response.status === "success") {
          setAgenda({
            title: response.data.title,
            image: response.data.image,
            description: response.data.description,
            created_at: response.data.created_at || response.data.updated_at,
            created_by: response.data.created_by
          });
        } else {
          throw new Error(response.message || "Gagal memuat detail agenda");
        }
      } catch (error) {
        console.error("Error fetching agenda detail:", error);
        setError(error.message || "Gagal memuat detail agenda. Silakan coba lagi nanti.");
      } finally {
        setLoading(false);
      }
    };

    fetchAgendaDetail();
  }, [slug]);

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
      <h1 className="text-[4rem] md:text-[5rem] leading-[4rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[6rem] md:mb-[3rem] mb-[2rem]" data-aos="fade-down" >
          Detail Agenda.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat detail agenda, mohon tunggu sebentar..."
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
        {!loading && !error && !agenda && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Data agenda tidak ditemukan."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && agenda && (
          <div className="animate-fadeIn">
            <ContentGridDetail
              title={agenda.title}
              image={agenda.image}
              description={agenda.description}
              date={agenda.created_at ? new Date(agenda.created_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric'
              }) : ''}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default ChildAgendaPage;
