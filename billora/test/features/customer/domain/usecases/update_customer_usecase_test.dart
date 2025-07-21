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
  late MockCustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    usecase = UpdateCustomerUseCase(repository);
  });

  test('should update customer', () async {
    final customer = Customer(id: '1', name: 'Test');
    when(() => repository.updateCustomer(customer))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase(customer);
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.updateCustomer(customer)).called(1);
    verifyNoMoreInteractions(repository);
  });
} 