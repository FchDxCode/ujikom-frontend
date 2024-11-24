import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';
  
  static String get baseUrl => apiBaseUrl.replaceAll('/api', '');
  
  static String getMediaUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) {
      return path;
    }
    return '$baseUrl$path';
  }
}
