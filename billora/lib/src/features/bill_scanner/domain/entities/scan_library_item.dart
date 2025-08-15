import 'enhanced_scanned_bill.dart';

class ScanLibraryItem {
  final String id;
  final String fileName;
  final String imagePath;
  final EnhancedScannedBill scannedBill;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final String? customerId;
  final String? invoiceId;
  final String? note;
  final List<String> tags;
  final bool isProcessed;
  final Map<String, dynamic> metadata;

  ScanLibraryItem({
    required this.id,
    required this.fileName,
    required this.imagePath,
    required this.scannedBill,
    required this.createdAt,
    required this.lastModifiedAt,
    this.customerId,
    this.invoiceId,
    this.note,
    this.tags = const [],
    this.isProcessed = false,
    this.metadata = const {},
  });

  String totalAmountString() => '\$${scannedBill.totalAmount.toStringAsFixed(2)}';

  ScanLibraryItem copyWith({
    String? id,
    String? fileName,
    String? imagePath,
    EnhancedScannedBill? scannedBill,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? customerId,
    String? invoiceId,
    String? note,
    List<String>? tags,
    bool? isProcessed,
    Map<String, dynamic>? metadata,
  }) {
    return ScanLibraryItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      imagePath: imagePath ?? this.imagePath,
      scannedBill: scannedBill ?? this.scannedBill,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      customerId: customerId ?? this.customerId,
      invoiceId: invoiceId ?? this.invoiceId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      isProcessed: isProcessed ?? this.isProcessed,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'imagePath': imagePath,
      'scannedBill': scannedBill.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'customerId': customerId,
      'invoiceId': invoiceId,
      'note': note,
      'tags': tags,
      'isProcessed': isProcessed,
      'metadata': metadata,
    };
  }

  factory ScanLibraryItem.fromJson(Map<String, dynamic> json) {
    return ScanLibraryItem(
      id: json['id'],
      fileName: json['fileName'],
      imagePath: json['imagePath'],
      scannedBill: EnhancedScannedBill.fromJson(json['scannedBill']),
      createdAt: DateTime.parse(json['createdAt']),
      lastModifiedAt: DateTime.parse(json['lastModifiedAt']),
      customerId: json['customerId'],
      invoiceId: json['invoiceId'],
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      isProcessed: json['isProcessed'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
} 