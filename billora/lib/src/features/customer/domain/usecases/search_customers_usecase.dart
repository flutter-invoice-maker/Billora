import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';

class SearchCustomersUseCase {
  final CustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  ResultFuture<List<Customer>> call(String query) =>
      repository.searchCustomers(query);
} 