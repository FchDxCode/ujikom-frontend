/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'bg1': '#4C425F',
        'bg2': '#AF8BB4',
        'bg3': '#AF8BF4',
        'stoneground': '#F1F1F2',
        'shadow': '#2A3132',
        'cerramic': '#CDCDC0',
        'abuabu': '#626D71',
        'mushorom': '#FEF2E4',
        'mist': '#ACD0C0',
        'bark': '#2A2922',
        'hijauDot': '#B4FAAC',
        'grayBg1': '#2B2C2E',
        'grayBg2': '#787878',
        'grayBg3': '#626262',
        'grayCard': '#5A5758',
        'grayProfile': '#484848',
      },
      backgroundImage: {
        'custom-gradient': 'linear-gradient(to bottom left, #AF8BF4, #4C425F)',
        'gradient-informasi': 'linear-gradient(135deg, #AF8BF4 0%, #4C425F 100%)',
        'new-gradient': 'linear-gradient(to left, #4C425F, #AF8BB4)',
      },
      fontFamily: {
        satoshiRegular: "satoshi_regular",
        satoshiMedium: "satoshi_medium",
        satoshiBold: "satoshi_bold",
        satoshiBlack: "satoshi_black",
        poppinsRegular: "poppins_regular",
        poppinsBold: "poppins_bold",
        poppinsBlack: "poppins_black",
        poppinsMedium: "poppins_medium",
        leagueBold: "league_bold",
      },
      borderRadius: {
        'none': '0',
        'sm': '0.125rem',
        'md': '0.375rem',
        'lg': '0.5rem',
        'card': '25px',
        'imageCard': '28px',
        'large': '12px',
      },
      animation: {
        'fadeIn': 'fadeIn 0.5s ease-in-out',
        'progress': 'progress 1.5s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        progress: {
          '0%': { width: '0%', marginLeft: '0' },
          '50%': { width: '100%', marginLeft: '0' },
          '100%': { width: '0%', marginLeft: '100%' },
        },
      },
    },
  },
  plugins: [
  ],
}