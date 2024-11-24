import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from '../components/navbar';
import Footer from '../components/footer';
import NotFound from '../components/NotFound';
import DashboardPage from '../page/beranda_page';
import InformasiPage from '../page/informasi_page';
import AgendaPage from '../page/agenda_page';
import AlbumPage from '../page/album_page';
import GalleryPage from '../page/gallery_page';
import PhotoPage from '../page/photo_page';
import ChildAgendaPage from '../page/childAgenda_page';
import ChildInformasiPage from '../page/childInformasi_page';
import ChildPhotoPage from '../page/childPhoto_page';
import ScrollToTop from '../components/ScrollToTop';
import AiPage from '../page/ai_page';
import FloatingChatButton from '../components/FloatingChatButton_components';
import ChildPhotoAI from '../page/childAi_page';

const Layout = ({ children }) => {
  return (
    <div className="flex flex-col bg-new-gradient min-h-screen overflow-x-hidden">
      <Navbar />
      <main className="flex-grow scroll-smooth">{children}</main>
      <FloatingChatButton />
      <Footer />
    </div>
  );
};

const AppRoutes = () => {
  return (
    <Router>
      <ScrollToTop />
      <Routes>
        <Route path="/" element={<Layout><DashboardPage /></Layout>} />

        {/* Routes Informasi */}
        <Route path="/informasi" element={<Layout><InformasiPage /></Layout>} />
        <Route path="/informasi/:slug" element={<Layout><ChildInformasiPage /></Layout>} />
        
        {/* Routes Agenda */}
        <Route path="/agenda" element={<Layout><AgendaPage /></Layout>} />
        <Route path="/agenda/:slug" element={<Layout><ChildAgendaPage /></Layout>} />
        
        {/* Routes Gallery */}
        <Route path="/galeri" element={<Layout><GalleryPage /></Layout>} />
        <Route path="/galeri/:categorySlug" element={<Layout><AlbumPage /></Layout>} />
        <Route path="/galeri/:categorySlug/:albumSlug" element={<Layout><PhotoPage /></Layout>} />
        <Route path="/galeri/:categorySlug/:albumSlug/:photoSlug" element={<Layout><ChildPhotoPage /></Layout>} />

        {/* Routes AI */}
        <Route path="/ai" element={<Layout><AiPage /></Layout>} />
        <Route path="/ai/album/:categorySlug/:albumSlug" element={<Layout><PhotoPage /></Layout>} />
        <Route path="/ai/photo/:categorySlug/:albumSlug/:photoSlug" element={<Layout><ChildPhotoAI /></Layout>} />
        
        <Route path="*" element={<Layout><NotFound /></Layout>} />
      </Routes>
    </Router>
  );
};

export default AppRoutes;
