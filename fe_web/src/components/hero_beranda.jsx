import React, { useEffect, useRef, useState } from "react";
import { contentBlockAPI } from '../service/contentblock_api';

const HeroDashboard = () => {
  const h1Ref = useRef(null);
  const h2Ref = useRef(null);
  const logoRef = useRef(null);
  const [inViewport, setInViewport] = useState({ h1: false, h2: false, logo: false });
  const [heroContent, setHeroContent] = useState({ title: '', image: '' });
  const [backgroundImage, setBackgroundImage] = useState('');

  useEffect(() => {
    const fetchContent = async () => {
      try {
        // Fetch logo and title
        const logoResponse = await contentBlockAPI.getContentBlocksByPageSlug('logo-website');
        if (logoResponse.data && logoResponse.data.length > 0) {
          setHeroContent({
            title: logoResponse.data[0].title,
            image: logoResponse.data[0].image
          });
        }

        // Fetch background image
        const heroResponse = await contentBlockAPI.getContentBlocksByPageSlug('hero-website');
        if (heroResponse.data && heroResponse.data.length > 0) {
          setBackgroundImage(heroResponse.data[0].image);
        }
      } catch (error) {
        console.error('Error fetching content:', error);
      }
    };

    fetchContent();
  }, []);

  useEffect(() => {
    const observerOptions = {
      root: null,
      rootMargin: "0px",
      threshold: 0.5, // Animasi dipicu saat 50% elemen terlihat
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const target = entry.target;
        const isIntersecting = entry.isIntersecting;

        if (target === h1Ref.current) {
          setInViewport((prev) => ({ ...prev, h1: isIntersecting }));
        }
        if (target === h2Ref.current) {
          setInViewport((prev) => ({ ...prev, h2: isIntersecting }));
        }
        if (target === logoRef.current) {
          setInViewport((prev) => ({ ...prev, logo: isIntersecting }));
        }
      });
    }, observerOptions);

    // Attach observers
    const h1Element = h1Ref.current;
    const h2Element = h2Ref.current;
    const logoElement = logoRef.current;

    if (h1Element) observer.observe(h1Element);
    if (h2Element) observer.observe(h2Element);
    if (logoElement) observer.observe(logoElement);

    return () => {
      // Cleanup
      if (h1Element) observer.unobserve(h1Element);
      if (h2Element) observer.unobserve(h2Element);
      if (logoElement) observer.unobserve(logoElement);
    };
  }, []);

  return (
    <div className="relative select-none">
      {/* Background Section */}
      <div
        className="relative w-full h-screen bg-cover bg-center"
        style={{
          backgroundImage: `url(${backgroundImage || `${process.env.PUBLIC_URL}/assets/img/dashboardBg.png`})`,
        }}
      >
        <div
          className="absolute inset-0 flex flex-col items-center justify-center"
          style={{
            background:
              "linear-gradient(180deg, rgba(0, 0, 0, 0.47) 50%, rgba(0, 0, 0, 0) 100%)",
          }}
        >
          {/* Teks h1 */}
          <h1
            ref={h1Ref}
            className={`text-3xl md:text-[3rem] text-center text-stoneground/80 font-satoshiBlack transition-all duration-[1300ms] ease-in-out ${
              inViewport.h1
                ? "translate-x-0 opacity-100"
                : "translate-x-[50%] opacity-0"
            }`}
          >
            Selamat datang di
          </h1>

          {/* Teks h2 */}
          <h2
            ref={h2Ref}
            className={`text-3xl md:text-[3rem] text-center text-stoneground/80 font-satoshiBlack mt-4 transition-all duration-[1300ms] ease-in-out ${
              inViewport.h2
                ? "translate-x-0 opacity-100"
                : "-translate-x-[50%] opacity-0"
            }`}
          >
            {heroContent.title}
          </h2>

          {/* Logo */}
          <img
            ref={logoRef}
            src={heroContent.image}
            alt="Logo Luminova"
            className={`h-28 w-28 md:h-44 md:w-44 object-contain mt-6 transition-all duration-[1300ms] ease-in-out ${
              inViewport.logo
                ? "translate-y-0 opacity-100"
                : "translate-y-[50%] opacity-0"
            }`}
          />
        </div>
      </div>

      {/* Divider */}
      <div className="h-2 bg-bark w-full rounded-full" />
    </div>
  );
};

export default HeroDashboard;
