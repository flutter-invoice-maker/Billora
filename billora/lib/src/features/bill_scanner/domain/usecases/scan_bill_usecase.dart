import 'dart:io';
import '../entities/scanned_bill.dart';
import '../repositories/bill_scanner_repository.dart';

class ScanBillUseCase {
  final BillScannerRepository _repository;

  ScanBillUseCase(this._repository);

  Future<ScannedBill> call(File imageFile) async {
    try {
      // Step 1: Scan the bill
      final scannedBill = await _repository.scanBill(imageFile);
      
      // Step 2: Validate and correct if needed
      final validatedBill = await _repository.validateAndCorrectBill(scannedBill);
      
      // Step 3: Save the bill
      await _repository.saveBill(validatedBill);
      
      return validatedBill;
    } catch (e) {
      throw Exception('Scan bill use case failed: $e');
    }
  }
} 