import axios from 'axios';
import { API_BASE_URL } from './config';

export const pageAPI = {
  getPublicPages: async () => {
    const response = await axios.get(`${API_BASE_URL}/pages/public/`);
    return response.data;
  },

  getPageBySlug: async (slug) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/pages/public/${slug}/`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};
