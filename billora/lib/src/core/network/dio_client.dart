// Đảm bảo đã thêm vào pubspec.yaml: dio: ^5.0.0 hoặc mới hơn
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }

  // Thêm các phương thức request nếu cần
} 