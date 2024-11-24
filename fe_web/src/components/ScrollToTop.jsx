import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const ScrollToTop = () => {
  const { pathname } = useLocation();

  useEffect(() => {
    // Gulir ke atas dengan sedikit penundaan untuk memastikan konten telah dirender
    setTimeout(() => {
      window.scrollTo(0, 0);
    }, 0);
  }, [pathname]);

  return null;
};

export default ScrollToTop;
