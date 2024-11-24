import React from 'react'
import { CheckCircle, XCircle, Loader2 } from 'lucide-react'

// Tambahkan style untuk animasi progress bar
const progressBarStyle = `
  @keyframes progress {
    0% {
      width: 0%;
      margin-left: 0;
    }
    50% {
      width: 100%;
      margin-left: 0;
    }
    100% {
      width: 0%;
      margin-left: 100%;
    }
  }
`;

export default function StatusHandler({ status, message }) {
  const getStatusConfig = () => {
    switch (status) {
      case 'success':
        return {
          icon: <CheckCircle className="w-16 h-16 text-stoneground/80" />,
          textColor: 'text-stoneground/80',
          bgColor: 'bg-shadow/30',
        }
      case 'error':
        return {
          icon: <XCircle className="w-16 h-16 text-stoneground/80" />,
          textColor: 'text-stoneground/80',
          bgColor: 'bg-shadow/30',
        }
      case 'loading':
        return {
          icon: <Loader2 className="w-16 h-16 text-stoneground/80 animate-spin" />,
          textColor: 'text-stoneground/80',
          bgColor: 'bg-shadow/30',
        }
      default:
        return null
    }
  }

  const config = getStatusConfig()

  if (!config) return null

  return (
    <>
      {/* Tambahkan style untuk animasi */}
      <style>{progressBarStyle}</style>

      <div className="flex items-center justify-center w-full p-4">
        <div 
          className={`
            max-w-lg w-full mx-auto p-8 
            ${config.bgColor}
            backdrop-blur-md 
            rounded-[2rem]
            border border-stoneground/80
            transition-all duration-500 ease-in-out 
            relative overflow-hidden
            animate-fadeIn
          `}
        >
          <div className="relative z-10">
            {/* Icon and Content Container */}
            <div className="flex flex-col items-center text-center space-y-6">
              <div className="transform transition-transform duration-300 hover:scale-110">
                {config.icon}
              </div>
              
              <div className="space-y-3">
                <h3 className={`text-xl md:text-2xl font-satoshiBold ${config.textColor}`}>
                  {status === 'loading' ? 'Memuat Data' : 
                   status === 'error' ? 'Terjadi Kesalahan' : 
                   'Berhasil'}
                </h3>
                <p className={`text-base md:text-lg font-satoshiMedium ${config.textColor} opacity-80`}>
                  {message}
                </p>
              </div>
            </div>

            {/* Loading Progress Bar */}
            {status === 'loading' && (
              <div className="mt-8">
                <div className="h-1.5 bg-stoneground/20 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-stoneground/60 rounded-full animate-progress"
                    style={{
                      width: '100%',
                      animation: 'progress 1.5s ease-in-out infinite',
                    }}
                  />
                </div>
              </div>
            )}
          </div>

          {/* Optional: Decorative Element for Error State */}
          {status === 'error' && (
            <div className="mt-8 text-center text-stoneground/20 font-satoshiMedium">
              ¯\_(ツ)_/¯
            </div>
          )}
        </div>
      </div>
    </>
  )
}