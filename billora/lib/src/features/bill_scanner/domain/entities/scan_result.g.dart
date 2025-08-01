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
      ocrProvider: json['ocrProvider'] as String?,
      fieldConfidence: (json['fieldConfidence'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$ScanResultImplToJson(_$ScanResultImpl instance) =>
    <String, dynamic>{
      'rawText': instance.rawText,
      'confidence': _$ScanConfidenceEnumMap[instance.confidence]!,
      'processedAt': instance.processedAt.toIso8601String(),
      'ocrProvider': instance.ocrProvider,
      'fieldConfidence': instance.fieldConfidence,
      'errorMessage': instance.errorMessage,
    };

const _$ScanConfidenceEnumMap = {
  ScanConfidence.high: 'high',
  ScanConfidence.medium: 'medium',
  ScanConfidence.low: 'low',
  ScanConfidence.unknown: 'unknown',
};
