import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/auth/domain/entities/user.dart';
import 'package:billora/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:billora/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:billora/src/core/errors/failures.dart';

@GenerateMocks([AuthRepository])
import 'login_usecase_test.mocks.dart';

class TestFailure extends Failure {
  const TestFailure(super.message);
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginUseCase usecase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = User(id: '1', email: tEmail, displayName: 'Test User');

  test('should call AuthRepository.login and return User on success', () async {
    // arrange
    when(mockAuthRepository.login(email: tEmail, password: tPassword))
        .thenAnswer((_) async => Right(tUser));
    // act
    final result = await usecase(email: tEmail, password: tPassword);
    // assert
    expect(result, Right(tUser));
    verify(mockAuthRepository.login(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository returns error', () async {
    // arrange
    final failure = TestFailure('Login failed');
    when(mockAuthRepository.login(email: tEmail, password: tPassword))
        .thenAnswer((_) async => Left(failure));
    // act
    final result = await usecase(email: tEmail, password: tPassword);
    // assert
    expect(result, Left(failure));
    verify(mockAuthRepository.login(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
} 