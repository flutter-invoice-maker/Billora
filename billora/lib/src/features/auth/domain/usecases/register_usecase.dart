import '../repositories/auth_repository.dart';
import '../entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';

@injectable
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({required String email, required String password}) {
    return repository.register(email: email, password: password);
  }
} 