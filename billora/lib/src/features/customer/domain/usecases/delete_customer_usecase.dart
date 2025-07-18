import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository repository;
  DeleteCustomerUseCase(this.repository);

  ResultFuture<void> call(String id) => repository.deleteCustomer(id);
} 
