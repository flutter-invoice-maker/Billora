// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanResultImpl _$$ScanResultImplFromJson(Map<String, dynamic> json) =>
    _$ScanResultImpl(
      rawText: json['rawText'] as String,
      confidence: $enumDecode(_$ScanConfidenceEnumMap, json['confidence']),
      processedAt: DateTime.parse(json['processedAt'] as String),
      ocrProvider: json['ocrProvider'] as String,
      detectedBillType: $enumDecodeNullable(
        _$BillTypeEnumMap,
        json['detectedBillType'],
      ),
      extractedFields: json['extractedFields'] as Map<String, dynamic>?,
      detectedLanguages:
          (json['detectedLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toDouble(),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$ScanResultImplToJson(_$ScanResultImpl instance) =>
    <String, dynamic>{
      'rawText': instance.rawText,
      'confidence': _$ScanConfidenceEnumMap[instance.confidence]!,
      'processedAt': instance.processedAt.toIso8601String(),
      'ocrProvider': instance.ocrProvider,
      'detectedBillType': _$BillTypeEnumMap[instance.detectedBillType],
      'extractedFields': instance.extractedFields,
      'detectedLanguages': instance.detectedLanguages,
      'processingTimeMs': instance.processingTimeMs,
      'errorMessage': instance.errorMessage,
    };

const _$ScanConfidenceEnumMap = {
  ScanConfidence.high: 'high',
  ScanConfidence.medium: 'medium',
  ScanConfidence.low: 'low',
  ScanConfidence.unknown: 'unknown',
};

const _$BillTypeEnumMap = {
  BillType.commercialInvoice: 'commercialInvoice',
  BillType.salesInvoice: 'salesInvoice',
  BillType.proformaInvoice: 'proformaInvoice',
  BillType.internalTransfer: 'internalTransfer',
  BillType.timesheetInvoice: 'timesheetInvoice',
  BillType.paymentReceipt: 'paymentReceipt',
  BillType.unknown: 'unknown',
};
