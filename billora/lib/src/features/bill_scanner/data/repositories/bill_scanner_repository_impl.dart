import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/free_ocr_api_datasource.dart';
import '../datasources/image_processing_datasource.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/repositories/bill_scanner_repository.dart';
import '../models/extraction_result_model.dart';

class BillScannerRepositoryImpl implements BillScannerRepository {
  final OCRDataSource mlKitDataSource;
  final FreeOCRApiDataSource apiDataSource;
  final ImageProcessingDataSource imageProcessingDataSource;

  BillScannerRepositoryImpl({
    required this.mlKitDataSource,
    required this.apiDataSource,
    required this.imageProcessingDataSource,
  });

  @override
  Future<Either<Failure, ScanResult>> scanBill(String imagePath) async {
    try {
      // Kiểm tra nếu là web file
      if (imagePath.startsWith('web_file_')) {
        // Trên web, không thể xử lý file local
        return Left(ServerFailure('Không thể xử lý file trên web. Vui lòng sử dụng mobile app.'));
      }

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return Left(ServerFailure('File ảnh không tồn tại'));
      }

      // Tối ưu ảnh trước khi OCR
      final optimizedFile = await imageProcessingDataSource.optimizeForOCR(imageFile);
      
      String extractedText = '';
      ScanConfidence confidence = ScanConfidence.unknown;
      
      try {
        // Thử ML Kit trước
        extractedText = await mlKitDataSource.extractText(optimizedFile);
        confidence = ScanConfidence.high;
      } catch (e) {
        // Fallback sang API
        try {
          final apiResponse = await apiDataSource.extractText(optimizedFile);
          extractedText = apiDataSource.parseOCRSpaceResponse(apiResponse);
          confidence = ScanConfidence.medium;
        } catch (apiError) {
          return Left(ServerFailure('Lỗi khi quét bill: $apiError'));
        }
      }
      
      if (extractedText.trim().isEmpty) {
        return Left(ServerFailure('Không thể trích xuất text từ ảnh'));
      }
      
      return Right(ScanResult(
        rawText: extractedText,
        confidence: confidence,
        processedAt: DateTime.now(),
        ocrProvider: confidence == ScanConfidence.high ? 'ML Kit' : 'OCR.Space API',
      ));
      
    } catch (e) {
      return Left(ServerFailure('Lỗi khi quét bill: $e'));
    }
  }

  @override
  Future<Either<Failure, ScannedBill>> extractBillData(String imagePath) async {
    try {
      final scanResult = await scanBill(imagePath);
      
      return scanResult.fold(
        (failure) => Left(failure),
        (result) async {
          final extractedData = _extractBillDataFromText(result.rawText);
          
          final scannedBill = ScannedBill(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: imagePath,
            storeName: extractedData.storeName,
            totalAmount: extractedData.totalAmount,
            scanDate: DateTime.now(),
            scanResult: result,
            items: extractedData.items?.map((item) => BillLineItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              description: item['description'] ?? '',
              quantity: item['quantity'] ?? 1.0,
              unitPrice: item['unit_price'] ?? 0.0,
              totalPrice: item['total_price'] ?? 0.0,
              confidence: item['confidence'] ?? 0.0,
            )).toList(),
            phone: extractedData.phone,
            address: extractedData.address,
            subtotal: extractedData.subtotal,
            tax: extractedData.tax,
            currency: extractedData.currency,
          );

          return Right(scannedBill);
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi trích xuất dữ liệu: $e'));
    }
  }

  @override
  Future<Either<Failure, ScannedBill>> validateBillData(ScannedBill bill) async {
    try {
      // Validation logic
      if (bill.storeName.isEmpty) {
        return Left(ServerFailure('Tên cửa hàng không được để trống'));
      }
      
      if (bill.totalAmount <= 0) {
        return Left(ServerFailure('Tổng tiền phải lớn hơn 0'));
      }

      return Right(bill);
    } catch (e) {
      return Left(ServerFailure('Lỗi validation: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> processWithRegex(String rawText) async {
    try {
      final processedText = _processTextWithRegex(rawText);
      return Right(processedText);
    } catch (e) {
      return Left(ServerFailure('Lỗi xử lý regex: $e'));
    }
  }

  ScanConfidence _calculateConfidence(String text) {
    if (text.length > 200) return ScanConfidence.high;
    if (text.length > 100) return ScanConfidence.medium;
    if (text.length > 50) return ScanConfidence.low;
    return ScanConfidence.unknown;
  }

  ExtractionResultModel _extractBillDataFromText(String text) {
    // Patterns cho tiền Việt Nam
    final vietnamCurrencyPattern = RegExp(
      r'(\d{1,3}(?:[,.]?\d{3})*)\s*(?:đ|vnd|VND|₫)',
      caseSensitive: false,
    );
    
    // Pattern cho ngày tháng Việt Nam
    final vietnamDatePattern = RegExp(
      r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})',
    );
    
    // Pattern cho số điện thoại Việt Nam  
    final vietnamPhonePattern = RegExp(
      r'(\+84|0)([3-9]\d{8})',
    );

    // final result = <String, dynamic>{};
    
    // Trích xuất tổng tiền
    final totalMatches = vietnamCurrencyPattern.allMatches(text);
    double totalAmount = 0.0;
    if (totalMatches.isNotEmpty) {
      final amounts = totalMatches.map((m) => 
        _parseVietnameseCurrency(m.group(1)!)
      ).toList()..sort();
      totalAmount = amounts.last; // Số lớn nhất thường là tổng
    }
    
    // Trích xuất ngày
    String? date;
    final dateMatch = vietnamDatePattern.firstMatch(text);
    if (dateMatch != null) {
      date = _parseVietnameseDate(dateMatch.group(0)!);
    }
    
    // Trích xuất số điện thoại
    String? phone;
    final phoneMatch = vietnamPhonePattern.firstMatch(text);
    if (phoneMatch != null) {
      phone = phoneMatch.group(0);
    }
    
    // Trích xuất tên cửa hàng (dòng đầu tiên thường là tên)
    final lines = text.split('\n');
    String storeName = 'Không xác định';
    if (lines.isNotEmpty) {
      storeName = lines.first.trim();
    }
    
    // Trích xuất items
    final items = _extractLineItems(text);
    
    return ExtractionResultModel(
      storeName: storeName,
      totalAmount: totalAmount,
      date: date,
      phone: phone,
      items: items,
      confidence: _calculateConfidence(text).index / ScanConfidence.values.length,
    );
  }

  double _parseVietnameseCurrency(String amount) {
    return double.parse(amount.replaceAll(RegExp(r'[,.]'), ''));
  }
  
  String _parseVietnameseDate(String dateStr) {
    final match = RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})').firstMatch(dateStr);
    if (match != null) {
      final day = match.group(1)!.padLeft(2, '0');
      final month = match.group(2)!.padLeft(2, '0');
      final year = match.group(3)!;
      return '$year-$month-$day';
    }
    return dateStr;
  }
  
  List<Map<String, dynamic>> _extractLineItems(String text) {
    final items = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    final vietnamCurrencyPattern = RegExp(
      r'(\d{1,3}(?:[,.]?\d{3})*)\s*(?:đ|vnd|VND|₫)',
      caseSensitive: false,
    );
    
    for (final line in lines) {
      final currencyMatches = vietnamCurrencyPattern.allMatches(line);
      if (currencyMatches.length >= 2) {
        // Có ít nhất 2 số tiền: giá đơn vị và thành tiền
        final amounts = currencyMatches.map((m) => 
          _parseVietnameseCurrency(m.group(1)!)
        ).toList();
        
        items.add({
          'description': line.split(RegExp(r'\d'))[0].trim(),
          'unit_price': amounts.first,
          'total_price': amounts.last,
          'quantity': amounts.last / amounts.first,
          'confidence': 0.8,
        });
      }
    }
    
    return items;
  }

  String _processTextWithRegex(String text) {
    // Xử lý text với regex patterns
    return text.trim();
  }
} 