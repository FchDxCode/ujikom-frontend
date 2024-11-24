import React, { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { pageAPI } from "../service/page_api";
import { contentBlockAPI } from "../service/contentblock_api";
import AgendaCard from "./cardOnly_agenda";
import { Swiper, SwiperSlide } from "swiper/react";
import { Scrollbar, Autoplay, Navigation } from "swiper/modules";
import { FaChevronLeft, FaChevronRight } from "react-icons/fa";
import StatusHandler from "./statusHandler";
import { debounce } from "lodash";

import "swiper/css";
import "swiper/css/scrollbar";
import "swiper/css/navigation";

const AgendaBeranda = () => {
  const [agendaData, setAgendaData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const swiperRef = useRef(null);
  const titleRef = useRef(null);
  const [isTitleVisible, setIsTitleVisible] = useState(false);

  const navigate = useNavigate();

  // Tambahkan fungsi handleAgendaClick
  const handleAgendaClick = (agenda) => {
    const slug = agenda.title
      .toLowerCase()
      .replace(/ /g, "-")
      .replace(/[^\w-]+/g, "");

    localStorage.setItem("agenda_id", agenda.id);
    navigate(`/agenda/${slug}`);
  };

  // Fetch Data on Mount
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [pageResponse, contentResponse] = await Promise.all([
          pageAPI.getPageBySlug("agenda"),
          contentBlockAPI.getContentBlocksByPageSlug("agenda"),
        ]);

        if (
          pageResponse.status === "success" &&
          contentResponse.status === "success"
        ) {
          const currentDate = new Date();
          const filteredAgenda = contentResponse.data
            .filter((agenda) => {
              if (!agenda.updated_at) return false;

              const createdDate = new Date(agenda.updated_at);
              const diffDays = Math.floor(
                (currentDate - createdDate) / (1000 * 60 * 60 * 24)
              );

              return diffDays >= -365 && diffDays <= 20;
            })
            .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));

          setAgendaData(filteredAgenda);
        } else {
          throw new Error("Gagal memuat data agenda");
        }
      } catch (error) {
        console.error("Error fetching data:", error);
        setError(error.message || "Terjadi kesalahan saat memuat data");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // Handle Autoplay Pause When Tab is Not Active
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.hidden) {
        swiperRef.current?.swiper?.autoplay?.stop();
      } else {
        swiperRef.current?.swiper?.autoplay?.start();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () =>
      document.removeEventListener("visibilitychange", handleVisibilityChange);
  }, []);

  // Add this new useEffect for title animation
  useEffect(() => {
    const observer = new IntersectionObserver(
      debounce((entries) => {
        entries.forEach((entry) => setIsTitleVisible(entry.isIntersecting));
      }, 200),
      { rootMargin: "0px", threshold: 0.5 }
    );

    const titleElement = titleRef.current;
    if (titleElement) observer.observe(titleElement);

    return () => observer.disconnect();
  }, []);

  return (
    <div className="min-h-screen w-full bg-transparent flex flex-col items-center justify-center">
      <div className="container mx-auto p-6">
        <h1
          ref={titleRef}
          className={`md:text-[3rem] text-[2rem] font-satoshiBlack text-stoneground/80 text-center mb-[5rem] transition-opacity duration-[1000ms] ease-in-out ${
            isTitleVisible
              ? "translate-x-0 opacity-100"
              : "-translate-x-[50%] opacity-0"
          }`}
        >
          Agenda Instansi.
        </h1>

        <div className="max-w-screen-lg mx-auto">
          {/* Loading State */}
          {loading && (
            <div className="my-8">
              <StatusHandler
                status="loading"
                message="Memuat data agenda, mohon tunggu sebentar..."
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
          {!loading && !error && agendaData.length === 0 && (
            <div className="my-8">
              <StatusHandler
                status="error"
                message="Tidak ada agenda terbaru yang tersedia saat ini."
              />
            </div>
          )}

          {/* Success State with Agenda Slider */}
          {!loading && !error && agendaData.length > 0 && (
            <div className="relative">
              {/* Desktop Navigation - Left */}
              <button
                className="absolute left-0 top-1/2 -translate-x-20 -translate-y-1/2 px-3.5 py-4 bg-shadow/30 backdrop-blur-md rounded-xl z-10 hover:bg-shadow/50 transition hidden md:flex group"
                onClick={() => swiperRef.current?.swiper?.slidePrev()}
                aria-label="Previous Slide"
              >
                <FaChevronLeft
                  className="text-stoneground group-hover:scale-110 transition-transform"
                  size={24}
                />
              </button>

              {/* Swiper Component */}
              <Swiper
                spaceBetween={65}
                ref={swiperRef}
                modules={[Scrollbar, Autoplay, Navigation]}
                slidesPerView={1}
                loop={true}
                breakpoints={{
                  640: { slidesPerView: 2 },
                }}
                draggable={true}
                autoplay={{
                  delay: 5000,
                  disableOnInteraction: true,
                  pauseOnMouseEnter: true,
                }}
                navigation={{
                  nextEl: ".swiper-button-next-custom",
                  prevEl: ".swiper-button-prev-custom",
                }}
                className="px-4 py-8"
              >
                {agendaData.map((agenda, index) => (
                  <SwiperSlide
                    key={agenda.id || index}
                    onClick={() => handleAgendaClick(agenda)}
                    style={{ cursor: "pointer" }}
                  >
                    <AgendaCard
                      image={agenda.image || "Gambar tidak tersedia"}
                      title={agenda.title || "Judul Tidak Tersedia"}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleAgendaClick(agenda);
                      }}
                    />
                  </SwiperSlide>
                ))}
              </Swiper>

              {/* Desktop Navigation - Right */}
              <button
                className="absolute right-0 top-1/2 translate-x-20 -translate-y-1/2 px-3.5 py-4 bg-shadow/30 backdrop-blur-md rounded-xl z-10 hover:bg-shadow/50 transition hidden md:flex group"
                onClick={() => swiperRef.current?.swiper?.slideNext()}
                aria-label="Next Slide"
              >
                <FaChevronRight
                  className="text-stoneground group-hover:scale-110 transition-transform"
                  size={24}
                />
              </button>

              {/* Mobile Navigation */}
              <div className="flex justify-center space-x-4 mt-6 md:hidden">
                <button
                  className="px-4 py-2 bg-shadow/30 backdrop-blur-md rounded-full hover:bg-shadow/50 transition group"
                  onClick={() => swiperRef.current?.swiper?.slidePrev()}
                  aria-label="Previous Slide"
                >
                  <FaChevronLeft
                    className="text-stoneground group-hover:scale-110 transition-transform"
                    size={24}
                  />
                </button>
                <button
                  className="px-4 py-2 bg-shadow/30 backdrop-blur-md rounded-full hover:bg-shadow/50 transition group"
                  onClick={() => swiperRef.current?.swiper?.slideNext()}
                  aria-label="Next Slide"
                >
                  <FaChevronRight
                    className="text-stoneground group-hover:scale-110 transition-transform"
                    size={24}
                  />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AgendaBeranda;
