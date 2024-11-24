import axios from 'axios';
import { API_BASE_URL, MEDIA_BASE_URL } from './config';

export const albumAPI = {
  // Get all public albums
  getPublicAlbums: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/albums/public/`);
      return {
        status: "success",
        data: response.data.data || []
      };
    } catch (error) {
      console.error("Error fetching public albums:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat album",
        data: []
      };
    }
  },

  // Get albums by category
  getAlbumsByCategory: async (categorySlug) => {
    try {
      const categoryId = localStorage.getItem('category_id');
      const response = await axios.get(`${API_BASE_URL}/albums/category/${categoryId}/`);
      
      // Transform data menggunakan MEDIA_BASE_URL untuk gambar
      const transformedData = response.data.data.map(album => ({
        ...album,
        cover_photo_url: album.cover_photo_url ? `${MEDIA_BASE_URL}${album.cover_photo_url}` : null
      }));

      return {
        status: "success",
        data: transformedData || []
      };
    } catch (error) {
      console.error("Error fetching albums by category:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat album untuk kategori ini",
        data: []
      };
    }
  }
};
