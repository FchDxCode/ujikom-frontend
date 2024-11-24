import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/contentblock_models.dart';
import '../repositories/auth_repositories.dart';
import './env.dart';

class ContentBlockRepository {
  final String apiUrl = '${Env.apiBaseUrl}/contentblocks/';
  final AuthRepository authRepository = AuthRepository();

  // Fetch all content blocks (GET)
  Future<List<ContentBlockModel>> fetchContentBlocks() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> contentBlockJson = responseData['data'];
        return contentBlockJson.map((json) {
          if (json['image'] == null) {
            json['image'] = '';
          }
          return ContentBlockModel.fromJson(json);
        }).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load content blocks: ${response.body}');
    }
  }

  Future<ContentBlockModel> createContentBlock(
      ContentBlockModel contentBlock, dynamic imageFile) async {
    final token = await authRepository.getAccessToken();
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    
    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['title'] = contentBlock.title;
    request.fields['description'] = contentBlock.description ?? '';
    request.fields['page'] = contentBlock.page.toString();

    // Handle image file
    try {
      if (imageFile != null) {
        if (imageFile is http.MultipartFile) {
          request.files.add(imageFile);
        }
      }

      // Send request and get response
      var streamedResponse = await request.send();
      var responseData = await http.Response.fromStream(streamedResponse);
      
      if (responseData.statusCode == 201 || responseData.statusCode == 200) {
        final responseJson = json.decode(responseData.body);
        if (responseJson['status'] == 'success' && responseJson['data'] != null) {
          // Ensure image field is not null
          if (responseJson['data']['image'] == null) {
            responseJson['data']['image'] = '';
          }
          return ContentBlockModel.fromJson(responseJson['data']);
        }
      }
      
      // Handle error responses
      throw Exception(
        'Failed to create content block: ${responseData.statusCode} - ${responseData.body}'
      );
    } catch (e) {
      throw Exception('Failed to create content block: $e');
    }
  }

  // Update an existing content block (PATCH)
  Future<ContentBlockModel> updateContentBlock(
    ContentBlockModel contentBlock, {
    dynamic imageFile,
  }) async {
    final token = await authRepository.getAccessToken();
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$apiUrl${contentBlock.id}/'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add text fields
    request.fields['title'] = contentBlock.title;
    request.fields['description'] = contentBlock.description ?? '';
    request.fields['page'] = contentBlock.page.toString();

    // Only add image file if new image is selected
    if (imageFile != null) {
      if (imageFile is http.MultipartFile) {
        request.files.add(imageFile);
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          // Ensure image field is not null
          if (responseData['data']['image'] == null) {
            responseData['data']['image'] = '';
          }
          return ContentBlockModel.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      }

      // Log error response for debugging
      
      
      throw Exception('Failed to update content block: ${response.statusCode} - ${response.reasonPhrase}');
    } catch (e) {
      throw Exception('Failed to update content block: $e');
    }
  }

  // Delete a content block (DELETE)
  Future<void> deleteContentBlock(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      // Delete berhasil, tidak ada data yang dikembalikan
      return;
    } else {
      throw Exception('Failed to delete content block');
    }
  }

  Future<List<ContentBlockModel>> fetchContentBlocksByPage(int pageId) async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse('${apiUrl}page/$pageId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> contentBlockJson = responseData['data'];
        return contentBlockJson.map((json) {
          if (json['image'] == null) {
            json['image'] = '';
          }
          return ContentBlockModel.fromJson(json);
        }).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load content blocks by page: ${response.body}');
    }
  }
}
