import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:billora/src/features/customer/data/models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource remoteDatasource;
  CustomerRepositoryImpl(this.remoteDatasource);

  @override
  ResultFuture<void> createCustomer(Customer customer) async {
    try {
      final model = customer.toModel();
      await remoteDatasource.createCustomer(model);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Customer>> getCustomers() async {
    try {
      final models = await remoteDatasource.getCustomers();
      final customers = models.map((m) => m.toEntity()).toList();
      return Right(customers);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateCustomer(Customer customer) async {
    try {
      final model = customer.toModel();
      await remoteDatasource.updateCustomer(model);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteCustomer(String id) async {
    try {
      await remoteDatasource.deleteCustomer(id);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
} 
