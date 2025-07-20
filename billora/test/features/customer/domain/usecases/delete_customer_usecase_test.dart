import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late DeleteCustomerUseCase usecase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    usecase = DeleteCustomerUseCase(mockRepository);
    registerFallbackValue('');
  });

  const id = '1';

  test('should call repository.deleteCustomer and return Right(unit)', () async {
    when(() => mockRepository.deleteCustomer(id)).thenAnswer((_) async => const Right(unit));
    final result = await usecase(id);
    expect(result, const Right(unit));
    verify(() => mockRepository.deleteCustomer(id)).called(1);
  });

  test('should return Left(Failure) when repository fails', () async {
    when(() => mockRepository.deleteCustomer(id)).thenAnswer((_) async => Left(AuthFailure('error')));
    final result = await usecase(id);
    expect(result.isLeft(), true);
    expect(result.fold((l) => l.message, (_) => ''), 'error');
    verify(() => mockRepository.deleteCustomer(id)).called(1);
  });
} 