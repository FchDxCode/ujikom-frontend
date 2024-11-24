import React from "react";

const AgendaCard = ({ title, image }) => {
  return (
    <div className="relative overflow-hidden rounded-2xl aspect-[4/3] shadow-lg">
      <img
        src={image}
        alt={title}
        className="w-full h-full object-cover"
        loading="lazy"
      />
      <div className="absolute inset-0 bg-gradient-to-b from-black/80 to-transparent"></div>
      <div className="absolute top-0 left-0 p-4">
        <h2 className="text-stoneground/85 text-xl line-clamp-2 font-satoshiBold">{title}</h2>
      </div>
      <div className="absolute bottom-0 right-0 p-4">
        <button className="px-4 py-2 bg-shadow/20 backdrop-blur-md font-satoshiMedium text-stoneground rounded-md border border-stoneground/40 hover:bg-shadow/50 transition">
          Detail Agenda
        </button>
      </div>
    </div>
  );
};

export default AgendaCard;
