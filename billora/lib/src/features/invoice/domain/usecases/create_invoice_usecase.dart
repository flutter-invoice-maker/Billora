import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository repository;
  CreateInvoiceUseCase(this.repository);

  ResultFuture<void> call(Invoice invoice) {
    return repository.createInvoice(invoice);
  }
} 