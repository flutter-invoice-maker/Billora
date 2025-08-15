import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class EnhancedFreeOCRApiDataSource {
  static const String baseUrl = 'https://api.ocr.space/parse/image';
  static const String apiKey = 'helloworld'; // API key công khai miễn phí
  
  Future<Map<String, dynamic>> extractText(File imageFile) async {
    final dio = Dio();
    
    FormData formData = FormData.fromMap({
      'apikey': apiKey,
      'language': 'eng',  // Chỉ sử dụng tiếng Anh để tối ưu hóa
      'isOverlayRequired': false,
      'detectOrientation': true,
      'isTable': true,  // Chế độ receipt scanning
      'OCREngine': 2,   // Engine mới nhất
      'scale': true,     // Tự động scale ảnh
      'fileType': 'jpg', // Chỉ định file type
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'bill.jpg',
      ),
    });

    try {
      debugPrint('🔍 Sending OCR request to API...');
      final response = await dio.post(baseUrl, data: formData);
      debugPrint('🔍 OCR API Response: ${response.data}');
      
      // Parse raw OCR response
      final rawText = parseOCRSpaceResponse(response.data);
      debugPrint('🔍 Extracted Raw Text: $rawText');
      
      if (rawText.isEmpty) {
        debugPrint('⚠️ Raw text is empty, returning default data');
        return {
          'success': false,
          'error': 'OCR returned empty text',
          'rawText': '',
          'structuredData': _getDefaultBillData(),
          'confidence': 'Unknown',
          'billType': 'UNKNOWN',
        };
      }
      
      // Extract structured data from English text
      final structuredData = parseEnglishBillData(rawText);
      debugPrint('🔍 Structured Data: $structuredData');
      
      return {
        'success': true,
        'rawText': rawText,
        'structuredData': structuredData,
        'confidence': _calculateConfidence(structuredData),
        'billType': _detectBillType(rawText),
      };
    } catch (e) {
      debugPrint('❌ OCR Error: $e');
      return {
        'success': false,
        'error': 'OCR processing error: $e',
        'rawText': '',
        'structuredData': _getDefaultBillData(),
        'confidence': 'Unknown',
        'billType': 'UNKNOWN',
      };
    }
  }

  String parseOCRSpaceResponse(Map<String, dynamic> response) {
    try {
      debugPrint('🔍 Parsing OCR response: $response');
      
      if (response['IsErroredOnProcessing'] == true) {
        debugPrint('⚠️ OCR API reported error: ${response['ErrorMessage']}');
        return '';
      }
      
      final parsedResults = response['ParsedResults'] as List?;
      if (parsedResults == null || parsedResults.isEmpty) {
        debugPrint('⚠️ No parsed results found in OCR response');
        return '';
      }
      
      final firstResult = parsedResults[0];
      final parsedText = firstResult['ParsedText'] as String?;
      
      if (parsedText == null || parsedText.trim().isEmpty) {
        debugPrint('⚠️ Parsed text is null or empty');
        return '';
      }
      
      debugPrint('✅ Successfully extracted text: ${parsedText.substring(0, parsedText.length > 100 ? 100 : parsedText.length)}...');
      return parsedText.trim();
    } catch (e) {
      debugPrint('❌ Error parsing OCR response: $e');
      return '';
    }
  }

  Map<String, dynamic> parseEnglishBillData(String text) {
    if (text.isEmpty) {
      debugPrint('⚠️ Text is empty, returning default data');
      return _getDefaultBillData();
    }

    debugPrint('🔍 Parsing English bill data from text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');
    
    final data = <String, dynamic>{};
    
    // Extract company/store name
    data['storeName'] = _extractStoreNameEnglish(text);
    
    // Extract total amount
    data['totalAmount'] = _extractTotalAmountEnglish(text);
    
    // Extract date
    data['date'] = _extractDateEnglish(text);
    
    // Extract invoice number
    data['invoiceNumber'] = _extractInvoiceNumberEnglish(text);
    
    // Extract contact information
    data['phone'] = _extractPhoneEnglish(text);
    data['email'] = _extractEmailEnglish(text);
    data['address'] = _extractAddressEnglish(text);
    
    // Extract bill recipient info
    data['billTo'] = _extractBillToEnglish(text);
    
    // Extract line items
    data['lineItems'] = _extractLineItemsEnglish(text);
    
    // Extract subtotal and tax
    data['subtotal'] = _extractSubtotalEnglish(text);
    data['tax'] = _extractTaxEnglish(text);
    data['currency'] = _extractCurrencyEnglish(text);
    
         debugPrint('🔍 Extracted data: $data');
    return data;
  }

  String _extractStoreNameEnglish(String text) {
    // Look for company name patterns in English invoices
    final patterns = [
      RegExp(r'(?:From|FROM|Bill\s+From|Invoice\s+From|Company|COMPANY):\s*([^\n\r]+)', caseSensitive: false),
      RegExp(r'^([A-Z][A-Z\s&.,\-]{2,50})', multiLine: true),
      RegExp(r'(?:^|\n)([A-Z][A-Z\s&.,\-]{2,50})(?:\n|$)', multiLine: true),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final name = match.group(1)!.trim();
        if (name.length > 2 && name.length < 100 && !name.contains('INVOICE') && !name.contains('RECEIPT')) {
          debugPrint('✅ Found store name: $name');
          return name;
        }
      }
    }
    
    // Try to extract from the first meaningful line
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
              if (firstLine.length > 2 && firstLine.length < 100 && 
            !firstLine.contains('INVOICE') && !firstLine.contains('RECEIPT') &&
            !firstLine.contains('Date') && !firstLine.contains('Due')) {
          debugPrint('✅ Using first line as store name: $firstLine');
          return firstLine;
        }
    }
    
         debugPrint('⚠️ Could not extract store name, using default');
    return 'Unknown Store';
  }

  double _extractTotalAmountEnglish(String text) {
    // English currency patterns
    final patterns = [
      RegExp(r'(?:Total|TOTAL|Amount\s+Due|Due|Balance|BALANCE):\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
      RegExp(r'[\$]\s*([0-9,.\s]+)\s*(?:USD|US\s*Dollar|Dollar)', caseSensitive: false),
      RegExp(r'([0-9,.\s]+)\s*(?:USD|US\s*Dollar|Dollar)', caseSensitive: false),
      RegExp(r'[\$]\s*([0-9,.\s]+)', caseSensitive: false),
      RegExp(r'(?:Total|TOTAL)\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        if (match.group(1) != null) {
          String amountStr = match.group(1)!.replaceAll(RegExp(r'[,\s]'), '');
          final amount = double.tryParse(amountStr);
                     if (amount != null && amount > 0) {
             debugPrint('✅ Found total amount: \$$amount');
             return amount;
           }
        }
      }
    }
    
         debugPrint('⚠️ Could not extract total amount');
    return 0.0;
  }

  String _extractDateEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Date|DATE|Invoice\s+Date|Issue\s+Date):\s*([0-9]{1,2}[\/\-][0-9]{1,2}[\/\-][0-9]{4})', caseSensitive: false),
      RegExp(r'(?:Date|DATE):\s*([A-Za-z]+\s+[0-9]{1,2},?\s+[0-9]{4})', caseSensitive: false),
      RegExp(r'([0-9]{1,2}[\/\-][0-9]{1,2}[\/\-][0-9]{4})'),
      RegExp(r'([A-Za-z]+\s+[0-9]{1,2},?\s+[0-9]{4})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
                 final date = match.group(1)!;
         debugPrint('✅ Found date: $date');
         return date;
      }
    }
    
         debugPrint('⚠️ Could not extract date');
    return '';
  }

  String _extractInvoiceNumberEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Invoice|INVOICE|INV|No|Number|#):\s*([A-Z0-9\-]+)', caseSensitive: false),
      RegExp(r'(?:Invoice|INV)[\s\-]*([0-9A-Z]+)', caseSensitive: false),
      RegExp(r'#([0-9A-Z]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
                 final invoiceNum = match.group(1)!;
         debugPrint('✅ Found invoice number: $invoiceNum');
         return invoiceNum;
      }
    }
    
         debugPrint('⚠️ Could not extract invoice number');
    return '';
  }

  String _extractPhoneEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Phone|Tel|Telephone|PHONE|TEL):\s*([0-9\s\-\+\(\)]+)', caseSensitive: false),
      RegExp(r'[\+]?[0-9]{1,3}[\s\-]?[0-9]{3}[\s\-]?[0-9]{3}[\s\-]?[0-9]{4}'),
      RegExp(r'\([0-9]{3}\)[\s\-]?[0-9]{3}[\s\-]?[0-9]{4}'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String phone = '';
        if (match.groupCount >= 1 && match.group(1) != null) {
          phone = match.group(1)!.trim();
        } else {
          phone = match.group(0)!.trim();
        }
                 if (phone.isNotEmpty) {
           debugPrint('✅ Found phone: $phone');
           return phone;
         }
      }
    }
    
         debugPrint('⚠️ Could not extract phone');
    return '';
  }

  String _extractEmailEnglish(String text) {
    final pattern = RegExp(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');
    final match = pattern.firstMatch(text);
         if (match != null && match.group(1) != null) {
       final email = match.group(1)!;
       debugPrint('✅ Found email: $email');
       return email;
     }
    
         debugPrint('⚠️ Could not extract email');
    return '';
  }

  String _extractAddressEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Address|ADDRESS|Location):\s*([^\n\r]+)', caseSensitive: false),
      RegExp(r'([0-9]+\s+[^\n\r,]+(?:,\s*[^\n\r]+)*(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr)[^\n\r]*)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final address = match.group(1)!.trim();
                 if (address.isNotEmpty) {
           debugPrint('✅ Found address: $address');
           return address;
         }
      }
    }
    
         debugPrint('⚠️ Could not extract address');
    return '';
  }

  String _extractBillToEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Bill\s+To|Bill\s+to|Bill\s+TO|Customer|CUSTOMER|Client|CLIENT):\s*([^\n\r]+)', caseSensitive: false),
      RegExp(r'(?:Bill\s+To|Customer)[\s\n\r]*([^\n\r]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final billTo = match.group(1)!.trim();
                 if (billTo.isNotEmpty) {
           debugPrint('✅ Found bill to: $billTo');
           return billTo;
         }
      }
    }
    
         debugPrint('⚠️ Could not extract bill to');
    return '';
  }

  List<Map<String, dynamic>> _extractLineItemsEnglish(String text) {
    final items = <Map<String, dynamic>>[];
    
    // Look for table-like structures
    final lines = text.split('\n');
    bool inTable = false;
    List<String> tableHeaders = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Detect table headers
      if (line.toLowerCase().contains('description') || 
          line.toLowerCase().contains('item') ||
          line.toLowerCase().contains('quantity') ||
          line.toLowerCase().contains('qty') ||
          line.toLowerCase().contains('unit') ||
          line.toLowerCase().contains('price') ||
          line.toLowerCase().contains('amount')) {
        inTable = true;
                 tableHeaders = line.split(RegExp(r'\s{2,}|\t')).map((e) => e.trim().toLowerCase()).toList();
         debugPrint('✅ Found table headers: $tableHeaders');
         continue;
      }
      
      if (inTable && line.isNotEmpty) {
        // Try to parse table rows
        final parts = line.split(RegExp(r'\s{2,}|\t'));
        if (parts.length >= 3) {
          final item = <String, dynamic>{};
          
          // Extract description (usually first part)
          item['description'] = parts[0].trim();
          
          // Try to extract quantity and price from remaining parts
          for (int j = 1; j < parts.length; j++) {
            final part = parts[j].trim();
            
            // Check if it's a quantity (integer)
            if (RegExp(r'^[0-9]+$').hasMatch(part)) {
              item['quantity'] = int.tryParse(part) ?? 1;
            } 
            // Check if it's a price (contains decimal or currency symbol)
            else if (RegExp(r'[\$]?[0-9,.\s]+').hasMatch(part)) {
              String priceStr = part.replaceAll(RegExp(r'[,\s\$]'), '');
              final price = double.tryParse(priceStr);
              if (price != null && price > 0) {
                if (!item.containsKey('unitPrice')) {
                  item['unitPrice'] = price;
                } else {
                  item['totalPrice'] = price;
                }
              }
            }
          }
          
          // Calculate total price if not found
          if (item.containsKey('quantity') && item.containsKey('unitPrice') && !item.containsKey('totalPrice')) {
            item['totalPrice'] = (item['quantity'] as int) * (item['unitPrice'] as double);
          }
          
                     if (item.containsKey('description') && item['description'].toString().isNotEmpty) {
             items.add(item);
             debugPrint('✅ Found line item: $item');
           }
        }
        
        // Stop if we hit total or summary
        if (line.toLowerCase().contains('total') || line.toLowerCase().contains('subtotal') || line.toLowerCase().contains('tax')) {
          break;
        }
      }
    }
    
         debugPrint('✅ Extracted ${items.length} line items');
    return items;
  }

  double _extractSubtotalEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Subtotal|Sub\s+Total|SUB\s*TOTAL):\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
      RegExp(r'(?:Net|NET):\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        String amountStr = match.group(1)!.replaceAll(RegExp(r'[,\s]'), '');
        final amount = double.tryParse(amountStr);
                   if (amount != null && amount > 0) {
             debugPrint('✅ Found subtotal: \$$amount');
             return amount;
           }
      }
    }
    
    return 0.0;
  }

  double _extractTaxEnglish(String text) {
    final patterns = [
      RegExp(r'(?:Tax|TAX|VAT|GST|Sales\s+Tax):\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
      RegExp(r'(?:Tax|TAX)\s*\([0-9]+%\):\s*[\$]?\s*([0-9,.\s]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        String amountStr = match.group(1)!.replaceAll(RegExp(r'[,\s]'), '');
        final amount = double.tryParse(amountStr);
                   if (amount != null && amount > 0) {
             debugPrint('✅ Found tax: \$$amount');
             return amount;
           }
      }
    }
    
    return 0.0;
  }

  String _extractCurrencyEnglish(String text) {
    if (text.contains('\$') || text.toLowerCase().contains('usd') || text.toLowerCase().contains('dollar')) {
      return 'USD';
    }
    return 'USD'; // Default to USD for English invoices
  }

  String _calculateConfidence(Map<String, dynamic> data) {
    int score = 0;
    
    if (data['storeName'] != null && data['storeName'] != 'Unknown Store') score++;
    if (data['totalAmount'] != null && data['totalAmount'] > 0) score++;
    if (data['date'] != null && data['date'].toString().isNotEmpty) score++;
    if (data['phone'] != null && data['phone'].toString().isNotEmpty) score++;
    if (data['email'] != null && data['email'].toString().isNotEmpty) score++;
    if (data['address'] != null && data['address'].toString().isNotEmpty) score++;
    if (data['invoiceNumber'] != null && data['invoiceNumber'].toString().isNotEmpty) score++;
    if (data['lineItems'] != null && (data['lineItems'] as List).isNotEmpty) score++;
    
         final confidence = score >= 6 ? 'High' : score >= 4 ? 'Medium' : score >= 2 ? 'Low' : 'Unknown';
     debugPrint('✅ Calculated confidence: $confidence (score: $score)');
     return confidence;
  }

  String _detectBillType(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('invoice')) {
      if (lowerText.contains('sales')) {
        return 'SALES_INVOICE';
      } else if (lowerText.contains('service')) {
        return 'SERVICE_INVOICE';
      } else {
        return 'COMMERCIAL_INVOICE';
      }
    } else if (lowerText.contains('receipt')) {
      return 'RECEIPT';
    } else if (lowerText.contains('estimate') || lowerText.contains('quote')) {
      return 'ESTIMATE';
    }
    
    return 'UNKNOWN';
  }

  Map<String, dynamic> _getDefaultBillData() {
    return {
      'storeName': 'Unknown Store',
      'totalAmount': 0.0,
      'date': '',
      'invoiceNumber': '',
      'phone': '',
      'email': '',
      'address': '',
      'billTo': '',
      'lineItems': <Map<String, dynamic>>[],
      'subtotal': 0.0,
      'tax': 0.0,
      'currency': 'USD',
    };
  }
} 