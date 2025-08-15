// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_line_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BillLineItemImpl _$$BillLineItemImplFromJson(Map<String, dynamic> json) =>
    _$BillLineItemImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      sku: json['sku'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$BillLineItemImplToJson(_$BillLineItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'unit': instance.unit,
      'category': instance.category,
      'sku': instance.sku,
      'discount': instance.discount,
      'tax': instance.tax,
      'confidence': instance.confidence,
    };
