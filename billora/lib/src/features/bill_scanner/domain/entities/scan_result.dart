import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

enum ScanConfidence {
  high,
  medium,
  low,
  unknown,
}

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String rawText,
    required ScanConfidence confidence,
    required DateTime processedAt,
    String? ocrProvider,
    Map<String, double>? fieldConfidence,
    String? errorMessage,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
} 