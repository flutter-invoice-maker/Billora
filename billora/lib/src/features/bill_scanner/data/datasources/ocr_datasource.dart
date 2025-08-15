// import 'dart:io';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// abstract class OCRDataSource {
//   Future<String> extractText(File imageFile);
//   Future<void> dispose();
// }

// class MLKitOCRDataSource implements OCRDataSource {
//   final TextRecognizer _textRecognizer = TextRecognizer();

//   @override
//   Future<String> extractText(File imageFile) async {
//     try {
//       final inputImage = InputImage.fromFile(imageFile);
//       final RecognizedText recognizedText = 
//           await _textRecognizer.processImage(inputImage);
      
//       return recognizedText.text;
//     } catch (e) {
//       throw Exception('ML Kit processing failed: $e');
//     }
//   }

//   @override
//   Future<void> dispose() async {
//       await _textRecognizer.close();
//   }
// } 