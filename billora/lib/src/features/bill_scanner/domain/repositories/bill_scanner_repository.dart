import 'dart:io';
import '../entities/scanned_bill.dart';

abstract class BillScannerRepository {
  Future<ScannedBill> scanBill(File imageFile);
  Future<ScannedBill> validateAndCorrectBill(ScannedBill scannedBill);
  Future<bool> saveBill(ScannedBill scannedBill);
  Future<List<ScannedBill>> getAllScannedBills();
  Future<ScannedBill?> getBillById(String id);
  Future<bool> deleteBill(String id);
} 