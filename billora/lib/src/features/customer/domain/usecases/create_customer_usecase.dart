import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository repository;
  CreateCustomerUseCase(this.repository);

  ResultFuture<void> call(Customer customer) => repository.createCustomer(customer);
} 
