import React, { useEffect, useState, useRef } from 'react';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Scrollbar, Autoplay } from 'swiper/modules';
import { contentBlockAPI } from '../service/contentblock_api';
import { pageAPI } from '../service/page_api';
import StatusHandler from './statusHandler';
import Card from './card_only';
import 'swiper/css';
import 'swiper/css/pagination';
import 'swiper/css/scrollbar';
import { useNavigate } from 'react-router-dom';

const InformasiDashboard = ({ divider = true, title = true }) => {
  const [cardData, setCardData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const swiperRef = useRef(null);
  const titleRef = useRef(null); // Ref untuk title
  const [isTitleVisible, setIsTitleVisible] = useState(false);
  const navigate = useNavigate();

  const handleCardClick = (data) => {
    const slug = data.title
      .toLowerCase()
      .replace(/ /g, '-')
      .replace(/[^\w-]+/g, '');
    
    localStorage.setItem('informasi_id', data.id);
    navigate(`/informasi/${slug}`); // Ubah path agar konsisten
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const pageResponse = await pageAPI.getPageBySlug('informasi');
        if (pageResponse.status === 'success') {
          const contentResponse = await contentBlockAPI.getContentBlocksByPageSlug('informasi');

          if (contentResponse.status === 'success') {
            // Filter informasi berdasarkan tanggal
            const currentDate = new Date();
            const filteredInformasi = contentResponse.data.filter(info => {
              if (!info.updated_at) return false;
              
              const createdDate = new Date(info.updated_at);
              const diffTime = currentDate.getTime() - createdDate.getTime();
              const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
              
              // Tampilkan informasi yang berumur 0-20 hari
              return diffDays >= -365 && diffDays <= 20;
            });

            // Urutkan berdasarkan tanggal terbaru
            const sortedInformasi = filteredInformasi.sort((a, b) => 
              new Date(b.updated_at) - new Date(a.updated_at)
            );

            setCardData(sortedInformasi);
          } else {
            throw new Error('Gagal memuat konten informasi');
          }
        } else {
          throw new Error('Halaman informasi tidak ditemukan');
        }
      } catch (error) {
        console.error('Error fetching data:', error);
        setError(error.message || 'Gagal memuat informasi');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  useEffect(() => {
    const observerOptions = {
      root: null,
      rootMargin: '0px',
      threshold: 0.5, // Animasi dipicu saat 50% elemen terlihat
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.target === titleRef.current) {
          setIsTitleVisible(entry.isIntersecting);
        }
      });
    }, observerOptions);

    const titleElement = titleRef.current;
    if (titleElement) observer.observe(titleElement);

    return () => {
      if (titleElement) observer.unobserve(titleElement);
    };
  }, []);

  return (
    <div className="w-full">
      <div className="max-w-screen-lg mx-auto py-4 px-2 rounded-lg">
        {title && (
          <h2
            ref={titleRef}
            className={`text-[2rem] md:text-[3rem] mt-5 pb-20 font-satoshiBlack text-center text-stoneground/80 transition-opacity duration-[1000ms] ease-in-out ${
              isTitleVisible
                ? 'translate-x-0 opacity-100'
                : '-translate-x-[50%] opacity-0'
            }`}
          >
            Informasi Terkini.
          </h2>
        )}

        {/* Loading State */}
        {loading && (
          <div className="my-8">
            <StatusHandler
              status="loading"
              message="Memuat informasi terkini, mohon tunggu sebentar..."
            />
          </div>
        )}

        {/* Error State */}
        {!loading && error && (
          <div className="my-8">
            <StatusHandler status="error" message={error} />
          </div>
        )}

        {/* Empty State */}
        {!loading && !error && cardData.length === 0 && (
          <div className="my-8">
            <StatusHandler
              status="error"
              message="Belum ada informasi yang tersedia saat ini."
            />
          </div>
        )}

        {/* Success State with Swiper */}
        {!loading && !error && cardData.length > 0 && (
          <Swiper
            modules={[Scrollbar, Autoplay]}
            spaceBetween={20}
            slidesPerView={1}
            loop={true}
            breakpoints={{
              640: {
                slidesPerView: 2,
              },
              1024: {
                slidesPerView: 3,
              },
            }}
            pagination={{ clickable: true }}
            scrollbar={{ draggable: true }}
            autoplay={{
              delay: 4000,
              disableOnInteraction: true,
              pauseOnMouseEnter: true,
            }}
            onSwiper={(swiper) => {
              swiperRef.current = swiper;
            }}
            className="px-4 pb-10"
            onTouchStart={() => {
              if (swiperRef.current?.autoplay?.running) {
                swiperRef.current.autoplay.stop();
              }
            }}
            onClick={() => {
              if (swiperRef.current?.autoplay?.running) {
                swiperRef.current.autoplay.stop();
              }
            }}
          >
            {cardData.map((data, index) => (
              <SwiperSlide
                key={index}
                className="flex justify-center p-2 pb-[2.5rem]"
                onClick={(e) => {
                  e.stopPropagation();
                  if (swiperRef.current) {
                    swiperRef.current.autoplay.stop();
                  }
                  handleCardClick(data);
                }}
              >
                <Card data={data} />
              </SwiperSlide>
            ))}
          </Swiper>
        )}
      </div>

      {divider && <div className="w-full h-2 bg-bark mt-8"></div>}
    </div>
  );
};

export default InformasiDashboard;
