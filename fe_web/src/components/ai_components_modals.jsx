import React, { useState, useRef, useEffect, useCallback } from 'react';
import { FaTimes, FaPaperPlane } from 'react-icons/fa';
import { Link } from 'react-router-dom';
import { assistantApi } from '../service/assistant_api';
import { motion, AnimatePresence } from 'framer-motion';
import StatusHandler from './statusHandler';
import { Loader2 } from 'lucide-react'; // Untuk spinner loading

const AIModal = ({ isOpen, onClose }) => {
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null); // Untuk status error
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    if (isOpen && messages.length === 0) {
      setMessages([{
        text: "Hai! Saya Cerbi, asisten yang akan membantu kamu menjelajahi galeri foto ini. Kamu bisa tanya tentang foto-foto populer atau informasi tentang website ini. Atau mungkin kita bisa ngobrol santai juga! 😊",
        isUser: false
      }]);
    }
  }, [isOpen, messages.length]);

  const handleAIResponse = useCallback(async (userMessage = '') => {
    try {
      setIsLoading(true);
      setError(null); // Reset error sebelumnya
      const aiResponse = await assistantApi.sendMessage(userMessage);
      
      if (aiResponse) {
        setMessages(prev => [...prev, 
          { text: userMessage, isUser: true },
          { 
            text: aiResponse.text, 
            isUser: false, 
            isDynamic: aiResponse.isDynamic 
          }
        ]);
      }
    } catch (error) {
      console.error('Error getting AI response:', error);
      setMessages(prev => [...prev,
        { text: userMessage, isUser: true },
        { 
          text: 'Maaf, terjadi kesalahan. Silakan coba lagi nanti ya! 😅', 
          isUser: false 
        }
      ]);
      setError('Terjadi kesalahan!'); // Set status error
    } finally {
      setIsLoading(false);
      if (error) {
        setTimeout(() => setError(null), 3000); // Reset error setelah 3 detik
      }
    }
  }, [error]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!inputMessage.trim()) return;

    const message = inputMessage;
    setInputMessage('');
    await handleAIResponse(message);
  };

  const renderDynamicContent = (content) => {
    if (!content || (!content.text && !content.intro)) return content;
    
    return (
      <div>
        {content.intro && <p className="mb-2">{content.intro}</p>}
        {Array.isArray(content.text) && content.text.map((item, index) => (
          <div key={index} className="mb-2">
            <Link 
              to={`/ai/photo/${item.category.slug}/${item.album.slug}/${item.slug}`}
              className="text-blue-500 hover:text-blue-700 hover:underline"
              onClick={onClose}
              target="_blank"
              rel="noopener noreferrer"
            >
              {`${index + 1}. ${item.text}`}
            </Link>
          </div>
        ))}
        {content.outro && <p className="mt-2">{content.outro}</p>}
      </div>
    );
  };

  const modalVariants = {
    hidden: { opacity: 0, y: '-100%' },
    visible: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: '100%' }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div 
          className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50 p-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="bg-white rounded-2xl w-full max-w-lg flex flex-col h-[80vh] shadow-xl relative overflow-hidden"
            variants={modalVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
            transition={{ type: 'spring', stiffness: 300, damping: 30 }}
          >
            {/* Header */}
            <div className="p-4 border-b flex justify-between items-center bg-blue-600 text-white">
              <h2 className="text-xl font-semibold">AI Assistant</h2>
              <button
                onClick={onClose}
                className="text-white hover:text-gray-200 focus:outline-none"
              >
                <FaTimes size={20} />
              </button>
            </div>

            {/* Status Handler - Hanya tampil saat terjadi error */}
            {error && (
              <div className="absolute top-0 left-0 right-0">
                <StatusHandler 
                  status="error" 
                  message={error} 
                />
              </div>
            )}

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
              {messages.map((message, index) => (
                <motion.div
                  key={index}
                  className={`flex ${message.isUser ? 'justify-end' : 'justify-start'}`}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: index * 0.05 }}
                >
                  <div
                    className={`max-w-[80%] p-3 rounded-lg shadow-md ${
                      message.isUser
                        ? 'bg-blue-500 text-white rounded-br-none'
                        : 'bg-gray-200 text-gray-800 rounded-bl-none'
                    }`}
                  >
                    {message.isDynamic 
                      ? renderDynamicContent(message.text)
                      : message.text
                    }
                  </div>
                </motion.div>
              ))}
              <div ref={messagesEndRef} />
            </div>

            {/* Input */}
            <form onSubmit={handleSubmit} className="p-4 border-t bg-white">
              <div className="flex space-x-2">
                <input
                  type="text"
                  value={inputMessage}
                  onChange={(e) => setInputMessage(e.target.value)}
                  placeholder="Tanyakan tentang foto populer..."
                  className="flex-1 p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  disabled={isLoading}
                />
                <button
                  type="submit"
                  className="bg-blue-500 text-white p-2 rounded-lg hover:bg-blue-600 disabled:bg-gray-400 flex items-center justify-center transition-colors"
                  disabled={isLoading || !inputMessage.trim()}
                >
                  {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : <FaPaperPlane />}
                </button>
              </div>
            </form>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default AIModal;
