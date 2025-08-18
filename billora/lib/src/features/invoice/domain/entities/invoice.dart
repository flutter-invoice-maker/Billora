import 'invoice_item.dart';

enum InvoiceStatus { draft, sent, paid, overdue, cancelled }

class Invoice {
  final String id;
  final String customerId;
  final String customerName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? note;
  final String? templateId;
  final List<String> tags;
  final List<String> searchKeywords;
  
  // AI-generated fields
  final String? aiClassification;
  final String? aiSummary;
  final List<String> aiSuggestedTags;
  final String? aiStatus; // 'pending', 'done', 'error'
  
  // QR Code fields
  final String? qrCodeData;
  final String? qrCodeHash;

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.note,
    this.templateId,
    this.tags = const [],
    this.searchKeywords = const [],
    this.aiClassification,
    this.aiSummary,
    this.aiSuggestedTags = const [],
    this.aiStatus,
    this.qrCodeData,
    this.qrCodeHash,
  });

  Invoice copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<InvoiceItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    InvoiceStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? paidAt,
    String? note,
    String? templateId,
    List<String>? tags,
    List<String>? searchKeywords,
    String? aiClassification,
    String? aiSummary,
    List<String>? aiSuggestedTags,
    String? aiStatus,
    String? qrCodeData,
    String? qrCodeHash,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
      templateId: templateId ?? this.templateId,
      tags: tags ?? this.tags,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      aiClassification: aiClassification ?? this.aiClassification,
      aiSummary: aiSummary ?? this.aiSummary,
      aiSuggestedTags: aiSuggestedTags ?? this.aiSuggestedTags,
      aiStatus: aiStatus ?? this.aiStatus,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      qrCodeHash: qrCodeHash ?? this.qrCodeHash,
    );
  }

  /// Convert Invoice to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'note': note,
      'templateId': templateId,
      'tags': tags,
      'searchKeywords': searchKeywords,
      'aiClassification': aiClassification,
      'aiSummary': aiSummary,
      'aiSuggestedTags': aiSuggestedTags,
      'aiStatus': aiStatus,
      'qrCodeData': qrCodeData,
      'qrCodeHash': qrCodeHash,
    };
  }
} 