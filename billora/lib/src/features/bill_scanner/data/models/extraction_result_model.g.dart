// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extraction_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtractionResultModel _$ExtractionResultModelFromJson(
  Map<String, dynamic> json,
) => ExtractionResultModel(
  storeName: json['storeName'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  date: json['date'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
  subtotal: (json['subtotal'] as num?)?.toDouble(),
  tax: (json['tax'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$ExtractionResultModelToJson(
  ExtractionResultModel instance,
) => <String, dynamic>{
  'storeName': instance.storeName,
  'totalAmount': instance.totalAmount,
  'date': instance.date,
  'phone': instance.phone,
  'address': instance.address,
  'items': instance.items,
  'subtotal': instance.subtotal,
  'tax': instance.tax,
  'currency': instance.currency,
  'confidence': instance.confidence,
};
