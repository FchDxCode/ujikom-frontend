import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './env.dart';

class AuthRepository {
  final storage = const FlutterSecureStorage();
  final String apiUrl = Env.apiBaseUrl;

  Future<Auth> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      jsonResponse['username'] = username;
      final auth = Auth.fromJson(jsonResponse);
      
      // Simpan token dan username ke storage
      await storage.write(key: 'access_token', value: auth.access);
      await storage.write(key: 'refresh_token', value: auth.refresh);
      await storage.write(key: 'username', value: username);
      return auth;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> logout() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      final accessToken = await storage.read(key: 'access_token');

      if (refreshToken == null || accessToken == null) {
        await storage.deleteAll();
        return;
      }

      final response = await http.post(
        Uri.parse('$apiUrl/logout/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      // Hapus token dari storage terlepas dari response
      await storage.deleteAll();

      if (response.statusCode != 200 && response.statusCode != 205) {
        print('Warning: Logout API returned status ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during logout API call: $e');
      // Tetap hapus token dari storage
      await storage.deleteAll();
    }
  }

  Future<String?> getUsername() async {
    return await storage.read(key: 'username');
  }
}