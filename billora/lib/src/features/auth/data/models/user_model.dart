import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email, super.displayName});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };
} 