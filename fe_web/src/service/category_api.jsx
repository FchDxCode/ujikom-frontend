import axios from 'axios';
import { API_BASE_URL } from './config';

export const categoryAPI = {
  // Get all public categories
  getPublicCategories: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/categories/public/`);
      return {
        status: "success",
        data: response.data.data || []
      };
    } catch (error) {
      console.error("Error fetching public categories:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat kategori",
        data: []
      };
    }
  },

  // Get category by ID
  getCategoryById: async (id) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/categories/public/${id}/`);
      return {
        status: "success",
        data: response.data.data
      };
    } catch (error) {
      console.error("Error fetching category:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat detail kategori",
        data: null
      };
    }
  }
};
