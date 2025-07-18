import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);

  ResultFuture<List<Customer>> call() => repository.getCustomers();
} 
