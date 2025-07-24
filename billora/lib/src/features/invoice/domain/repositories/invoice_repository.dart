import '../entities/invoice.dart';
import 'package:billora/src/core/utils/typedef.dart';

abstract class InvoiceRepository {
  ResultFuture<void> createInvoice(Invoice invoice);
  ResultFuture<List<Invoice>> getInvoices();
  ResultFuture<void> deleteInvoice(String id);
  // Có thể mở rộng thêm: update, delete, getById, ...
} 