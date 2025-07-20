import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late UpdateCustomerUseCase usecase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    usecase = UpdateCustomerUseCase(mockRepository);
    registerFallbackValue(Customer(id: '', name: '', email: ''));
  });

  final customer = Customer(id: '1', name: 'Test', email: 'test@email.com');

  test('should call repository.updateCustomer and return Right(unit)', () async {
    when(() => mockRepository.updateCustomer(customer)).thenAnswer((_) async => const Right(unit));
    final result = await usecase(customer);
    expect(result, const Right(unit));
    verify(() => mockRepository.updateCustomer(customer)).called(1);
  });

  test('should return Left(Failure) when repository fails', () async {
    when(() => mockRepository.updateCustomer(customer)).thenAnswer((_) async => Left(AuthFailure('error')));
    final result = await usecase(customer);
    expect(result.isLeft(), true);
    expect(result.fold((l) => l.message, (_) => ''), 'error');
    verify(() => mockRepository.updateCustomer(customer)).called(1);
  });
} 