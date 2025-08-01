import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scanned_bill.dart';
import '../entities/scan_result.dart';

abstract class BillScannerRepository {
  Future<Either<Failure, ScanResult>> scanBill(String imagePath);
  Future<Either<Failure, ScannedBill>> extractBillData(String imagePath);
  Future<Either<Failure, ScannedBill>> validateBillData(ScannedBill bill);
  Future<Either<Failure, String>> processWithRegex(String rawText);
} 