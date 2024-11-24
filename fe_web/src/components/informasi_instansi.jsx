import React, { useEffect, useState, useRef, useCallback } from 'react';
import { pageAPI } from '../service/page_api';
import { contentBlockAPI } from '../service/contentblock_api';
import { motion, AnimatePresence } from 'framer-motion';
import ModalDetailInformasi from './modal_detailInformasi';
import StatusHandler from './statusHandler';

function InformasiInstansi() {
  const [contentBlocks, setContentBlocks] = useState([]);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [direction, setDirection] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const intervalRef = useRef(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Fetch Data
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const pageResponse = await pageAPI.getPageBySlug('informasi-instansi');
        if (pageResponse.status === 'success') {
          const contentResponse = await contentBlockAPI.getContentBlocksByPageSlug('informasi-instansi');
          if (contentResponse.status === 'success') {
            setContentBlocks(contentResponse.data);
          } else {
            throw new Error('Gagal memuat konten informasi instansi.');
          }
        } else {
          throw new Error('Gagal memuat data halaman informasi instansi.');
        }
      } catch (err) {
        console.error('Error fetching data:', err);
        setError(err.message || 'Terjadi kesalahan saat memuat informasi instansi.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Preload Images
  useEffect(() => {
    if (contentBlocks.length > 0) {
      const preloadImages = contentBlocks.map((block) => {
        return new Promise((resolve, reject) => {
          const img = new Image();
          img.src = block?.image || block?.media?.url || (block?.images && block.images[0]?.url) || '';
          img.onload = resolve;
          img.onerror = reject;
        });
      });
      Promise.all(preloadImages).catch(console.error);
    }
  }, [contentBlocks]);

  const paginate = useCallback((newDirection) => {
    setDirection(newDirection);
    setCurrentImageIndex((prevIndex) => {
      const newIndex = (prevIndex + newDirection + contentBlocks.length) % contentBlocks.length;
      return newIndex;
    });
  }, [contentBlocks.length]);

  const stopAutoPlay = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  const startAutoPlay = useCallback(() => {
    stopAutoPlay();
    intervalRef.current = setInterval(() => {
      paginate(1);
    }, 5000);
  }, [paginate, stopAutoPlay]);

  useEffect(() => {
    if (contentBlocks.length > 1 && !isModalOpen) {
      startAutoPlay();

      // Pause autoplay when the user leaves the tab and resume when they return
      const handleVisibilityChange = () => {
        if (document.hidden) {
          stopAutoPlay();
        } else {
          startAutoPlay();
        }
      };
      document.addEventListener('visibilitychange', handleVisibilityChange);

      return () => {
        stopAutoPlay();
        document.removeEventListener('visibilitychange', handleVisibilityChange);
      };
    }
  }, [contentBlocks, isModalOpen, startAutoPlay, stopAutoPlay]);

  const handlePrev = useCallback(() => {
    paginate(-1);
    startAutoPlay();
  }, [paginate, startAutoPlay]);

  const handleNext = useCallback(() => {
    paginate(1);
    startAutoPlay();
  }, [paginate, startAutoPlay]);

  const handleIndicatorClick = useCallback((index) => {
    if (index !== currentImageIndex) {
      const newDirection = index > currentImageIndex ? 1 : -1;
      setDirection(newDirection);
      setCurrentImageIndex(index);
      startAutoPlay();
    }
  }, [currentImageIndex, startAutoPlay]);

  if (loading) {
    return <div>
                <StatusHandler
                    status="loading"
                    message="Memuat informasi instansi, mohon tunggu sebentar..."
                />
            </div>;
  }

  if (error) {
    return <div className='mt-20'>
               <StatusHandler
                status="error"
                message={error}
              />
          </div>;
  }

  const currentBlock = contentBlocks[currentImageIndex];
  const currentImage = currentBlock?.image || currentBlock?.media?.url || (currentBlock?.images && currentBlock.images[0]?.url) || '';

  const swipeConfidenceThreshold = 10000;
  const swipePower = (offset, velocity) => {
    return Math.abs(offset) * velocity;
  };

  const variants = {
    enter: (direction) => ({
      x: direction > 0 ? '100%' : '-100%',
    }),
    center: {
      x: 0,
    },
    exit: (direction) => ({
      x: direction < 0 ? '100%' : '-100%',
    }),
  };

  const contentVariants = {
    initial: (direction) => ({
      x: direction > 0 ? '100%' : '-100%',
      opacity: 0,
    }),
    animate: {
      x: 0,
      opacity: 1,
      transition: { duration: 1.0 },
    },
    exit: (direction) => ({
      x: direction < 0 ? '100%' : '-100%',
      opacity: 0,
      transition: { duration: 0.5 },
    }),
  };

  return (
    <div className="relative bg-stoneground w-full min-h-screen overflow-hidden pt-16 select-none">
      {/* Title */}
      <div className="absolute mt-5 w-full text-center z-10">
        <h1 className="text-stoneground/80 text-[2rem] md:text-[3rem] font-satoshiBlack">
          Informasi Instansi.
        </h1>
      </div>

      {/* Loading State */}
      {loading && (
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="max-w-lg w-full mx-4">
            <StatusHandler
              status="loading"
              message="Memuat informasi instansi, mohon tunggu sebentar..."
            />
          </div>
        </div>
      )}

      {/* Error State */}
      {!loading && error && (
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="max-w-lg w-full mx-4">
            <StatusHandler
              status="error"
              message={error}
            />
          </div>
        </div>
      )}

      {/* Empty State */}
      {!loading && !error && contentBlocks.length === 0 && (
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="max-w-lg w-full mx-4">
            <StatusHandler
              status="error"
              message="Belum ada informasi instansi yang tersedia saat ini."
            />
          </div>
        </div>
      )}

      {/* Success State with Content */}
      {!loading && !error && contentBlocks.length > 0 && (
        <>
          <AnimatePresence initial={false} custom={direction}>
            <motion.div
              key={currentImageIndex}
              className="absolute top-0 left-0 w-full h-full"
              custom={direction}
              variants={variants}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{
                x: { type: "tween", duration: 0.8 },
              }}
              style={{
                backgroundImage: `url(${currentImage})`,
                backgroundSize: 'cover',
                backgroundPosition: 'center',
              }}
              onPanEnd={(e, { offset, velocity }) => {
                const swipe = swipePower(offset.x, velocity.x);
                if (swipe < -swipeConfidenceThreshold) {
                  handleNext();
                } else if (swipe > swipeConfidenceThreshold) {
                  handlePrev();
                }
              }}
            >
              <div className="absolute inset-0 bg-black bg-opacity-65"></div>

              {/* Content */}
              <motion.div
                className="relative z-10 h-full flex flex-col items-center justify-center text-center px-4"
                variants={contentVariants}
                initial="initial"
                animate="animate"
                exit="exit"
                custom={direction}
              >
                <h2 className="text-stoneground/80 text-[1.5rem] md:text-[2rem] font-satoshiBold mb-4 md:mb-6">
                  {currentBlock?.title}
                </h2>
                <button
                  onClick={() => setIsModalOpen(true)}
                  className="bg-stoneground/20 backdrop-blur-sm text-stoneground font-satoshiMedium px-4 py-2 md:px-6 md:py-3 rounded transition duration-200 hover:bg-stoneground/30"
                >
                  Lihat selengkapnya
                </button>
              </motion.div>
            </motion.div>
          </AnimatePresence>

          {/* Slide Indicators */}
          <div className="absolute bottom-4 w-full flex justify-center space-x-2 z-10">
            {contentBlocks.map((_, index) => (
              <button
                key={index}
                className={`w-2 h-2 md:w-3 md:h-3 rounded-full transition-all duration-300 ${
                  index === currentImageIndex ? 'bg-stoneground scale-125' : 'bg-stoneground/50'
                }`}
                onClick={() => handleIndicatorClick(index)}
              ></button>
            ))}
          </div>

          {/* Modal */}
          <ModalDetailInformasi
            isOpen={isModalOpen}
            onClose={() => setIsModalOpen(false)}
            data={currentBlock}
          />
        </>
      )}

      {/* Divider */}
      <div className="absolute bottom-0 w-full">
        <div className="w-full h-2 bg-bark"></div>
      </div>
    </div>
  );
}

export default InformasiInstansi;
