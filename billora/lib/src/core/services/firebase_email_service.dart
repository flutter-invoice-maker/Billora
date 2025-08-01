import 'dart:typed_data';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

@injectable
class FirebaseEmailService {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  FirebaseEmailService(this._functions, this._auth);

  Future<void> sendInvoiceEmail({
    required String toEmail,
    required String subject,
    required String body,
    required Uint8List pdfData,
    required String fileName,
  }) async {
    try {
      // Check if user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Convert PDF data to base64
      final base64Pdf = base64Encode(pdfData);

      // Call Firebase Function
      final callable = _functions.httpsCallable('sendInvoiceEmail');
      final result = await callable.call({
        'toEmail': toEmail,
        'subject': subject,
        'body': body,
        'pdfData': base64Pdf,
        'fileName': fileName,
      });

      // Check result
      final data = result.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception('Failed to send email: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        switch (e.code) {
          case 'unauthenticated':
            throw Exception('User not authenticated. Please log in again.');
          case 'invalid-argument':
            throw Exception('Invalid email data provided.');
          case 'internal':
            throw Exception('Server error: ${e.message}');
          default:
            throw Exception('Failed to send email: ${e.message}');
        }
      }
      throw Exception('Error sending email: $e');
    }
  }
} 