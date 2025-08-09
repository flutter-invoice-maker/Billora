import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class GetCustomerRecentInvoicesUseCase {
  final InvoiceRepository repository;
  GetCustomerRecentInvoicesUseCase(this.repository);

  ResultFuture<List<Invoice>> call(String customerId, {int limit = 2}) {
    return repository.getCustomerRecentInvoices(customerId, limit: limit);
  }
} 