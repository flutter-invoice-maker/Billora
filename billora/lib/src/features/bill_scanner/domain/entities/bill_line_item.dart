import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_line_item.freezed.dart';
part 'bill_line_item.g.dart';

@freezed
class BillLineItem with _$BillLineItem {
  const factory BillLineItem({
    required String id,
    required String description,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
    double? tax,
    String? notes,
    double? confidence,
  }) = _BillLineItem;

  factory BillLineItem.fromJson(Map<String, dynamic> json) =>
      _$BillLineItemFromJson(json);
} 