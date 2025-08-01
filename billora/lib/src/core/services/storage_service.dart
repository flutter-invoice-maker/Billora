import 'package:injectable/injectable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@injectable
class StorageService {
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  
  StorageService(this.storage, this.auth);

  Future<String> uploadInvoicePdf({
    required String userId,
    required String invoiceId,
    required Uint8List pdfData,
  }) async {
    try {
      // Check if user is authenticated
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate file size (max 10MB)
      if (pdfData.length > 10 * 1024 * 1024) {
        throw Exception('File size too large. Maximum size is 10MB.');
      }

      // For web platform, use a different approach to avoid CORS
      if (kIsWeb) {
        return await _uploadForWeb(userId, invoiceId, pdfData, user.uid);
      } else {
        return await _uploadForMobile(userId, invoiceId, pdfData, user.uid);
      }
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Upload failed: Unauthorized. Please check your authentication.');
        case 'storage/canceled':
          throw Exception('Upload was canceled.');
        case 'storage/unknown':
          throw Exception('Upload failed: Unknown error occurred.');
        case 'storage/invalid-checksum':
          throw Exception('Upload failed: Invalid file checksum.');
        case 'storage/retry-limit-exceeded':
          throw Exception('Upload failed: Retry limit exceeded. Please try again.');
        case 'storage/invalid-url':
          throw Exception('Upload failed: Invalid URL.');
        case 'storage/invalid-argument':
          throw Exception('Upload failed: Invalid argument provided.');
        case 'storage/no-default-bucket':
          throw Exception('Upload failed: No default bucket configured.');
        case 'storage/cannot-slice-blob':
          throw Exception('Upload failed: Cannot slice blob.');
        case 'storage/server-file-wrong-size':
          throw Exception('Upload failed: Server file wrong size.');
        default:
          throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<String> _uploadForMobile(String userId, String invoiceId, Uint8List pdfData, String userUid) async {
    // Create storage reference with proper path
    final ref = storage.ref().child('invoices/$userId/$invoiceId.pdf');
    
    // Upload with metadata
    final metadata = SettableMetadata(
      contentType: 'application/pdf',
      customMetadata: {
        'uploadedBy': userUid,
        'uploadedAt': DateTime.now().toIso8601String(),
        'invoiceId': invoiceId,
      },
    );
    
    final uploadTask = await ref.putData(pdfData, metadata);
    
    // Get download URL
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    return downloadUrl;
  }

  Future<String> _uploadForWeb(String userId, String invoiceId, Uint8List pdfData, String userUid) async {
    try {
      // For web, we'll use a simpler approach with less metadata to avoid CORS
      final ref = storage.ref().child('invoices/$userId/$invoiceId.pdf');
      
      // Use basic metadata for web
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
      );
      
      final uploadTask = await ref.putData(pdfData, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      // If web upload fails, provide a fallback message
      throw Exception('Web upload not available. Please use mobile app for PDF upload functionality.');
    }
  }
} 