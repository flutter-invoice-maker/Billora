import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

@injectable
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String displayName,
    String? photoURL,
  }) async {
    return await repository.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }
} 