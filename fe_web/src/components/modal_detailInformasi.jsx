import React, { useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'

const ModalDetailInformasi = ({ isOpen, onClose, data }) => {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') onClose()
    }
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [onClose])

  if (!isOpen || !data) return null

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.95, opacity: 0 }}
          onClick={(e) => e.stopPropagation()}
          className="relative bg-shadow/25 backdrop-blur-lg rounded-lg shadow-xl w-full max-w-2xl overflow-hidden"
        >
          <button
            className="absolute top-2 right-2 z-10 p-2 text-shadow hover:text-red-600 transition-colors"
            onClick={onClose}
          >
            <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
            <span className="sr-only">Tutup</span>
          </button>

          <div className="relative w-full h-48 sm:h-64 md:h-72">
            <img
              src={data.image}
              alt={data.title}
              className="w-full h-full object-cover"
              onError={(e) => {
                e.target.src = '/placeholder.svg'
              }}
            />
            <button
              onClick={async (e) => {
                e.stopPropagation();
                try {
                  const response = await fetch(data.image);
                  const blob = await response.blob();
                  const url = window.URL.createObjectURL(blob);
                  const link = document.createElement('a');
                  link.href = url;
                  link.download = `${data.title}.jpg`; // atau ekstensi yang sesuai
                  document.body.appendChild(link);
                  link.click();
                  document.body.removeChild(link);
                  window.URL.revokeObjectURL(url);
                } catch (error) {
                  console.error('Download failed:', error);
                  // Tambahkan handling error sesuai kebutuhan
                }
              }}
              className="absolute bottom-4 left-4 bg-black/50 hover:bg-black/70 text-white p-2 rounded-full transition-colors"
              title="Download gambar"
            >
              <svg 
                xmlns="http://www.w3.org/2000/svg" 
                className="h-6 w-6" 
                fill="none" 
                viewBox="0 0 24 24" 
                stroke="currentColor"
              >
                <path 
                  strokeLinecap="round" 
                  strokeLinejoin="round" 
                  strokeWidth={2} 
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" 
                />
              </svg>
              <span className="sr-only">Download gambar</span>
            </button>
          </div>

          <div className="p-6 max-h-[calc(90vh-12rem)] overflow-y-auto">
            <h2 className="text-2xl font-satoshiBold text-stoneground mb-4">{data.title}</h2>
            <div className="prose prose-sm sm:prose-base max-w-none mb-6">
              <p className="text-cerramic font-satoshiRegular whitespace-pre-line">{data.description}</p>
            </div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between text-sm text-cerramic">
              <div className="flex items-center space-x-2 mb-2 sm:mb-0">
                <span className="font-satoshiRegular">Dibuat oleh:</span>
                <span>{data.created_by}</span>
              </div>
              <div>
                {new Date(data.updated_at).toLocaleDateString('id-ID', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                })}
              </div>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  )
}

export default ModalDetailInformasi