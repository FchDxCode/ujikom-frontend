import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import ScrollReveal from "scrollreveal";
import Card from "./card_only";
import { FaSearch } from "react-icons/fa";

const CardContainer = ({
  data = [],
  emptyMessage = "Tidak ada informasi yang tersedia.",
  dropdownOptions = [
    { label: "Terbaru", value: "terbaru" },
    { label: "Terlama", value: "terlama" },
    { label: "Terpopuler", value: "terpopuler" },
  ],
  buttonLabel = "Filter",
  showProfile = true,
  onCardClick,
  CardComponent = Card,
  onLikeClick,
}) => {
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortOrder, setSortOrder] = useState(dropdownOptions[0]?.value || "");
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const containerRef = useRef(null);
  const [currentLabel, setCurrentLabel] = useState(buttonLabel);

  useEffect(() => {
    const container = containerRef.current;

    if (!container) return;

    const sr = ScrollReveal({
      origin: "bottom",
      distance: "50px",
      duration: 800,
      delay: 100,
      easing: "ease-in-out",
      reset: true,
      container,
    });

    sr.reveal(".card-item");

    return () => sr.destroy();
  }, []);

  const filteredAndSortedData = data
    .filter((item) => {
      const title = item?.title?.toLowerCase() || "";
      const description = item?.description?.toLowerCase() || "";
      const query = searchQuery.toLowerCase();

      return title.includes(query) || description.includes(query);
    })
    .sort((a, b) => {
      if (sortOrder === "terbaru") {
        return new Date(b?.updated_at || 0) - new Date(a?.updated_at || 0);
      } else if (sortOrder === "terlama") {
        return new Date(a?.updated_at || 0) - new Date(b?.updated_at || 0);
      } else if (sortOrder === "terpopuler") {
        return (b?.popularity || 0) - (a?.popularity || 0); 
      }
      return 0;
    });

  return (
    <div className="p-4 bg-grayBg1/50 rounded-[1.5rem] scroll-smooth">
      <div className="sticky top-0 z-20 p-4 rounded-t-[1.5rem]">
        <div className="flex flex-col sm:flex-row sm:items-center gap-2">
          <div className="relative">
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="px-4 md-px-4 py-2 bg-grayBg3 border-2 border-grayBg2 text-mushorom font-poppinsMedium text-sm rounded-xl focus:outline-none hover:border-stoneground/45 duration-300"
            >
              <div className="flex items-center justify-between w-[5rem] md:min-w-[120px]">
                <span>{currentLabel}</span>
                <span
                  className="ml-2 transform transition-transform duration-500"
                  style={{
                    transform: isDropdownOpen ? "rotate(0deg)" : "rotate(180deg)",
                  }}
                >
                  ▼
                </span>
              </div>
            </button>
            <AnimatePresence>
              {isDropdownOpen && (
                <motion.div
                  initial={{ opacity: 0, y: -3 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -3 }}
                  transition={{ duration: 0.2 }}
                  className="absolute mt-2 text-sm w-full bg-grayBg3 text-cerramic rounded-lg font-poppinsMedium z-10"
                >
                  <ul>
                    {dropdownOptions.map((option) => (
                      <li
                        key={option.value}
                        onClick={() => {
                          setSortOrder(option.value);
                          setCurrentLabel(option.label);
                          setIsDropdownOpen(false);
                        }}
                        className="px-4 py-2 cursor-pointer hover:bg-stoneground/20"
                      >
                        {option.label}
                      </li>
                    ))}
                  </ul>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          <div className="flex items-center w-full sm:w-auto">
            <button
              onClick={() => setIsSearchActive(!isSearchActive)}
              className="p-3 bg-grayBg3 border-2 border-grayBg2 text-mushorom rounded-full transition-all focus:outline-none hover:border-stoneground/50 duration-300"
            >
              <FaSearch className="text-stoneground/50 hover:text-mushorom" />
            </button>
            <AnimatePresence>
              {isSearchActive && (
                <motion.input
                  type="text"
                  placeholder="Cari berdasarkan nama"
                  initial={{ width: 0, opacity: 0 }}
                  animate={{
                    width: window.innerWidth < 768 ? "100%" : "300px",
                    opacity: 1,
                  }}
                  exit={{ width: 0, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                  className="ml-2 px-4 py-2 bg-grayBg3 border-2 border-grayBg2 text-stoneground rounded-full placeholder-cerramic focus:outline-none"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      <div
        className="overflow-auto max-h-[80vh] no-scrollbar p-4"
        ref={containerRef}
      >
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 place-items-center">
          {filteredAndSortedData.map((item, index) => (
            <div
              key={item?.id || index}
              className="w-full max-w-[384px] card-item"
            >
              <CardComponent
                data={item}
                showProfile={showProfile}
                onClick={() => onCardClick && onCardClick(item)}
                onLikeClick={() => onLikeClick && onLikeClick(item)}
              />
            </div>
          ))}
        </div>

        {filteredAndSortedData.length === 0 && (
          <div className="text-center text-gray-500 mt-8">{emptyMessage}</div>
        )}
      </div>
    </div>
  );
};

export default CardContainer;
