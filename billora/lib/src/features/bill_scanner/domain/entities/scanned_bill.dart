import 'package:freezed_annotation/freezed_annotation.dart';
import 'bill_line_item.dart';
import 'scan_result.dart';

part 'scanned_bill.freezed.dart';
part 'scanned_bill.g.dart';

@freezed
class ScannedBill with _$ScannedBill {
  const factory ScannedBill({
    required String id,
    required String imagePath,
    required String storeName,
    required double totalAmount,
    required DateTime scanDate,
    required ScanResult scanResult,
    List<BillLineItem>? items,
    String? phone,
    String? address,
    String? note,
    double? subtotal,
    double? tax,
    String? currency,
  }) = _ScannedBill;

  factory ScannedBill.fromJson(Map<String, dynamic> json) =>
      _$ScannedBillFromJson(json);
} 