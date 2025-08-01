import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/auth/domain/entities/user.dart';
import 'package:billora/src/features/auth/domain/repositories/auth_repository.dart';

@injectable
class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  ResultFuture<User> call() => repository.signInWithApple();
} 