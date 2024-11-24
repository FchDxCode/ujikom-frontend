// category_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_models.dart';
import '../repositories/auth_repositories.dart';
import './env.dart';

class CategoryRepository {
  final String apiUrl = '${Env.apiBaseUrl}/categories/';
  final AuthRepository authRepository = AuthRepository();

  // Fetch all categories (GET)
  Future<List<Category>> fetchCategories() async {
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
      print('Response Body: $responseBody'); // Tambahkan logging di sini
      final List<dynamic> categoryJson = json.decode(responseBody)['data'];

      return categoryJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<int, String>> getCategoryAlbums() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> categoryJson = json.decode(response.body)['data'];
      return {
        for (var category in categoryJson) category['id']: category['title']
      };
    } else {
      throw Exception('Failed to load category by albums');
    }
  }

  // Create a new category (POST)
  Future<Category> createCategory(Category category) async {
    final token = await authRepository.getAccessToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': category.name,
        'description': category.description,
      }),
    );

    if (response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to create category');
    }
  }

  // Update an existing category (PATCH)
  Future<Category> updateCategory(Category category) async {
    final token = await authRepository.getAccessToken();
    final response = await http.patch(
      Uri.parse('$apiUrl${category.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': category.name,
        'description': category.description,
      }),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to update category');
    }
  }

  // Delete a category (DELETE)
  Future<void> deleteCategory(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
