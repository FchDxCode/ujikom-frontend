import React, { useEffect, useState } from "react";
import Viewer from "react-viewer";
import { FaTwitter, FaInstagram, FaFacebook, FaClock, FaDownload } from "react-icons/fa";
import { MdContentCopy } from "react-icons/md";
import { Link } from "react-router-dom";
import AOS from "aos";
import "aos/dist/aos.css";

const ContentGridDetail = ({ title, image, description, date }) => {
  const [showCopyNotification, setShowCopyNotification] = useState(false);
  const [showDownloadNotification, setShowDownloadNotification] = useState(false);
  const [isButtonDisabled, setIsButtonDisabled] = useState(false);
  const [isDownloadDisabled, setIsDownloadDisabled] = useState(false);
  const [viewerVisible, setViewerVisible] = useState(false);
  const [isDownloading, setIsDownloading] = useState(false);

  useEffect(() => {
    AOS.init({
      duration: 800,
      easing: "ease-in-out",
      delay: 100,
      mirror: true,
      once: false,
    });
    AOS.refresh();
  }, []);

  const handleCopyLink = async () => {
    if (isButtonDisabled) return;

    try {
      await navigator.clipboard.writeText(window.location.href);
      setShowCopyNotification(true);
      setIsButtonDisabled(true);

      setTimeout(() => {
        setShowCopyNotification(false);
        setIsButtonDisabled(false);
      }, 2000);
    } catch (err) {
      console.error("Failed to copy:", err);
      setIsButtonDisabled(false);
    }
  };

  const handleDownload = async () => {
    if (isDownloading || !image || isDownloadDisabled) return;

    try {
      setIsDownloading(true);
      setIsDownloadDisabled(true);
      setShowDownloadNotification(true);

      // Ambil nama file dari URL
      const fileName = image.split('/').pop() || 'photo.jpg';

      // Fetch gambar sebagai blob
      const response = await fetch(image);
      const blob = await response.blob();
      
      // Buat object URL
      const url = window.URL.createObjectURL(blob);
      
      // Buat element link untuk download
      const link = document.createElement('a');
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      
      // Cleanup
      window.URL.revokeObjectURL(url);
      document.body.removeChild(link);

      // Reset states setelah 2 detik
      setTimeout(() => {
        setShowDownloadNotification(false);
        setIsDownloadDisabled(false);
      }, 2000);
    } catch (error) {
      console.error("Download error:", error);
    } finally {
      setIsDownloading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 w-full gap-3 p-6 md:p-[3rem] overflow-hidden">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-3 md:gap-6">
        {/* Image Viewer Integration */}
        <div
          className="lg:col-span-8 relative h-[400px] w-full bg-[#5A5859]/80 overflow-hidden rounded-[2rem] border border-stoneground/80"
          data-aos="fade-down-right"
        >
          {image ? (
            <img
              src={image}
              alt={title}
              className="cursor-pointer w-full h-full object-cover rounded-[2.3rem] p-3"
              onClick={() => setViewerVisible(true)}
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-stoneground/10">
              <span className="text-stoneground text-xl">Tidak ada gambar</span>
            </div>
          )}
        </div>

        <div
          className="lg:col-span-4 flex flex-col w-full bg-[#5A5859]/80 rounded-[2rem] border border-stoneground/80"
          data-aos="fade-left"
        >
          <h1 className="text-lg md:text-[1.5rem] p-3 px-7 md:p-6 md:px-7 font-satoshiBold text-stoneground break-words">
            {title}
          </h1>
          <div
            className="mt-auto flex items-center justify-end gap-3 md:gap-4 p-3 md:p-4 md:px-7 px-7"
            data-aos="fade-up-left"
          >
            <Link
              to="https://x.com/"
              rel="noreferrer"
              target="_blank"
              className="text-cerramic hover:text-mist transition-colors duration-300"
            >
              <FaTwitter className="w-5 h-5 md:w-6 md:h-6" />
            </Link>
            <Link
              to="https://www.instagram.com/f4_rpl2/"
              rel="noreferrer"
              target="_blank"
              className="text-cerramic hover:text-mist transition-colors duration-300"
            >
              <FaInstagram className="w-5 h-5 md:w-6 md:h-6" />
            </Link>
            <Link
              to="https://web.facebook.com/fahru.buchori.1"
              rel="noreferrer"
              target="_blank"
              className="text-cerramic hover:text-mist transition-colors duration-300"
            >
              <FaFacebook className="w-5 h-5 md:w-6 md:h-6" />
            </Link>

            <div className="relative">
              <button
                onClick={handleDownload}
                disabled={isDownloadDisabled}
                className={`text-cerramic transition-colors duration-300 ${
                  isDownloadDisabled ? "opacity-50 cursor-not-allowed" : "hover:text-mist"
                }`}
                title="Download foto"
              >
                <FaDownload className="w-5 h-5 md:w-6 md:h-6" />
              </button>
              {showDownloadNotification && (
                <div
                  className="absolute bottom-full font-satoshiBold right-0 mb-2 px-3 py-1 bg-stoneground text-shadow text-sm rounded-md whitespace-nowrap"
                  style={{
                    animation: "fadeInOut 2s ease-in-out",
                  }}
                >
                  Mengunduh foto...
                </div>
              )}
            </div>

            <div className="relative">
              <button
                onClick={handleCopyLink}
                disabled={isButtonDisabled}
                className={`text-cerramic transition-colors duration-300 ${
                  isButtonDisabled
                    ? "opacity-50 cursor-not-allowed"
                    : "hover:text-mist"
                }`}
              >
                <MdContentCopy className="w-5 h-5 md:w-6 md:h-6" />
              </button>
              {showCopyNotification && (
                <div
                  className="absolute bottom-full font-satoshiBold right-0 mb-2 px-3 py-1 bg-stoneground text-shadow text-sm rounded-md whitespace-nowrap"
                  style={{
                    animation: "fadeInOut 2s ease-in-out",
                  }}
                >
                  Link berhasil disalin!
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Viewer Instance */}
      {image && (
        <Viewer
          visible={viewerVisible}
          onClose={() => setViewerVisible(false)}
          images={[{ src: image, alt: title }]}
          changeable={false}
          zoomable={true}
          rotatable={true}
          scalable={true}
          drag={true}
          customToolbar={(config) => [
            ...config,
            {
              key: "download",
              render: <span>⤓ Download</span>,
              onClick: handleDownload,
            },
          ]}
        />
      )}

      <div
        className="text-sm sm:text-base text-stoneground bg-[#5A5859]/80 rounded-[2rem] p-4 font-satoshiMedium border border-stoneground/80 min-h-[10rem] h-fit md:px-8"
        data-aos="fade-up"
      >
        <div className="flex flex-col h-full justify-between">
          <div className="mb-4" data-aos="fade-down-right">
            {description}
          </div>
          <div
            className="flex justify-end pt-[4.5rem] text-sm text-stoneground/60 items-center gap-2"
            data-aos="fade-up-left"
          >
            <FaClock className="w-4 h-4" />
            {date}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ContentGridDetail;
