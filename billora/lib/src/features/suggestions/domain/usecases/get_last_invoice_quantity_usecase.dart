import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/usecase/usecase.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';

@injectable
class GetLastInvoiceQuantityUseCase implements UseCase<Map<String, int>, String> {
  final InvoiceRepository repository;

  GetLastInvoiceQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(String customerId) async {
    return await repository.getLastInvoiceQuantity(customerId);
  }
} 