import 'package:flutter/foundation.dart';

class WebHelper {
  static void downloadPdf(Uint8List pdfData, String fileName) {
    if (kIsWeb) {
      // Web download implementation
      _downloadPdfWeb(pdfData, fileName);
    } else {
      // Mobile fallback
      throw Exception('Download not supported on mobile. Use upload instead.');
    }
  }

  static void _downloadPdfWeb(Uint8List pdfData, String fileName) {
    // This will be implemented with proper web APIs
    // For now, we'll throw an exception to indicate web download is not ready
    throw Exception('Web download functionality is being implemented. Please use mobile app for now.');
  }
} 