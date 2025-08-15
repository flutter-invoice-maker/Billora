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
    String? unit,
    String? category,
    String? sku,
    double? discount,
    double? tax,
    @Default(0.0) double confidence,
  }) = _BillLineItem;

  factory BillLineItem.fromJson(Map<String, dynamic> json) =>
      _$BillLineItemFromJson(json);
}

extension BillLineItemX on BillLineItem {
  BillLineItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    String? unit,
    String? category,
    String? sku,
    double? discount,
    double? tax,
    double? confidence,
  }) {
    return BillLineItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      confidence: confidence ?? this.confidence,
    );
  }
} 