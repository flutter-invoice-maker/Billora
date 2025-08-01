import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/scan_result.dart';
import '../repositories/bill_scanner_repository.dart';

class ScanBillUseCase implements UseCase<ScanResult, String> {
  final BillScannerRepository repository;

  ScanBillUseCase(this.repository);

  @override
  Future<Either<Failure, ScanResult>> call(String imagePath) async {
    return await repository.scanBill(imagePath);
  }
} 