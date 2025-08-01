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
  ResultFuture<Map<String, int>> getLastInvoiceQuantity(String customerId) async {
    try {
      final models = await remoteDatasource.getInvoices();
      final customerInvoices = models
          .where((invoice) => invoice.customerId == customerId)
          .toList();
      
      if (customerInvoices.isEmpty) {
        return const Right({});
      }
      
      // Sort by creation date descending and get the most recent
      customerInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastInvoice = customerInvoices.first;
      
      // Extract product quantities from the last invoice
      final quantities = <String, int>{};
      for (final item in lastInvoice.items) {
        quantities[item.productId] = item.quantity.toInt();
      }
      
      return Right(quantities);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
} 