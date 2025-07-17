import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;
  AuthRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) throw Exception('User not found');
    return UserModel(id: user.uid, email: user.email ?? '', displayName: user.displayName);
  }

  @override
  Future<UserModel> register({required String email, required String password}) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user == null) throw Exception('User not found');
    return UserModel(id: user.uid, email: user.email ?? '', displayName: user.displayName);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
} 