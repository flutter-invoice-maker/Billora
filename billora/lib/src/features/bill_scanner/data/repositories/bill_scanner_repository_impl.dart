import 'dart:io';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/bill_scanner_repository.dart';
import '../datasources/enhanced_free_ocr_datasource.dart';

class BillScannerRepositoryImpl implements BillScannerRepository {
  final EnhancedFreeOCRApiDataSource _ocrDataSource;

  BillScannerRepositoryImpl({
    required EnhancedFreeOCRApiDataSource ocrDataSource,
  }) : _ocrDataSource = ocrDataSource;

  @override
  Future<ScannedBill> scanBill(File imageFile) async {
    try {
      Logger.scanStart('bill scan', context: {'file': imageFile.path});
      final ocrResult = await _ocrDataSource.extractText(imageFile);
      
      if (!ocrResult['success']) {
        Logger.scanError('OCR processing', Exception(ocrResult['error'] ?? 'OCR processing failed'));
        throw Exception(ocrResult['error'] ?? 'OCR processing failed');
      }

      final structuredData = ocrResult['structuredData'] as Map<String, dynamic>;
      final rawText = ocrResult['rawText'] as String;
      final confidence = ocrResult['confidence'] as String;
      final billType = ocrResult['billType'] as String;

      Logger.debug('Creating scan result with confidence: $confidence, billType: $billType', tag: 'SCAN');

      final scanResult = ScanResult(
        rawText: rawText,
        confidence: _mapConfidenceString(confidence),
        processedAt: DateTime.now(),
        ocrProvider: 'OCR.Space Enhanced',
        detectedBillType: _mapBillTypeString(billType),
        extractedFields: structuredData,
        detectedLanguages: ['english'], // Only English now
        processingTimeMs: 0,
      );

      final items = _createLineItems(structuredData['lineItems'] as List<dynamic>? ?? []);
      
      // Calculate subtotal from line items if not provided
      double subtotal = (structuredData['subtotal'] ?? 0.0).toDouble();
      if (subtotal == 0.0 && items.isNotEmpty) {
        subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      }
      
      // Calculate total amount if not provided
      double totalAmount = (structuredData['totalAmount'] ?? 0.0).toDouble();
      if (totalAmount == 0.0) {
        totalAmount = subtotal + (structuredData['tax'] ?? 0.0).toDouble();
      }
      
      final scannedBill = ScannedBill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imageFile.path,
        storeName: structuredData['storeName'] ?? 'Unknown Store',
        totalAmount: totalAmount,
        scanDate: DateTime.now(),
        scanResult: scanResult,
        items: items,
        phone: structuredData['phone'],
        address: structuredData['address'],
        note: null,
        subtotal: subtotal,
        tax: (structuredData['tax'] ?? 0.0).toDouble(),
        currency: structuredData['currency'] ?? 'USD',
      );
      
      Logger.scanSuccess('scanned bill creation', result: {'storeName': scannedBill.storeName, 'totalAmount': scannedBill.totalAmount});
      return scannedBill;
    } catch (e) {
      Logger.scanError('bill scan', e);
      throw Exception('Failed to scan bill: $e');
    }
  }

  ScanConfidence _mapConfidenceString(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return ScanConfidence.high;
      case 'medium':
        return ScanConfidence.medium;
      case 'low':
        return ScanConfidence.low;
      default:
        return ScanConfidence.unknown;
    }
  }

  BillType _mapBillTypeString(String billType) {
    switch (billType) {
      case 'COMMERCIAL_INVOICE':
        return BillType.commercialInvoice;
      case 'SALES_INVOICE':
        return BillType.salesInvoice;
      case 'SERVICE_INVOICE':
        return BillType.salesInvoice;
      case 'RECEIPT':
        return BillType.paymentReceipt;
      case 'ESTIMATE':
        return BillType.proformaInvoice;
      default:
        return BillType.unknown;
    }
  }

  List<BillLineItem> _createLineItems(List<dynamic> itemsData) {
    final items = itemsData.map((item) {
      final itemMap = item as Map<String, dynamic>;
      
      // Ensure we have valid data
      final description = itemMap['description'] ?? '';
      final quantity = (itemMap['quantity'] ?? 1.0).toDouble();
      final unitPrice = (itemMap['unitPrice'] ?? 0.0).toDouble();
      final totalPrice = (itemMap['totalPrice'] ?? 0.0).toDouble();
      
      // Calculate total price if not provided
      final calculatedTotalPrice = totalPrice > 0 ? totalPrice : quantity * unitPrice;
      
      return BillLineItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${itemsData.indexOf(item)}',
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: calculatedTotalPrice,
        unit: itemMap['unit'] ?? 'pcs',
        confidence: 0.8,
      );
    }).toList();
    
    Logger.debug('Created ${items.length} line items', tag: 'SCAN');
    return items;
  }

  @override
  Future<ScannedBill> validateAndCorrectBill(ScannedBill scannedBill) async {
    Logger.debug('Validating and correcting scanned bill', tag: 'SCAN');
    
    final correctedBill = scannedBill.copyWith(
      // Ensure total amount matches sum of line items if items exist
      totalAmount: _validateTotalAmount(scannedBill),
      // Clean up store name
      storeName: _cleanStoreName(scannedBill.storeName),
      // Validate subtotal
      subtotal: _validateSubtotal(scannedBill),
    );
    
          Logger.debug('Bill validation completed', tag: 'SCAN');
    return correctedBill;
  }

  double _validateTotalAmount(ScannedBill bill) {
    if (bill.items != null && bill.items!.isNotEmpty) {
      final calculatedTotal = bill.items!.fold<double>(
        0.0, 
        (sum, item) => sum + item.totalPrice,
      );
      
      // If calculated total is significantly different, use the larger value
      if ((calculatedTotal - bill.totalAmount).abs() > bill.totalAmount * 0.1) {
        final newTotal = calculatedTotal > bill.totalAmount ? calculatedTotal : bill.totalAmount;
        Logger.debug('Adjusted total amount from \$${bill.totalAmount} to \$$newTotal', tag: 'SCAN');
        return newTotal;
      }
    }
    return bill.totalAmount;
  }

  double _validateSubtotal(ScannedBill bill) {
    if (bill.items != null && bill.items!.isNotEmpty) {
      final calculatedSubtotal = bill.items!.fold<double>(
        0.0, 
        (sum, item) => sum + item.totalPrice,
      );
      
      final currentSubtotal = bill.subtotal ?? 0.0;
      if (currentSubtotal == 0.0 || (calculatedSubtotal - currentSubtotal).abs() > currentSubtotal * 0.1) {
        Logger.debug('Adjusted subtotal from \$$currentSubtotal to \$$calculatedSubtotal', tag: 'SCAN');
        return calculatedSubtotal;
      }
    }
    return bill.subtotal ?? 0.0;
  }

  String _cleanStoreName(String storeName) {
    final cleaned = storeName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned != storeName) {
      Logger.debug('Cleaned store name: "$storeName" -> "$cleaned"', tag: 'SCAN');
    }
    return cleaned;
  }

  @override
  Future<bool> saveBill(ScannedBill scannedBill) async {
    // Implement save logic (database, local storage, etc.)
    try {
      Logger.saveOperation('scanned bill', itemId: scannedBill.id, itemName: scannedBill.storeName);
      // Save to your preferred storage
      return true;
    } catch (e) {
      Logger.saveError('scanned bill', e, itemId: scannedBill.id);
      return false;
    }
  }

  @override
  Future<List<ScannedBill>> getAllScannedBills() async {
    // Implement retrieval logic
    return [];
  }

  @override
  Future<ScannedBill?> getBillById(String id) async {
    // Implement retrieval by ID
    return null;
  }

  @override
  Future<bool> deleteBill(String id) async {
    // Implement deletion logic
    return true;
  }
} 