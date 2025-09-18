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
      final storageRef = _storage.ref().child('profiles/${user.uid}/user/$fileName');

      // Upload the file with public metadata
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
            'public': 'true', // Set as public for profile images
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
                'public': 'true', // Set as public for product images
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
      throw Exception('Failed to upload product image: $e');
    }
  }

  Future<String> uploadCustomerAvatar(File imageFile, String customerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename
      final fileName = 'customer_${customerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profiles/${user.uid}/customers/$customerId/$fileName');

      // Upload the file with public metadata
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
            'customerId': customerId,
            'public': 'true', // Set as public for customer avatars
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload customer avatar: $e');
    }
  }
} 