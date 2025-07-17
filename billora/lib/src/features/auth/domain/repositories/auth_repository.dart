import '../entities/user.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});
  Future<Either<Failure, User>> register({required String email, required String password});
  Future<void> logout();
} 