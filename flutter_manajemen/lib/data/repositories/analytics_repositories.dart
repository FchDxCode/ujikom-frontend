import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analytics_models.dart';
import '../repositories/auth_repositories.dart';
import './env.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../../service/web_download_helper.dart'
    if (dart.library.io) '../../service/io_download_helper.dart';

class AnalyticsRepository {
  final String apiUrl = '${Env.apiBaseUrl}/analytics/';
  final AuthRepository authRepository = AuthRepository();

  Future<AnalyticsStats> getAnalyticsStats({int days = 30}) async {
    try {
      final token = await authRepository.getAccessToken();

      final url = Uri.parse('${apiUrl}stats/').replace(
        queryParameters: {'days': days.toString()},
      );

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final decodedJson = json.decode(responseBody);

        return AnalyticsStats.fromJson(decodedJson);
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('Not authorized to access analytics');
      } else {
        throw AnalyticsException(
          'Failed to fetch analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw AnalyticsException('Unexpected error: $e');
    }
  }

  Future<List<AnalyticsArchive>> getArchives() async {
    try {
      final token = await authRepository.getAccessToken();
      final url = Uri.parse('${apiUrl}archives/');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> archiveList =
            json.decode(response.body)['archives'];
        return archiveList
            .map((json) => AnalyticsArchive.fromJson(json))
            .toList();
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('Not authorized to access archives');
      } else {
        throw AnalyticsException('Failed to fetch archives');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw AnalyticsException('Unexpected error: $e');
    }
  }

  Future<void> downloadArchive(String filename) async {
    try {
      final token = await authRepository.getAccessToken();
      final url = Uri.parse('${apiUrl}archives/$filename/');

      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web implementation
          downloadFileWeb(response.bodyBytes, filename);
          return;
        } else {
          try {
            String? filePath;

            if (Platform.isWindows) {
              // Windows implementation
              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Pilih lokasi untuk menyimpan file',
                fileName: filename,
                type: FileType.custom,
                allowedExtensions: ['csv'],
              );

              filePath = outputFile;
            } else if (Platform.isAndroid) {
              var status = await Permission.storage.status;
              if (!status.isGranted) {
                status = await Permission.storage.request();
                if (!status.isGranted) {
                  throw AnalyticsException('Storage permission denied');
                }
              }
              final directory = await getExternalStorageDirectory();
              filePath = '${directory!.path}/$filename';
            } else if (Platform.isIOS) {
              // iOS implementation
              final directory = await getApplicationDocumentsDirectory();
              filePath = '${directory.path}/$filename';
            }
            if (filePath != null) {
              final file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);

              if (await file.exists()) {
                await OpenFile.open(filePath);
                return;
              }
            }
          } catch (e) {
            throw AnalyticsException('Error saving file: $e');
          }
        }
      } else if (response.statusCode == 404) {
        throw AnalyticsException('File not found');
      } else {
        throw AnalyticsException('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      throw AnalyticsException('Error downloading archive: $e');
    }
  }
}

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
