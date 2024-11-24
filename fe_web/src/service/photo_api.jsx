import axios from 'axios';
import { API_BASE_URL } from './config';

export const photoAPI = {
  // Get all public photos
  getPublicPhotos: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/photos/public/`);
      return {
        status: "success",
        data: response.data.data || []
      };
    } catch (error) {
      console.error("Error fetching public photos:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat foto",
        data: []
      };
    }
  },

  // Get photos by album ID
  getPhotosByAlbum: async (albumId) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/photos/album/${albumId}/`);
      return {
        status: "success",
        data: response.data.data || []
      };
    } catch (error) {
      console.error("Error fetching photos by album:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat foto album",
        data: []
      };
    }
  },

  likePhoto: async (photoId, action) => {
    try {
      const response = await axios.post(
        `${API_BASE_URL}/photos/${photoId}/like/`,
        { action }  // Send the action in the request body
      );
      return {
        status: "success",
        data: {
          likes: response.data.likes,
          action: response.data.action
        }
      };
    } catch (error) {
      console.error("Error toggling like:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Failed to toggle like status",
        data: null
      };
    }
  },

  // Update method untuk get photo detail menggunakan endpoint public
  getPhotoDetail: async (photoId) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/photos/public/${photoId}/`);
      return {
        status: response.data.status,
        data: response.data.data
      };
    } catch (error) {
      console.error("Error fetching photo detail:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat detail foto",
        data: null
      };
    }
  },

  getAlbumDetail: async (albumId) => {
    try {
      const response = await axios.get(`${API_BASE_URL}/albums/${albumId}/`);
      return {
        status: "success",
        data: response.data.data
      };
    } catch (error) {
      console.error("Error fetching album detail:", error);
      return {
        status: "error",
        message: error.response?.data?.message || "Gagal memuat detail album",
        data: null
      };
    }
  },

  // Mendapatkan foto dengan like terbanyak
  getPopularPhotos: async () => {
    try {
      const response = await photoAPI.getPublicPhotos();
      if (response.status === "success") {
        const sortedPhotos = response.data
          .sort((a, b) => (b.likes || 0) - (a.likes || 0))
          .slice(0, 5)
          .map(photo => ({
            ...photo,
            type: 'photo',
            likes: photo.likes || 0,
            categorySlug: photo.category_slug,
            albumSlug: photo.album_slug,
            photoSlug: photo.slug
          }));
        
        return {
          status: "success",
          data: sortedPhotos
        };
      }
      return response;
    } catch (error) {
      console.error("Error getting popular photos:", error);
      return {
        status: "error",
        message: error.message || "Gagal memuat foto populer",
        data: []
      };
    }
  }
};
