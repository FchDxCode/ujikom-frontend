import React, { useState } from "react";
import Viewer from "react-viewer";

const ReactViewerComponent = ({ images }) => {
  const [visible, setVisible] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);

  const handleDownload = (imageSrc) => {
    const link = document.createElement("a");
    link.href = imageSrc;
    link.download = `image-${activeIndex + 1}.jpg`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="gallery-container">
      {/* Thumbnail List */}
      <div className="image-thumbnails flex flex-wrap gap-4">
        {images.map((image, index) => (
          <img
            key={index}
            src={image.src}
            alt={image.alt || `Image ${index + 1}`}
            className="thumbnail w-32 h-32 object-cover rounded-lg cursor-pointer"
            onClick={() => {
              setActiveIndex(index);
              setVisible(true);
            }}
          />
        ))}
      </div>

      {/* Viewer */}
      <Viewer
        visible={visible}
        onClose={() => setVisible(false)}
        images={images}
        activeIndex={activeIndex}
        onChange={(newIndex) => setActiveIndex(newIndex)}
        zoomable={true}
        rotatable={true}
        scalable={true}
        drag={true}
        customToolbar={(config) => [
          ...config,
          {
            key: "download",
            render: <span>⤓ Download</span>,
            onClick: () => handleDownload(images[activeIndex].src),
          },
        ]}
      />
    </div>
  );
};

export default ReactViewerComponent;
