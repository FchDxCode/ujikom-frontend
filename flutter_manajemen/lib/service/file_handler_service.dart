import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FileHandlerService {
  static Future<http.MultipartFile> handleFileUpload(XFile pickedFile) async {
    if (kIsWeb) {
      // Handle web
      final bytes = await pickedFile.readAsBytes();
      return http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: pickedFile.name,
      );
    } else {
      // Handle mobile/desktop
      return http.MultipartFile.fromPath(
        'photo',
        pickedFile.path,
      );
    }
  }

  static Future<dynamic> getImagePreview(XFile? file) async {
    if (file == null) return null;
    
    if (kIsWeb) {
      return await file.readAsBytes();
    } else {
      return File(file.path);
    }
  }
}