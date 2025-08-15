import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class QRService {
  /// Generate QR code data for invoice
  Map<String, dynamic> generateInvoiceQRData(Invoice invoice) {
    return {
      'invoice_id': invoice.id,
      'customer_name': invoice.customerName,
      'total_amount': invoice.total,
      'created_date': invoice.createdAt.toIso8601String(),
      'due_date': invoice.dueDate?.toIso8601String(),
      'status': invoice.status.name,
      'items_count': invoice.items.length,
      'tags': invoice.tags,
      'template_id': invoice.templateId,
      'qr_version': '1.0',
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate QR code data as JSON string
  String generateInvoiceQRString(Invoice invoice) {
    final qrData = generateInvoiceQRData(invoice);
    return json.encode(qrData);
  }

  /// Generate QR code data as compressed string
  String generateInvoiceQRCompressedString(Invoice invoice) {
    final qrData = generateInvoiceQRData(invoice);
    final jsonString = json.encode(qrData);
    // Simple compression by removing spaces and newlines
    return jsonString.replaceAll(RegExp(r'\s+'), '');
  }

  /// Parse QR code data from string
  Map<String, dynamic>? parseQRData(String qrString) {
    try {
      final decoded = json.decode(qrString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('Error parsing QR data: $e');
    }
    return null;
  }

  /// Validate QR code data
  bool isValidInvoiceQRData(Map<String, dynamic> qrData) {
    final requiredFields = [
      'invoice_id',
      'customer_name',
      'total_amount',
      'created_date',
      'status',
    ];
    
    for (final field in requiredFields) {
      if (!qrData.containsKey(field) || qrData[field] == null) {
        return false;
      }
    }
    
    return true;
  }

  /// Extract invoice information from QR data
  Map<String, dynamic> extractInvoiceInfo(Map<String, dynamic> qrData) {
    return {
      'id': qrData['invoice_id'] ?? '',
      'customer_name': qrData['customer_name'] ?? '',
      'total_amount': qrData['total_amount'] ?? 0.0,
      'created_date': qrData['created_date'] ?? '',
      'due_date': qrData['due_date'],
      'status': qrData['status'] ?? 'draft',
      'items_count': qrData['items_count'] ?? 0,
      'tags': List<String>.from(qrData['tags'] ?? []),
      'template_id': qrData['template_id'],
    };
  }

  /// Generate QR code for invoice lookup URL
  String generateInvoiceLookupURL(String invoiceId) {
    return 'https://billora.app/invoice/$invoiceId';
  }

  /// Generate QR code for payment (if needed in future)
  Map<String, dynamic> generatePaymentQRData(Invoice invoice) {
    return {
      'type': 'payment',
      'invoice_id': invoice.id,
      'amount': invoice.total,
      'currency': 'USD',
      'customer_name': invoice.customerName,
      'due_date': invoice.dueDate?.toIso8601String(),
    };
  }

  /// Generate QR code data for invoice summary
  Map<String, dynamic> generateInvoiceSummaryQRData(Invoice invoice) {
    return {
      'type': 'summary',
      'invoice_id': invoice.id,
      'customer_name': invoice.customerName,
      'total_amount': invoice.total,
      'items_count': invoice.items.length,
      'status': invoice.status.name,
      'created_date': invoice.createdAt.toIso8601String(),
    };
  }

  /// Generate QR code data for invoice verification
  Map<String, dynamic> generateInvoiceVerificationQRData(Invoice invoice) {
    return {
      'type': 'verification',
      'invoice_id': invoice.id,
      'hash': _generateInvoiceHash(invoice),
      'created_date': invoice.createdAt.toIso8601String(),
      'total_amount': invoice.total,
    };
  }

  /// Generate simple hash for invoice verification
  String _generateInvoiceHash(Invoice invoice) {
    final data = '${invoice.id}${invoice.customerName}${invoice.total}${invoice.createdAt.toIso8601String()}';
    return data.hashCode.toString();
  }

  /// Get QR code configuration
  Map<String, dynamic> getQRConfig() {
    return {
      'data_format': 'json',
      'compression': true,
      'error_correction': 'M',
      'version': 10,
      'size': 256,
      'format': 'png',
    };
  }
} 