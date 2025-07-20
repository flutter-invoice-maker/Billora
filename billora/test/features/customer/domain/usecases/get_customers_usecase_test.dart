import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late GetCustomersUseCase usecase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    usecase = GetCustomersUseCase(mockRepository);
  });

  final customers = [Customer(id: '1', name: 'Test', email: 'test@email.com')];

  test('should call repository.getCustomers and return Right(customers)', () async {
    when(() => mockRepository.getCustomers()).thenAnswer((_) async => Right(customers));
    final result = await usecase();
    expect(result, Right(customers));
    verify(() => mockRepository.getCustomers()).called(1);
  });

  test('should return Left(Failure) when repository fails', () async {
    when(() => mockRepository.getCustomers()).thenAnswer((_) async => Left(AuthFailure('error')));
    final result = await usecase();
    expect(result.isLeft(), true);
    expect(result.fold((l) => l.message, (_) => ''), 'error');
    verify(() => mockRepository.getCustomers()).called(1);
  });
} 