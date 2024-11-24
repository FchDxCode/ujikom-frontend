import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/photo_models.dart';
import '../repositories/auth_repositories.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan ini
import 'package:http_parser/http_parser.dart';
import './env.dart';

class PhotoRepository {
  final String apiUrl = '${Env.apiBaseUrl}/photos/';
  final AuthRepository authRepository = AuthRepository();

  // Fetch all photos (GET)
  Future<List<Photo>> fetchPhotos() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;

      final List<dynamic> photoJson = json.decode(responseBody)['data'];
      return photoJson.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<List<Photo>> fetchPhotosByAlbum(int albumId) async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> photoJson = json.decode(response.body)['data'];
      return photoJson.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos by album: ${response.body}');
    }
  }

  // Create a new photo (POST)
  Future<Photo> createPhoto(Photo photo, XFile imageFile) async {
    final token = await authRepository.getAccessToken();
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = photo.title ?? 'No Title';
    request.fields['description'] = photo.description ?? 'No Description';
    request.fields['album'] = photo.album.toString();

    final bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'photos',
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', imageFile.name.split('.').last),
      ),
    );

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseData = await http.Response.fromStream(response);
      final jsonResponse = json.decode(responseData.body);
      final photoData = jsonResponse['data'][0];
      return Photo.fromJson(photoData);
    } else {
      var responseData = await http.Response.fromStream(response);
      print('Error response: ${responseData.body}');
      throw Exception('Failed to create photo: ${responseData.statusCode}');
    }
  }

  // Update an existing photo (PATCH)
  Future<Photo> updatePhoto(Photo photo, {XFile? imageFile}) async {
    final token = await authRepository.getAccessToken();
    var request = http.MultipartRequest('PATCH', Uri.parse('$apiUrl${photo.id}/'));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = photo.title ?? '';
    request.fields['description'] = photo.description ?? '';
    request.fields['album'] = photo.album.toString();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', imageFile.name.split('.').last),
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      final jsonResponse = json.decode(responseData.body);

      // Extract the data from response
      final photoData = jsonResponse['data'] is List
          ? jsonResponse['data'][0]
          : jsonResponse['data'];

      return Photo.fromJson(photoData);
    } else {
      var responseData = await http.Response.fromStream(response);
      print('Error response: ${responseData.body}');
      throw Exception('Failed to update photo: ${response.statusCode}');
    }
  }

  // Delete a photo (DELETE)
  Future<void> deletePhoto(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete photo');
    }
  }
}
