// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScannedBillImpl _$$ScannedBillImplFromJson(Map<String, dynamic> json) =>
    _$ScannedBillImpl(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      storeName: json['storeName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      scanDate: DateTime.parse(json['scanDate'] as String),
      scanResult: ScanResult.fromJson(
        json['scanResult'] as Map<String, dynamic>,
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => BillLineItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      note: json['note'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$$ScannedBillImplToJson(_$ScannedBillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'storeName': instance.storeName,
      'totalAmount': instance.totalAmount,
      'scanDate': instance.scanDate.toIso8601String(),
      'scanResult': instance.scanResult,
      'items': instance.items,
      'phone': instance.phone,
      'address': instance.address,
      'note': instance.note,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'currency': instance.currency,
    };
