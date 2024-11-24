// fe_web/src/service/assistant_api.jsx
import axios from 'axios';
import { API_BASE_URL } from './config';

export const assistantApi = {
  // Kirim pesan ke AI Assistant
  sendMessage: async (message) => {
    try {
      console.log('Sending message:', message); // Debug log
      const response = await axios.post(`${API_BASE_URL}/assistant/public-chat/`, {
        question: message
      }, {
        headers: {
          'Content-Type': 'application/json',
        },
        withCredentials: true // Penting untuk session
      });
      console.log('Response:', response.data); // Debug log
      return response.data;
    } catch (error) {
      console.error('API Error:', error.response || error); // Better error logging
      throw error;
    }
  },

  // Ambil history chat
  getChatHistory: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/assistant/public-chat/`, {
        withCredentials: true // Penting untuk session
      });
      return response.data;
    } catch (error) {
      console.error('History Error:', error.response || error);
      throw error;
    }
  }
};