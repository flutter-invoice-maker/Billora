import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late CreateCustomerUseCase usecase;
  late MockCustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    usecase = CreateCustomerUseCase(repository);
  });

  test('should create customer', () async {
    final customer = Customer(id: '1', name: 'Test');
    when(() => repository.createCustomer(customer))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase(customer);
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.createCustomer(customer)).called(1);
    verifyNoMoreInteractions(repository);
  });
} 