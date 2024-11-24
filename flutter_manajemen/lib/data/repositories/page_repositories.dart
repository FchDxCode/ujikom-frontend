import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/page_models.dart';
import 'auth_repositories.dart';
import './env.dart';

class PageRepository {
  final String apiUrl = '${Env.apiBaseUrl}/pages/';
  final AuthRepository authRepository = AuthRepository();

  // Fetch all pages (GET)
  Future<List<PageModel>> fetchPages() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> pageJson = json.decode(response.body)['data'];
      return pageJson.map((json) => PageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pages');
    }
  }

  // Create a new page (POST)
  Future<PageModel> createPage(PageModel page) async {
    final token = await authRepository.getAccessToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': page.title,
        'content': page.content,
        'is_active': page.isActive,
      }),
    );

    if (response.statusCode == 201) {
      return PageModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to create page');
    }
  }

  // Update an existing page (PATCH)
  Future<PageModel> updatePage(PageModel page) async {
    final token = await authRepository.getAccessToken();
    final response = await http.patch(
      Uri.parse('$apiUrl${page.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': page.title,
        'content': page.content,
        'is_active': page.isActive
      }),
    );

    if (response.statusCode == 200) {
      return PageModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to update page');
    }
  }

  // Delete a page (DELETE)
  Future<void> deletePage(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete page');
    }
  }
}
