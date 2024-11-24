import React, { useState, useEffect, useRef } from 'react';
import { contentBlockAPI } from '../service/contentblock_api';
import CardContainer from '../components/container_card';
import { useNavigate } from 'react-router-dom';
import StatusHandler from '../components/statusHandler';

const AgendaPage = () => {
  const navigate = useNavigate();
  const [contentBlocks, setContentBlocks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const h1Ref = useRef(null);
  const [inViewport, setInViewport] = useState(false);

  const dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" }
  ];

  useEffect(() => {
    fetchAgendaContent();

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

  const fetchAgendaContent = async () => {
    try {
      setError(null);
      setLoading(true);

      // Fetch content blocks
      const response = await contentBlockAPI.getContentBlocksByPageSlug('agenda');
      
      const formattedContent = response.data.map(block => ({
        id: block.id,
        title: block.title,
        description: block.description,
        image: block.image || null,
        created_by: block.created_by,
        updated_at: block.updated_at
      }));

      setContentBlocks(formattedContent);
    } catch (error) {
      console.error('Error fetching agenda content:', error);
      setError('Terjadi kesalahan saat memuat data agenda. Silakan coba lagi nanti.');
    } finally {
      setLoading(false);
    }
  };

  const handleCardClick = (agenda) => {
    const slug = agenda.title
      .toLowerCase()
      .replace(/ /g, '-')
      .replace(/[^\w-]+/g, '');
    
    localStorage.setItem('agenda_id', agenda.id);
    navigate(`/agenda/${slug}`);
  };

  return (
    <div className="min-h-screen bg-new-gradient">
      <div className="container mx-auto py-8">
        <h1
          ref={h1Ref}
          className={`text-[4rem] md:text-[5rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[4rem] md:mb-[3rem] mb-[2rem] transition-all duration-[1300ms] ease-in-out ${
            inViewport ? 'translate-y-0 opacity-100' : 'translate-y-[50%] opacity-0'
          }`}
        >
          Agenda.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-screen-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat daftar agenda, mohon tunggu sebentar..."
            />
          </div>
        )}

        {/* Error State */}
        {!loading && error && (
          <div className="max-w-screen-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message={error}
            />
          </div>
        )}

        {/* Empty State */}
        {!loading && !error && contentBlocks.length === 0 && (
          <div className="max-w-screen-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Belum ada agenda yang tersedia saat ini."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && contentBlocks.length > 0 && (
          <div className="animate-fadeIn">
            <CardContainer 
              data={contentBlocks}
              emptyMessage="Tidak ada agenda yang tersedia saat ini."
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

export default AgendaPage;
