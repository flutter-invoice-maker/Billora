import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';

abstract class CustomerRepository {
  ResultFuture<void> createCustomer(Customer customer);
  ResultFuture<List<Customer>> getCustomers();
  ResultFuture<void> updateCustomer(Customer customer);
  ResultFuture<void> deleteCustomer(String id);
} 
