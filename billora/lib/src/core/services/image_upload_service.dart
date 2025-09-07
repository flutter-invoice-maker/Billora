import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class ImageUploadService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ImageUploadService(this._storage, this._auth);

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename
      final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profiles/${user.uid}/$fileName');

      // Upload the file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename with user ID to avoid conflicts
      final fileName = 'product_${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('products/${user.uid}/$productId/$fileName');

      // Upload the file with retry mechanism
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          final uploadTask = storageRef.putFile(
            imageFile,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'uploadedBy': user.uid,
                'uploadedAt': DateTime.now().toIso8601String(),
                'productId': productId,
              },
            ),
          );

          // Wait for upload to complete
          final snapshot = await uploadTask;
          
          // Get download URL
          final downloadURL = await snapshot.ref.getDownloadURL();
          
          return downloadURL;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            rethrow;
          }
          // Wait before retry
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
      
      throw Exception('Failed to upload after $maxRetries attempts');
    } catch (e) {
      // Provide more specific error messages
      if (e.toString().contains('object-not-found')) {
        throw Exception('Storage bucket not found. Please check Firebase Storage configuration.');
      } else if (e.toString().contains('unauthorized')) {
        throw Exception('Unauthorized access. Please check Firebase Storage rules.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Failed to upload product image: $e');
      }
    }
  }

  Future<void> deleteProfileImage(String imageURL) async {
    try {
      final ref = _storage.refFromURL(imageURL);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting (image might not exist)
      // Log error silently as this is expected behavior
    }
  }

  Future<void> deleteProductImage(String imageURL) async {
    try {
      final ref = _storage.refFromURL(imageURL);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting (image might not exist)
      // Log error silently as this is expected behavior
    }
  }
} 