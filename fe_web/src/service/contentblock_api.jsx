import axios from 'axios';
import { API_BASE_URL } from './config';

export const contentBlockAPI = {
  // Get all public content blocks
  getPublicContentBlocks: async () => {
    const response = await axios.get(`${API_BASE_URL}/contentblocks/public/`);
    return response.data;
  },

  // Get content blocks by page ID
  getContentBlocksByPage: async (pageId) => {
    const response = await axios.get(`${API_BASE_URL}/contentblocks/page/${pageId}/`);
    return response.data;
  },

  // Get content blocks by page slug
  getContentBlocksByPageSlug: async (pageSlug) => {
    const response = await axios.get(`${API_BASE_URL}/contentblocks/page/slug/${pageSlug}/`);
    return response.data;
  },

  // Get single content block by ID
  getContentBlockById: async (id) => {
    const response = await axios.get(`${API_BASE_URL}/contentblocks/detail/${id}/`);
    return response.data;
  },

  // Update method untuk get content block detail by ID
  getContentBlockDetail: async (id) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/contentblocks/detail/${id}/`);
      if (response.data.status === "success") {
        return {
          status: "success",
          data: response.data.data
        };
      } else {
        return {
          status: "error",
          message: response.data.message || "Gagal memuat detail agenda",
          data: null
        };
      }
    } catch (error) {
      console.error("Error fetching content block detail:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat detail agenda",
        data: null
      };
    }
  }
};
