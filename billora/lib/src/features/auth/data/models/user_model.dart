import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:billora/src/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
  });

  factory UserModel.fromFirebaseUser(fb_auth.User user) {
    return UserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email ?? '',
      displayName: displayName,
      photoURL: photoURL,
    );
  }
} 