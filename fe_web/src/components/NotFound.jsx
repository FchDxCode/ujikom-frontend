import React from 'react';
import { useNavigate } from 'react-router-dom';
import { FaHome, FaArrowLeft } from 'react-icons/fa';

const NotFound = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen flex items-center justify-center p-4 mt-20">
      <div className="text-center">
        {/* Error Code */}
        <h1 className="text-[8rem] md:text-[12rem] font-leagueBold text-stoneground/80 leading-none animate-pulse">
          404
        </h1>
        
        {/* Error Message */}
        <h2 className="text-2xl md:text-3xl font-satoshiBold text-stoneground/60 mt-4 mb-8">
          Halaman Tidak Ditemukan
        </h2>
        
        {/* Description */}
        <p className="text-base md:text-lg text-stoneground/50 max-w-md mx-auto mb-12">
          Maaf, halaman yang Anda cari tidak dapat ditemukan atau telah dipindahkan.
        </p>
        
        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center gap-2 px-6 py-3 bg-shadow/30 backdrop-blur-md rounded-xl 
                     text-stoneground hover:bg-shadow/50 transition-all duration-300 
                     group w-full sm:w-auto justify-center"
          >
            <FaArrowLeft className="group-hover:-translate-x-1 transition-transform" />
            Kembali
          </button>
          
          <button
            onClick={() => navigate('/')}
            className="flex items-center gap-2 px-6 py-3 bg-shadow/30 backdrop-blur-md rounded-xl 
                     text-stoneground hover:bg-shadow/50 transition-all duration-300 
                     group w-full sm:w-auto justify-center"
          >
            <FaHome className="group-hover:scale-110 transition-transform" />
            Beranda
          </button>
        </div>

        {/* Optional: Decorative Element */}
        <div className="mt-16 text-stoneground/20 font-satoshiMedium">
          ¯\_(ツ)_/¯
        </div>
      </div>
    </div>
  );
};

export default NotFound;