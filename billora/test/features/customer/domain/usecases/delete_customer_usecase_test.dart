import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late DeleteCustomerUseCase usecase;
  late MockCustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    usecase = DeleteCustomerUseCase(repository);
  });

  test('should delete customer', () async {
    when(() => repository.deleteCustomer('1'))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase('1');
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.deleteCustomer('1')).called(1);
    verifyNoMoreInteractions(repository);
  });
} 