import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';
import '../repositories/auth_repositories.dart';
import './env.dart';

class DashboardRepository {
  final String apiUrl = '${Env.apiBaseUrl}/dashboard/';
  final AuthRepository authRepository = AuthRepository();

  Future<DashboardStats> getDashboardStats({bool refresh = false}) async {
    try {
      final token = await authRepository.getAccessToken();
      final response = await http.get(
        Uri.parse('${apiUrl}stats/').replace(
          queryParameters: {'refresh': refresh.toString()},
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Dashboard Response Body: $responseBody'); // Untuk debugging
        return DashboardStats.fromJson(json.decode(responseBody));
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('Not authorized to access dashboard');
      } else {
        throw DashboardException(
          'Failed to fetch dashboard stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw DashboardException('Unexpected error: $e');
    }
  }
}

// Custom exceptions
class DashboardException implements Exception {
  final String message;
  DashboardException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
