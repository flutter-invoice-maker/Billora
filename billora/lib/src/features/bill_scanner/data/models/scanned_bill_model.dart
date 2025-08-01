import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/entities/scan_result.dart';

part 'scanned_bill_model.g.dart';

@JsonSerializable()
class ScannedBillModel {
  final String id;
  final String imagePath;
  final String storeName;
  final double totalAmount;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime scanDate;
  final ScanResult scanResult;
  final List<BillLineItem>? items;
  final String? phone;
  final String? address;
  final String? note;
  final double? subtotal;
  final double? tax;
  final String? currency;

  ScannedBillModel({
    required this.id,
    required this.imagePath,
    required this.storeName,
    required this.totalAmount,
    required this.scanDate,
    required this.scanResult,
    this.items,
    this.phone,
    this.address,
    this.note,
    this.subtotal,
    this.tax,
    this.currency,
  });

  factory ScannedBillModel.fromJson(Map<String, dynamic> json) =>
      _$ScannedBillModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedBillModelToJson(this);

  ScannedBill toEntity() {
    return ScannedBill(
      id: id,
      imagePath: imagePath,
      storeName: storeName,
      totalAmount: totalAmount,
      scanDate: scanDate,
      scanResult: scanResult,
      items: items,
      phone: phone,
      address: address,
      note: note,
      subtotal: subtotal,
      tax: tax,
      currency: currency,
    );
  }

  factory ScannedBillModel.fromEntity(ScannedBill entity) {
    return ScannedBillModel(
      id: entity.id,
      imagePath: entity.imagePath,
      storeName: entity.storeName,
      totalAmount: entity.totalAmount,
      scanDate: entity.scanDate,
      scanResult: entity.scanResult,
      items: entity.items,
      phone: entity.phone,
      address: entity.address,
      note: entity.note,
      subtotal: entity.subtotal,
      tax: entity.tax,
      currency: entity.currency,
    );
  }

  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String();
} 