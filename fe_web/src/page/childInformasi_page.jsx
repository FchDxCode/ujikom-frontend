import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { contentBlockAPI } from '../service/contentblock_api';
import ContentGridDetail from '../components/contentGridDetail';
import StatusHandler from '../components/statusHandler';
import AOS from "aos";
import "aos/dist/aos.css";

const ChildInformasiPage = () => {
  const { slug } = useParams();
  const [informasiData, setInformasiData] = useState(null);
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
    const fetchInformasiDetail = async () => {
      try {
        setLoading(true);
        const informasiId = localStorage.getItem('informasi_id');
        
        if (!informasiId) {
          throw new Error('ID informasi tidak ditemukan');
        }

        const response = await contentBlockAPI.getContentBlockById(informasiId);
        
        if (response.status === 'success' && response.data) {
          setInformasiData(response.data);
        } else {
          throw new Error('Data informasi tidak ditemukan');
        }
      } catch (error) {
        console.error('Error fetching informasi detail:', error);
        setError(error.message || 'Terjadi kesalahan saat memuat data');
      } finally {
        setLoading(false);
      }
    };

    fetchInformasiDetail();
  }, [slug]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <StatusHandler status="loading" message="Memuat detail informasi..." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <StatusHandler status="error" message={error} />
      </div>
    );
  }

  if (!informasiData) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <StatusHandler status="error" message="Data tidak ditemukan" />
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <h1 className="text-[4rem] md:text-[5rem] leading-[4rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[6rem] md:mb-[3rem] mb-[2rem]" data-aos="fade-down">
        Detail Informasi.
      </h1>
      <ContentGridDetail
        title={informasiData.title}
        image={informasiData.image}
        description={informasiData.description}
        date={new Date(informasiData.updated_at).toLocaleDateString('id-ID', {
          day: 'numeric',
          month: 'long',
          year: 'numeric'
        })}
      />
    </div>
  );
};

export default ChildInformasiPage;
