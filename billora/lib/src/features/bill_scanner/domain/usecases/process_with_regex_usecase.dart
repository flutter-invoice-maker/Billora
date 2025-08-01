import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bill_scanner_repository.dart';

class ProcessWithRegexUseCase implements UseCase<String, String> {
  final BillScannerRepository repository;

  ProcessWithRegexUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String rawText) async {
    return await repository.processWithRegex(rawText);
  }
} 