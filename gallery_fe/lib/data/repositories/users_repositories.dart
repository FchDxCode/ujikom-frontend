import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/users_models.dart';
import './auth_repositories.dart';
import './env.dart';

class UserRepository {
  final String apiUrl = Env.apiBaseUrl;
  final AuthRepository authRepository = AuthRepository();

  // Fetch all users (GET)
  Future<List<User>> fetchUsers() async {
    final token = await authRepository.getAccessToken();
    final response = await http.get(
      Uri.parse('$apiUrl/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> userJson = json.decode(response.body)['data'];
      return userJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Create a new user (POST)
  Future<User> createUser(User user, String password) async {
    final token = await authRepository.getAccessToken();
    final response = await http.post(
      Uri.parse('$apiUrl/register/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': user.username,
        'password': password,
        'role': user.role,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<User> updateUser(User user, String? password) async {
  final token = await authRepository.getAccessToken();
  Map<String, dynamic> body = {
    'username': user.username,
    if (user.role != null) 'role': user.role,
    if (password != null && password.isNotEmpty) 'password': password,
  };

  final response = await http.patch(
    Uri.parse('$apiUrl/users/${user.id}/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return User.fromJson(responseData['data']);
    } else {
      throw Exception('Invalid response format');
    }
  } else {
    throw Exception('Failed to update user: ${response.body}');
  }
}


  // Delete a user (DELETE)
  Future<void> deleteUser(int id) async {
    final token = await authRepository.getAccessToken();
    final response = await http.delete(
      Uri.parse('$apiUrl/users/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
