import React, { useState, useEffect } from 'react';
import { FaTwitter, FaInstagram, FaFacebook, FaLinkedin } from 'react-icons/fa';
import { Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { contentBlockAPI } from '../service/contentblock_api';

const Footer = () => {
  const [isContactOpen, setIsContactOpen] = useState(false);
  const [isMapExpanded, setIsMapExpanded] = useState(false);
  const [isDesktop, setIsDesktop] = useState(window.innerWidth >= 1024); // Misalnya, lg breakpoint di Tailwind adalah 1024px
  const [footerContent, setFooterContent] = useState({ title: '', image: '' });

  // Update isDesktop saat ukuran jendela berubah
  useEffect(() => {
    const handleResize = () => {
      setIsDesktop(window.innerWidth >= 1024);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Tambahkan useEffect untuk fetch data
  useEffect(() => {
    const fetchFooterContent = async () => {
      try {
        const response = await contentBlockAPI.getContentBlocksByPageSlug('logo-website');
        if (response.data && response.data.length > 0) {
          setFooterContent({
            title: response.data[0].title,
            image: response.data[0].image
          });
        }
      } catch (error) {
        console.error('Error fetching footer content:', error);
      }
    };

    fetchFooterContent();
  }, []);

  const toggleContactForm = () => setIsContactOpen(!isContactOpen);
  const toggleMap = () => setIsMapExpanded(!isMapExpanded);

  const handleSubmit = (event) => {
    event.preventDefault();
    // Penanganan pengiriman formulir
    alert("Message Sent! We'll get back to you soon.");
    setIsContactOpen(false);
  };

  const handleNewsletter = (event) => {
    event.preventDefault();
    // Penanganan pendaftaran newsletter
    alert("Subscribed! You've been added to our newsletter.");
  };

  // Variants untuk formulir kontak
  const contactVariants = {
    hidden: { opacity: 0, height: 0, overflow: 'hidden' },
    visible: { opacity: 1, height: 'auto', overflow: 'hidden' },
  };

  // Variants untuk peta
  const mapVariantsMobile = {
    hidden: { opacity: 0, height: 0, overflow: 'hidden' },
    visible: { opacity: 1, height: 300, overflow: 'hidden' },
  };

  const mapVariantsDesktop = {
    hidden: { opacity: 0, y: -20 },
    visible: { opacity: 1, y: 0 },
  };

  return (
    <footer className="bg-gray-900 text-stoneground mt-32 py-12 px-4 md:px-8 lg:px-12">
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {/* Logo and Company Info */}
        <div className="flex flex-col items-center md:items-start space-y-4">
          <div className="flex items-center space-x-4"> 
            <img 
              src={footerContent.image} 
              alt="Company Logo" 
              className="w-16 h-16 md:w-20 md:h-20" 
            />
            <div>
              <h2 className="text-2xl md:text-[2rem] font-leagueBold">
                {footerContent.title}
              </h2>
              <p className="text-sm font-satoshiMedium">Crafting Digital Experiences</p>
            </div>
          </div>
          <p className="text-sm text-cerramic font-poppinsRegular text-center md:text-left">
            Kami spesialisasi dalam menciptakan website dan aplikasi yang indah dan fungsional yang membantu bisnis berkembang dalam dunia digital.
          </p>
        </div>

        {/* Contact and Social Media */}
        <div className="flex flex-col items-center md:items-start space-y-6">
          <button
            className={`font-satoshiMedium px-4 py-2 rounded-md ${
              isContactOpen
                ? 'bg-shadow text-stoneground'
                : 'bg-blue-600 text-stoneground'
            } hover:bg-blue-800 transition-colors duration-300`}
            onClick={toggleContactForm}
          >
            {isContactOpen ? 'Tutup kontak' : 'Kontak kami'}
          </button>

          <AnimatePresence>
            {isContactOpen && (
              <motion.form
                onSubmit={handleSubmit}
                className="w-full space-y-4"
                initial="hidden"
                animate="visible"
                exit="hidden"
                variants={contactVariants}
                transition={{ duration: 0.5, ease: 'easeInOut' }}
              >
                <input
                  type="text"
                  placeholder="Nama"
                  required
                  className="w-full px-3 py-2 bg-gray-800 text-stoneground rounded-md"
                />
                <input
                  type="email"
                  placeholder="Email"
                  required
                  className="w-full px-3 py-2 bg-gray-800 text-stoneground rounded-md"
                />
                <textarea
                  placeholder="Pesan"
                  required
                  className="w-full px-3 py-2 bg-gray-800 text-stoneground rounded-md"
                ></textarea>
                <button
                  type="submit"
                  className="px-4 py-2 font-satoshiMedium bg-blue-600 text-stoneground rounded-md hover:bg-blue-800 transition-colors duration-400"
                >
                  Kirim Pesan
                </button>
              </motion.form>
            )}
          </AnimatePresence>

          <div className="flex space-x-4">
            <Link to="https://x.com/" target='_blank' className="text-cerramic hover:text-mist duration-300 transition-colors">
              <FaTwitter size={24} />
              <span className="sr-only">Twitter</span>
            </Link>
            <Link to="https://www.instagram.com/f4_rpl2/" target='_blank' className="text-cerramic hover:text-mist duration-300 transition-colors">
              <FaInstagram size={24} />
              <span className="sr-only">Instagram</span>
            </Link>
            <Link to="https://web.facebook.com/fahru.buchori.1" target='_blank' className="text-cerramic hover:text-mist duration-300 transition-colors">
              <FaFacebook size={24} />
              <span className="sr-only">Facebook</span>
            </Link>
            <Link to="https://www.linkedin.com/in/fachru-buchori-83010728a/" target='_blank' className="text-cerramic hover:text-mist duration-300 transition-colors">
              <FaLinkedin size={24} />
              <span className="sr-only">LinkedIn</span>
            </Link>
          </div>
        </div>

        {/* Newsletter Signup */}
        <div className="flex flex-col items-center lg:items-end space-y-4">
          <h3 className="text-xl font-satoshiBold">Tetap Terhubung</h3>
          <form onSubmit={handleNewsletter} className="flex w-full max-w-sm items-center space-x-2">
            <input
              type="email"
              placeholder="Masukkan email anda"
              required
              className="flex-grow px-3 py-2 bg-gray-800 text-stoneground rounded-md"
            />
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-stoneground rounded-md hover:bg-blue-800 transition-colors duration-300"
            >
              Berlangganan
            </button>
          </form>
        </div>
      </div>

      {/* Map Section */}
      <div className="mt-12">
        <button
          onClick={toggleMap}
          className="w-full md:w-auto mb-4 px-4 py-2 bg-gray-800 text-stoneground rounded-md hover:bg-gray-700 transition-colors duration-300"
        >
          {isMapExpanded ? 'Tutup Peta' : 'Lihat Peta'}
        </button>
        <AnimatePresence>
          {isMapExpanded && (
            <motion.div
              className={`w-full rounded-lg overflow-hidden ${
                isDesktop ? 'h-[400px]' : 'h-[300px]'
              }`}
              initial="hidden"
              animate="visible"
              exit="hidden"
              variants={isDesktop ? mapVariantsDesktop : mapVariantsMobile}
              transition={{ duration: 0.5, ease: 'easeInOut' }}
            >
              <iframe
                title='SMKN 4 BOGOR'
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3963.0498396124403!2d106.8221189736684!3d-6.640733393353769!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e69c8b16ee07ef5%3A0x14ab253dd267de49!2sSMK%20Negeri%204%20Bogor%20(Nebrazka)!5e0!3m2!1sid!2sid!4v1731589996527!5m2!1sid!2sid"
                width="100%"
                height="100%"
                style={{ border: 0 }}
                allowFullScreen={false}
                loading="lazy"
                referrerPolicy="no-referrer-when-downgrade"
              ></iframe>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Copyright */}
      <div className="mt-12 text-center text-sm text-cerramic">
        <p>&copy; {new Date().getFullYear()} Luminova. All rights reserved.</p>
      </div>
    </footer>
  );
};

export default Footer;
