import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/user_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
  Future<void> logout();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    required String displayName,
    String? photoURL,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserService _userService;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn, this._userService);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) throw Exception('User not found');
    
    // Ensure user profile exists in Firestore
    await _userService.getUserProfile();
    
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> register({required String email, required String password}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) throw Exception('User not found');
    
    // Ensure user profile exists in Firestore
    await _userService.getUserProfile();
    
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> logout() async {
    try {
      // Sign out from Google if user was signed in with Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();
      
      // Clear any cached user data in UserService
      await _userService.clearUserCache();
    } catch (e) {
      // Log the error but don't throw it - we want logout to succeed
      // even if some cleanup operations fail
      print('Warning: Some logout operations failed: $e');
    }
  }
  
  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    final googleAuth = await googleUser.authentication;
    final credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('User not found');
    }
    
    // Ensure user profile exists in Firestore
    await _userService.getUserProfile();
    
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final credential = fb_auth.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('User not found');
    }
    
    // Ensure user profile exists in Firestore
    await _userService.getUserProfile();
    
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    
    // Check if user is still authenticated and has valid email
    if (user.email == null || user.email!.isEmpty) {
      return null;
    }
    
    // Try to get profile from Firestore first
    try {
      final profile = await _userService.getUserProfile();
      if (profile != null) {
        // Return UserModel with Firestore data
        return UserModel(
          id: profile.uid,
          email: profile.email,
          displayName: profile.displayName,
          photoURL: profile.photoURL,
        );
      }
    } catch (e) {
      // If Firestore fails, fallback to Firebase Auth
      // Log error silently as this is expected behavior
    }
    
    // Fallback to Firebase Auth data
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not found');
    
    // Update Firebase Auth
    await user.updateDisplayName(displayName);
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }
    
    // Update Firestore for persistent storage
    await _userService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
    
    return UserModel.fromFirebaseUser(user);
  }
} 