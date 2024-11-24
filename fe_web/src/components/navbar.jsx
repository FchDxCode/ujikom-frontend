import * as React from "react";
import { Link, useLocation } from "react-router-dom";

export default function Navbar() {
  const location = useLocation();
  const pathname = location.pathname;

  const navigation = [
    { name: "Beranda", href: "/" },
    { name: "Galeri", href: "/galeri" },
    { name: "Informasi", href: "/informasi" },
    { name: "Agenda", href: "/agenda" },
  ];

  // Fungsi untuk memeriksa apakah rute saat ini aktif (termasuk child routes)
  const isActive = (href) => {
    // Pastikan hanya satu item aktif pada satu waktu
    if (href === "/") {
      return pathname === href;
    }
    return pathname.startsWith(href);
  };

  return (
    <header className="fixed top-0 z-50 w-full flex justify-center mt-5 px-3 sm:px-0 select-none">
      <nav className="backdrop-blur-sm bg-stoneground/25 border border-stoneground/30 rounded-2xl px-3 sm:px- sm:pr-7 py-1.5 sm:py-1 w-full sm:w-auto max-w-sm sm:max-w-7xl">
        <div className="flex items-center gap-3 sm:gap-6 flex-wrap justify-center">
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              className={`relative flex items-center gap-1 sm:gap-2 text-sm sm:text-base font-satoshiMedium transition-colors
                ${
                  isActive(item.href)
                    ? "text-stoneground"
                    : "text-stoneground hover:text-primary"
                }
                ${
                  item.name === "Beranda"
                    ? "bg-stoneground/40 px-2 sm:px-3 py-0.5 sm:py-1 rounded-xl"
                    : ""
                }
              `}
            >
              {/* Titik hijau dengan animasi */}
              <span
                className={`h-2 w-2 rounded-full bg-hijauDot transform transition-transform duration-300 ease-out ${
                  isActive(item.href) ? "scale-100" : "scale-0"
                }`}
                aria-hidden="true"
              />
              {item.name}
            </Link>
          ))}
        </div>
      </nav>
    </header>
  );
}

//navbar gerak
// import * as React from "react";
// import { Link, useLocation } from "react-router-dom";

// export default function Navbar() {
//   const location = useLocation();
//   const pathname = location.pathname;

//   const navigation = [
//     { name: "Dashboard", href: "/" },
//     { name: "Galeri", href: "/galeri" },
//     { name: "Informasi", href: "/informasi" },
//     { name: "Agenda", href: "/agenda" },
//   ];

//   // Refs untuk menyimpan node DOM dari item navigasi
//   const navItemRefs = React.useRef([]);

//   // State untuk menyimpan posisi dan ukuran indikator
//   const [indicatorStyle, setIndicatorStyle] = React.useState({
//     left: 0,
//     width: 0,
//   });

//   React.useEffect(() => {
//     // Menemukan indeks item aktif
//     const activeIndex = navigation.findIndex((item) => item.href === pathname);
//     const activeItemRef = navItemRefs.current[activeIndex];

//     if (activeItemRef) {
//       // Mendapatkan posisi dan lebar item aktif
//       const { offsetLeft, offsetWidth } = activeItemRef;

//       // Mengupdate gaya indikator
//       setIndicatorStyle({
//         left: offsetLeft,
//         width: offsetWidth,
//       });
//     }
//   }, [pathname, navigation]);

//   return (
//     <header className="fixed top-0 z-50 w-full flex justify-center mt-5 px-3 sm:px-0">
//       <nav className="backdrop-blur-md bg-stoneground/20 border border-stoneground/50 rounded-full px-3 sm:px-4 py-1.5 sm:py-1 w-full sm:w-auto max-w-sm sm:max-w-7xl">
//         <div className="relative flex items-center gap-3 sm:gap-6 flex-wrap justify-center">
//           {/* Indikator yang bergeser */}
//           <div
//             className="absolute bg-stoneground/30 rounded-full transition-all duration-300"
//             style={{
//               height: '100%',
//               left: indicatorStyle.left,
//               width: indicatorStyle.width,
//             }}
//           ></div>
//           {navigation.map((item, index) => (
//             <Link
//               key={item.name}
//               to={item.href}
//               ref={(el) => (navItemRefs.current[index] = el)}
//               className={`relative flex items-center gap-1 sm:gap-2 text-sm sm:text-base font-medium transition-colors
//                 ${
//                   pathname === item.href
//                     ? "text-stoneground"
//                     : "text-stoneground hover:text-primary"
//                 }
//                 px-2 sm:px-3 py-0.5 sm:py-1 rounded-full z-10
//               `}
//             >
//               {/* Green dot only for the active page */}
//               {pathname === item.href && (
//                 <span className="h-2 w-2 rounded-full bg-green-500" aria-hidden="true" />
//               )}
//               {item.name}
//             </Link>
//           ))}
//         </div>
//       </nav>
//     </header>
//   );
// }
