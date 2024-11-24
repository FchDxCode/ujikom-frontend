import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { categoryAPI } from '../service/category_api';
import CardContainer from '../components/container_card';
import StatusHandler from '../components/statusHandler';

const generateInitials = (text) => {
  const firstWord = text.split('_')[0].split('-')[0];
  return firstWord.charAt(0).toUpperCase();
};

const GalleryPage = () => {
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const h1Ref = useRef(null);
  const [inViewport, setInViewport] = useState(false);

  const dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" }
  ];

  useEffect(() => {
    fetchCategories();

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

  const fetchCategories = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await categoryAPI.getPublicCategories();
      if (!response.data) {
        throw new Error('Tidak ada data kategori yang ditemukan');
      }

      const formattedCategories = response.data.map(category => ({
        id: category.id,
        title: category.name,
        description: category.description,
        updated_at: category.updated_at || new Date().toISOString(),
        initial: generateInitials(category.name),
      }));
      setCategories(formattedCategories);
    } catch (error) {
      console.error('Error fetching categories:', error);
      setError(error.message || 'Gagal memuat kategori. Silakan coba lagi nanti.');
    } finally {
      setLoading(false);
    }
  };

  const handleCategoryClick = (category) => {
    const slug = category.title
      .toLowerCase()
      .replace(/ /g, '-')
      .replace(/[^\w-]+/g, '');
    
    localStorage.setItem('category_id', category.id);
    navigate(`/galeri/${slug}`);
  };

  return (
    <div className="min-h-screen">
      <div className="container mx-auto py-8">
        <h1
          ref={h1Ref}
          className={`text-[4rem] md:text-[5rem] font-leagueBold text-stoneground/80 text-center md:mt-[7rem] mt-[4rem] md:mb-[3rem] mb-[2rem] transition-all duration-[1300ms] ease-in-out ${
            inViewport ? 'translate-y-0 opacity-100' : 'translate-y-[50%] opacity-0'
          }`}
        >
          Galeri.
        </h1>

        {/* Loading State */}
        {loading && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="loading"
              message="Memuat kategori galeri, mohon tunggu sebentar..."
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
        {!loading && !error && categories.length === 0 && (
          <div className="max-w-lg mx-auto px-4">
            <StatusHandler
              status="error"
              message="Tidak ada kategori galeri yang tersedia saat ini."
            />
          </div>
        )}

        {/* Success State with Content */}
        {!loading && !error && categories.length > 0 && (
          <div className="animate-fadeIn">
            <CardContainer 
              data={categories} 
              emptyMessage="Tidak ada data kategori yang tersedia saat ini."
              dropdownOptions={dropdownOptions}
              showProfile={false}
              onCardClick={handleCategoryClick}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default GalleryPage;
