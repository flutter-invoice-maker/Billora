import 'bill_line_item.dart';

class EnhancedScannedBill {
  final String id;
  final String imagePath;
  final String storeName;
  final double totalAmount;
  final DateTime scanDate;
  final Map<String, dynamic> scanResult;
  final List<BillLineItem>? items;
  final String? phone;
  final String? address;
  final String? note;
  final double? subtotal;
  final double? tax;
  final String? currency;
  
  // Enhanced fields
  final Map<String, dynamic> aiProcessedData;
  final Map<String, double> fieldAccuracy;
  final List<String> validationWarnings;
  final bool isDataComplete;
  final String? suggestedCustomerName;
  final String? suggestedCategory;

  EnhancedScannedBill({
    required this.id,
    required this.imagePath,
    required this.storeName,
    required this.totalAmount,
    required this.scanDate,
    required this.scanResult,
    this.items,
    this.phone,
    this.address,
    this.note,
    this.subtotal,
    this.tax,
    this.currency,
    required this.aiProcessedData,
    required this.fieldAccuracy,
    required this.validationWarnings,
    required this.isDataComplete,
    this.suggestedCustomerName,
    this.suggestedCategory,
  });

  EnhancedScannedBill copyWith({
    String? id,
    String? imagePath,
    String? storeName,
    double? totalAmount,
    DateTime? scanDate,
    Map<String, dynamic>? scanResult,
    List<BillLineItem>? items,
    String? phone,
    String? address,
    String? note,
    double? subtotal,
    double? tax,
    String? currency,
    Map<String, dynamic>? aiProcessedData,
    Map<String, double>? fieldAccuracy,
    List<String>? validationWarnings,
    bool? isDataComplete,
    String? suggestedCustomerName,
    String? suggestedCategory,
  }) {
    return EnhancedScannedBill(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      storeName: storeName ?? this.storeName,
      totalAmount: totalAmount ?? this.totalAmount,
      scanDate: scanDate ?? this.scanDate,
      scanResult: scanResult ?? this.scanResult,
      items: items ?? this.items,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      currency: currency ?? this.currency,
      aiProcessedData: aiProcessedData ?? this.aiProcessedData,
      fieldAccuracy: fieldAccuracy ?? this.fieldAccuracy,
      validationWarnings: validationWarnings ?? this.validationWarnings,
      isDataComplete: isDataComplete ?? this.isDataComplete,
      suggestedCustomerName: suggestedCustomerName ?? this.suggestedCustomerName,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'storeName': storeName,
      'totalAmount': totalAmount,
      'scanDate': scanDate.toIso8601String(),
      'scanResult': scanResult,
      'items': items?.map((item) => item.toJson()).toList(),
      'phone': phone,
      'address': address,
      'note': note,
      'subtotal': subtotal,
      'tax': tax,
      'currency': currency,
      'aiProcessedData': aiProcessedData,
      'fieldAccuracy': fieldAccuracy,
      'validationWarnings': validationWarnings,
      'isDataComplete': isDataComplete,
      'suggestedCustomerName': suggestedCustomerName,
      'suggestedCategory': suggestedCategory,
    };
  }

  factory EnhancedScannedBill.fromJson(Map<String, dynamic> json) {
    return EnhancedScannedBill(
      id: json['id'],
      imagePath: json['imagePath'],
      storeName: json['storeName'],
      totalAmount: json['totalAmount'].toDouble(),
      scanDate: DateTime.parse(json['scanDate']),
      scanResult: Map<String, dynamic>.from(json['scanResult']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => BillLineItem.fromJson(item))
              .toList()
          : null,
      phone: json['phone'],
      address: json['address'],
      note: json['note'],
      subtotal: json['subtotal']?.toDouble(),
      tax: json['tax']?.toDouble(),
      currency: json['currency'],
      aiProcessedData: Map<String, dynamic>.from(json['aiProcessedData']),
      fieldAccuracy: Map<String, double>.from(json['fieldAccuracy']),
      validationWarnings: List<String>.from(json['validationWarnings']),
      isDataComplete: json['isDataComplete'],
      suggestedCustomerName: json['suggestedCustomerName'],
      suggestedCategory: json['suggestedCategory'],
    );
  }
} 