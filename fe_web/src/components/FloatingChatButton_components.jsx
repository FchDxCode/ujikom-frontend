// fe_web/src/components/FloatingChatButton.jsx
import React, { useState } from 'react';
import { FiMessageCircle } from 'react-icons/fi'; // Import ikon
import AIChatModal from './ai_components_modals';

const FloatingChatButton = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <button
        data-testid="float-chat-btn"
        onClick={() => setIsModalOpen(true)}
        className="fixed bottom-6 right-6 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-full p-4 shadow-2xl hover:shadow-xl hover:from-purple-500 hover:to-blue-500 transition-all z-30 group"
      >
        <div className="relative">
          {/* React Icon */}
          <FiMessageCircle className="w-8 h-8 group-hover:scale-110 transition-transform" />
          {/* Hover Tooltip */}
          <span className="absolute bottom-full mb-2 left-1/2 transform -translate-x-1/2 bg-gradient-to-r from-gray-800 to-gray-900 text-white text-sm py-2 px-3 rounded-lg shadow-lg opacity-0 group-hover:opacity-100 group-hover:translate-y-[-10px] transition-all duration-300 ease-in-out z-40">
            Chat with Cerby
          </span>
        </div>
      </button>

      <AIChatModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
      />
    </>
  );
};

export default FloatingChatButton;
