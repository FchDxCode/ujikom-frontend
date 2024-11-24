import React, { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { pageAPI } from '../service/page_api';
import { contentBlockAPI } from '../service/contentblock_api';
import CardContainer from '../components/container_card';
import StatusHandler from '../components/statusHandler';

const InformasiPage = () => {
  const navigate = useNavigate();
  const [informasiData, setInformasiData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const h1Ref = useRef(null);
  const [inViewport, setInViewport] = useState(false);

  useEffect(() => {
    fetchData();

    const observerOptions = {
      root: null,
      rootMargin: '0px',
      threshold: 0.5,
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.target === h1Ref.current) {
          setInViewport(entry.isIntersecting);
        }
      });
    }, observerOptions);

    const h1Element = h1Ref.current;
    if (h1Element) observer.observe(h1Element);

    return () => {
      if (h1Element) observer.unobserve(h1Element);
    };
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      const pageResponse = await pageAPI.getPageBySlug("informasi");
      if (pageResponse.status === "success") {
        const contentResponse = await contentBlockAPI.getContentBlocksByPageSlug("informasi");
        if (contentResponse.status === "success") {
          const formattedData = contentResponse.data.map(item => ({
            id: item.id,
            title: item.title,
            description: item.description,
            image: item.image,
            created_by: item.created_by,
            updated_at: item.updated_at
          }));
          setInformasiData(formattedData);
        } else {
          throw new Error("Gagal memuat konten informasi");
        }
      } else {
        throw new Error("Gagal memuat data halaman");
      }
    } catch (error) {
      console.error("Error fetching data:", error);
      setError(error.message || "Gagal memuat data. Silakan coba lagi nanti.");
    } finally {
      setLoading(false);
    }
  };

  const handleCardClick = (data) => {
    const slug = data.title
      .toLowerCase()
      .replace(/ /g, '-')
      .replace(/[^\w-]+/g, '');
    
    localStorage.setItem('informasi_id', data.id);
    navigate(`/informasi/${slug}`); // Ubah path agar konsisten
  };

  const dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" }
  ];

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
        <h1
          ref={h1Ref}
          className={`text-[4rem] md:text-[5rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[4rem] md:mb-[3rem] mb-[2rem] transition-all duration-[1300ms] ease-in-out ${
            inViewport ? 'translate-y-0 opacity-100' : 'translate-y-[50%] opacity-0'
          }`}
        >
          Informasi.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat data informasi, mohon tunggu sebentar..."
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
        {!loading && !error && informasiData.length === 0 && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Tidak ada informasi yang tersedia saat ini."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && informasiData.length > 0 && (
          <div className="animate-fadeIn">
            <CardContainer 
              data={informasiData} 
              emptyMessage="Tidak ada data informasi yang tersedia saat ini."
              dropdownOptions={dropdownOptions}
              showProfile={true}
              onCardClick={handleCardClick}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default InformasiPage;
