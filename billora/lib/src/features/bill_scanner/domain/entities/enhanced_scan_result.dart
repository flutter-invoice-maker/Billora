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

class EnhancedScanResult {
  final String rawText;
  final ScanConfidence confidence;
  final DateTime processedAt;
  final String ocrProvider;
  final BillType? detectedBillType;
  final Map<String, dynamic>? extractedFields;
  final List<String>? detectedLanguages;
  final double? processingTimeMs;
  final String? errorMessage;
  
  // Enhanced AI fields
  final Map<String, dynamic> aiExtractedData;
  final Map<String, double> fieldConfidence;
  final List<String> aiSuggestions;
  final Map<String, String> fieldMappings;
  final bool isDataValidated;
  final String aiModelVersion;
  final Map<String, dynamic> processingMetadata;

  EnhancedScanResult({
    required this.rawText,
    required this.confidence,
    required this.processedAt,
    required this.ocrProvider,
    this.detectedBillType,
    this.extractedFields,
    this.detectedLanguages,
    this.processingTimeMs,
    this.errorMessage,
    required this.aiExtractedData,
    required this.fieldConfidence,
    required this.aiSuggestions,
    required this.fieldMappings,
    required this.isDataValidated,
    required this.aiModelVersion,
    required this.processingMetadata,
  });

  EnhancedScanResult copyWith({
    String? rawText,
    ScanConfidence? confidence,
    DateTime? processedAt,
    String? ocrProvider,
    BillType? detectedBillType,
    Map<String, dynamic>? extractedFields,
    List<String>? detectedLanguages,
    double? processingTimeMs,
    String? errorMessage,
    Map<String, dynamic>? aiExtractedData,
    Map<String, double>? fieldConfidence,
    List<String>? aiSuggestions,
    Map<String, String>? fieldMappings,
    bool? isDataValidated,
    String? aiModelVersion,
    Map<String, dynamic>? processingMetadata,
  }) {
    return EnhancedScanResult(
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
      processedAt: processedAt ?? this.processedAt,
      ocrProvider: ocrProvider ?? this.ocrProvider,
      detectedBillType: detectedBillType ?? this.detectedBillType,
      extractedFields: extractedFields ?? this.extractedFields,
      detectedLanguages: detectedLanguages ?? this.detectedLanguages,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      errorMessage: errorMessage ?? this.errorMessage,
      aiExtractedData: aiExtractedData ?? this.aiExtractedData,
      fieldConfidence: fieldConfidence ?? this.fieldConfidence,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      fieldMappings: fieldMappings ?? this.fieldMappings,
      isDataValidated: isDataValidated ?? this.isDataValidated,
      aiModelVersion: aiModelVersion ?? this.aiModelVersion,
      processingMetadata: processingMetadata ?? this.processingMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawText': rawText,
      'confidence': confidence.toString(),
      'processedAt': processedAt.toIso8601String(),
      'ocrProvider': ocrProvider,
      'detectedBillType': detectedBillType?.toString(),
      'extractedFields': extractedFields,
      'detectedLanguages': detectedLanguages,
      'processingTimeMs': processingTimeMs,
      'errorMessage': errorMessage,
      'aiExtractedData': aiExtractedData,
      'fieldConfidence': fieldConfidence,
      'aiSuggestions': aiSuggestions,
      'fieldMappings': fieldMappings,
      'isDataValidated': isDataValidated,
      'aiModelVersion': aiModelVersion,
      'processingMetadata': processingMetadata,
    };
  }

  factory EnhancedScanResult.fromJson(Map<String, dynamic> json) {
    return EnhancedScanResult(
      rawText: json['rawText'],
      confidence: ScanConfidence.values.firstWhere(
        (e) => e.toString() == json['confidence'],
        orElse: () => ScanConfidence.unknown,
      ),
      processedAt: DateTime.parse(json['processedAt']),
      ocrProvider: json['ocrProvider'],
      detectedBillType: json['detectedBillType'] != null
          ? BillType.values.firstWhere(
              (e) => e.toString() == json['detectedBillType'],
              orElse: () => BillType.unknown,
            )
          : null,
      extractedFields: json['extractedFields'],
      detectedLanguages: json['detectedLanguages'] != null
          ? List<String>.from(json['detectedLanguages'])
          : null,
      processingTimeMs: json['processingTimeMs'],
      errorMessage: json['errorMessage'],
      aiExtractedData: Map<String, dynamic>.from(json['aiExtractedData']),
      fieldConfidence: Map<String, double>.from(json['fieldConfidence']),
      aiSuggestions: List<String>.from(json['aiSuggestions']),
      fieldMappings: Map<String, String>.from(json['fieldMappings']),
      isDataValidated: json['isDataValidated'],
      aiModelVersion: json['aiModelVersion'],
      processingMetadata: Map<String, dynamic>.from(json['processingMetadata']),
    );
  }
} 