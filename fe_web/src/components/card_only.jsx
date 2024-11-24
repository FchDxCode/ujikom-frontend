import React from 'react';
import { motion } from 'framer-motion';
import PropTypes from 'prop-types';

const Card = ({ data = {}, onClick, showProfile = true }) => {
  const { 
    title = '', 
    image = '', 
    description = '', 
    created_by = '', 
    updated_at = '' 
  } = data;

  const formatDate = (isoString) => {
    if (!isoString) return '-';
    
    try {
      const date = new Date(isoString);
      const options = {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
      };

      return date.toLocaleDateString('id-ID', options);
    } catch (error) {
      console.error('Error formatting date:', error);
      return '-';
    }
  };

  const formattedDate = formatDate(updated_at);

  const handleClick = () => {
    if (onClick) {
      onClick(data);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  };

  // Fungsi untuk mengambil maksimal 5 karakter dari title
  const getInitials = (text) => {
    if (!text) return 'ABC';
    // Hapus karakter khusus dan split berdasarkan spasi atau underscore atau dash
    const words = text.replace(/[^a-zA-Z0-9 -_]/g, '').split(/[-_ ]/);
    // Ambil maksimal 5 karakter pertama dari kata pertama
    return words[0].slice(0, 10).toUpperCase();
  };

  return (
    <motion.div
      className="select-none max-w-sm md:max-w-md lg:max-w-lg overflow-hidden rounded-card border-2 bg-grayCard/70 p-2.5 mx-auto md:mx-0 cursor-pointer flex flex-col"
      onClick={handleClick}
      role="button"
      tabIndex={0}
      onKeyDown={handleKeyDown}
      whileHover={{
        scale: 1.01,
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        borderColor: 'rgba(168, 162, 158, 1)',
      }}
      transition={{
        type: 'tween',
        duration: 0.2,
      }}
      initial={{
        scale: 1,
        borderColor: 'rgba(168, 162, 158, 0.3)',
      }}
    >
      {/* Image Section */}
      <div className="relative h-[178px] w-full overflow-hidden rounded-imageCard border border-stoneground/80 flex-shrink-0">
        {image ? (
          <img
            src={image}
            alt={title}
            className="h-full w-full object-cover rounded-imageCard"
            onError={(e) => {
              // Jika gambar error, tampilkan div dengan inisial
              e.target.style.display = 'none';
              e.target.nextElementSibling.style.display = 'flex';
            }}
          />
        ) : null}
        <div 
          className={`h-full w-full flex items-center justify-center bg-abuabu ${image ? 'hidden' : 'flex'}`}
        >
          <span className="text-4xl font-leagueBold text-stoneground">
            {getInitials(title)}
          </span>
        </div>
      </div>

      {/* Content Section */}
      <div className="flex-grow flex flex-col justify-between px-4 pb-4 pt-1 space-y-3">
        <div>
          <h2 className="text-xl font-satoshiBold text-stoneground line-clamp-1">
            {title}
          </h2>
          <p className="text-sm font-satoshiRegular text-cerramic line-clamp-2 min-h-[2.25rem]">
            {description}
          </p>
        </div>

        {showProfile ? (
          <div className="bg-grayProfile p-3 rounded-2xl flex items-center gap-3 mt-auto">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-shadow text-stoneground font-poppinsMedium text-xl flex-shrink-0">
              {created_by ? created_by.charAt(0).toUpperCase() : 'A'}
            </div>
            <div className="flex flex-col">
              <span className="text-md font-satoshiMedium text-stoneground truncate">
                {created_by || 'Admin'}
              </span>
              <span className="text-xs text-cerramic font-satosRegular truncate">
                {formattedDate}
              </span>
            </div>
          </div>
        ) : (
          <div className="flex justify-end items-center text-xs text-cerramic font-satoshiRegular mt-2">
            <span>{formattedDate}</span>
          </div>
        )}
      </div>
    </motion.div>
  );
};

// Menambahkan PropTypes untuk validasi props
Card.propTypes = {
  data: PropTypes.shape({
    title: PropTypes.string,
    image: PropTypes.string,
    description: PropTypes.string,
    created_by: PropTypes.string,
    updated_at: PropTypes.string,
  }),
  onClick: PropTypes.func,
  showProfile: PropTypes.bool,
};

export default Card;
