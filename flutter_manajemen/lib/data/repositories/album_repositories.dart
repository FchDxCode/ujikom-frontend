//album_repository
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/album_models.dart';
import '../repositories/auth_repositories.dart';
import './env.dart';

class AlbumRepository {
  final String apiUrl = '${Env.apiBaseUrl}/albums/';
  final AuthRepository authRepository = AuthRepository();

  // Fetch all albums (GET)
  Future<List<Album>> fetchAlbums() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> albumJson = json.decode(response.body)['data'];
      return albumJson.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  Future<Map<int, String>> getAlbumPhotos() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> albumJson = json.decode(response.body)['data'];
      return {for (var album in albumJson) album['id']: album['title']};
    } else {
      throw Exception('Failed to load albums');
    }
  }

  // Create a new album (POST)
  Future<Album> createAlbum(Album album) async {
    final token = await authRepository.getAccessToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': album.title,
        'description': album.description,
        'category': album.category,
        'is_active': album.isActive,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Album.fromJson(responseData);
    } else {
      throw Exception('Failed to create album');
    }
  }

  // Update an existing album (PATCH)
  Future<Album> updateAlbum(Album album) async {
    final token = await authRepository.getAccessToken();
    final response = await http.patch(
      Uri.parse('$apiUrl${album.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': album.title,
        'description': album.description,
        'category':
            album.category, // Tidak akan null karena ada default di model
        'is_active': album.isActive, // Tidak akan null
        'sequence_number':
            album.sequenceNumber, // Tidak akan null karena ada default di model
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Album.fromJson(responseData);
    } else {
      throw Exception('Failed to update album');
    }
  }

  // Delete an album (DELETE)
  Future<void> deleteAlbum(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete album');
    }
  }

  Future<List<Album>> fetchAlbumsByCategory(int categoryId) async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse('${apiUrl}category/$categoryId/'), // Removed the space
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> albumJson = json.decode(response.body)['data'];
      return albumJson.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums by category');
    }
  }
}
