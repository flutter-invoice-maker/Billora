import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

enum ScanConfidence { high, medium, low, unknown }

enum BillType {
  commercialInvoice,
  salesInvoice,
  proformaInvoice,
  internalTransfer,
  timesheetInvoice,
  paymentReceipt,
  unknown
}

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String rawText,
    required ScanConfidence confidence,
    required DateTime processedAt,
    required String ocrProvider,
    BillType? detectedBillType,
    Map<String, dynamic>? extractedFields,
    List<String>? detectedLanguages,
    double? processingTimeMs,
    String? errorMessage,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
} 