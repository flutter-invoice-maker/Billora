import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_remote_datasource.dart';
import '../models/invoice_model.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:dartz/dartz.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDatasource remoteDatasource;
  InvoiceRepositoryImpl(this.remoteDatasource);

  @override
  ResultFuture<void> createInvoice(Invoice invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      await remoteDatasource.createInvoice(model);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Invoice>> getInvoices() async {
    try {
      final models = await remoteDatasource.getInvoices();
      final invoices = models.map((m) => m.toEntity()).toList();
      return Right(invoices);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteInvoice(String id) async {
    try {
      await remoteDatasource.deleteInvoice(id);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Invoice>> getCustomerRecentInvoices(String customerId, {int limit = 2}) async {
    try {
      final models = await remoteDatasource.getCustomerRecentInvoices(customerId, limit: limit);
      final invoices = models.map((m) => m.toEntity()).toList();
      return Right(invoices);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
} 