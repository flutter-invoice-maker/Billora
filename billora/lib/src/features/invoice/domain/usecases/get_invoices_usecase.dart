import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class GetInvoicesUseCase {
  final InvoiceRepository repository;
  GetInvoicesUseCase(this.repository);

  ResultFuture<List<Invoice>> call() {
    return repository.getInvoices();
  }
} 