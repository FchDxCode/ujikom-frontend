import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/page_models.dart';
import '../models/contentblock_models.dart';
import './env.dart';

// Pindahkan ServerException ke luar class
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class LogoRepository {
  final String baseUrl = Env.apiBaseUrl;
  static const timeoutDuration = Duration(seconds: 3);

  Future<http.Response> _safeGetRequest(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeoutDuration);
      
      return response;
    } on SocketException {
      throw ServerException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ServerException('Koneksi timeout');
    } on http.ClientException {
      throw ServerException('Gagal terhubung ke server');
    } catch (e) {
      throw ServerException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fetch logo page dengan error handling yang lebih baik
  Future<PageModel?> fetchLogoPage() async {
    try {
      final response = await _safeGetRequest('/contentblocks/page/slug/logo-flutter/');

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body)['data'];
        if (dataList.isNotEmpty) {
          return PageModel.fromJson(dataList.first);
        }
      } else if (response.statusCode >= 500) {
        throw ServerException('Server sedang mengalami gangguan');
      } else if (response.statusCode == 404) {
        throw ServerException('Data tidak ditemukan');
      } else {
        throw ServerException('Terjadi kesalahan: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      if (e is ServerException) {
        print('Server Error: ${e.message}');
      } else {
        print('Error fetching logo page: $e');
      }
      return null;
    }
  }

  // Fetch logo content blocks dengan error handling yang lebih baik
  Future<List<ContentBlockModel>> fetchLogoContent() async {
    try {
      final response = await _safeGetRequest('/contentblocks/page/slug/logo-flutter/');

      if (response.statusCode == 200) {
        final List<dynamic> contentJson = json.decode(response.body)['data'];
        return contentJson.map((json) {
          if (json['image'] == null) {
            json['image'] = '';
          }
          return ContentBlockModel.fromJson(json);
        }).toList();
      }
      
      // Handle error status codes tanpa throw
      if (response.statusCode >= 500) {
        print('Server Error: Server sedang mengalami gangguan');
      } else if (response.statusCode == 404) {
        print('Server Error: Data tidak ditemukan');
      } else {
        print('Server Error: Terjadi kesalahan ${response.statusCode}');
      }
      return [];
      
    } catch (e) {
      if (e is ServerException) {
        print('Server Error: ${e.message}');
      } else {
        print('Error fetching logo content: $e');
      }
      return [];
    }
  }
}
