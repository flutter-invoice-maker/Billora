import 'dart:io';
import 'package:dio/dio.dart';

class FreeOCRApiDataSource {
  static const String baseUrl = 'https://api.ocr.space/parse/image';
  static const String apiKey = 'helloworld'; // API key công khai miễn phí
  
  Future<Map<String, dynamic>> extractText(File imageFile) async {
    final dio = Dio();
    
    FormData formData = FormData.fromMap({
      'apikey': apiKey,
      'language': 'vie',  // Tiếng Việt
      'isOverlayRequired': false,
      'detectOrientation': true,
      'isTable': true,  // Chế độ receipt scanning
      'OCREngine': 2,   // Engine mới nhất
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'bill.jpg',
      ),
    });

    try {
      final response = await dio.post(baseUrl, data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Lỗi khi gọi OCR API: $e');
    }
  }

  Future<Map<String, dynamic>> extractTextFromUrl(String imageUrl) async {
    final dio = Dio();
    
    FormData formData = FormData.fromMap({
      'apikey': apiKey,
      'language': 'vie',  // Tiếng Việt
      'isOverlayRequired': false,
      'detectOrientation': true,
      'isTable': true,  // Chế độ receipt scanning
      'OCREngine': 2,   // Engine mới nhất
      'url': imageUrl,  // URL của ảnh
    });

    try {
      final response = await dio.post(baseUrl, data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Lỗi khi gọi OCR API từ URL: $e');
    }
  }

  String parseOCRSpaceResponse(Map<String, dynamic> response) {
    try {
      final parsedResults = response['ParsedResults'] as List;
      if (parsedResults.isNotEmpty) {
        return parsedResults[0]['ParsedText'] as String;
      }
    } catch (e) {
      // Handle OCR.Space response parsing error
    }
    return '';
  }
} 