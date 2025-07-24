import '../repositories/invoice_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class DeleteInvoiceUseCase {
  final InvoiceRepository repository;
  DeleteInvoiceUseCase(this.repository);

  ResultFuture<void> call(String id) {
    return repository.deleteInvoice(id);
  }
} 