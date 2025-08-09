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
      final storageRef = _storage.ref().child('profile_images/$fileName');

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

  Future<void> deleteProfileImage(String imageURL) async {
    try {
      final ref = _storage.refFromURL(imageURL);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting (image might not exist)
      // Log error silently as this is expected behavior
    }
  }
} 