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

extension ScannedBillX on ScannedBill {
  ScannedBill copyWith({
    String? id,
    String? imagePath,
    String? storeName,
    double? totalAmount,
    DateTime? scanDate,
    ScanResult? scanResult,
    List<BillLineItem>? items,
    String? phone,
    String? address,
    String? note,
    double? subtotal,
    double? tax,
    String? currency,
  }) {
    return ScannedBill(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      storeName: storeName ?? this.storeName,
      totalAmount: totalAmount ?? this.totalAmount,
      scanDate: scanDate ?? this.scanDate,
      scanResult: scanResult ?? this.scanResult,
      items: items ?? this.items,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      currency: currency ?? this.currency,
    );
  }
} 