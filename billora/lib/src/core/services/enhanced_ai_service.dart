import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import '../../features/bill_scanner/domain/entities/enhanced_scan_result.dart';

@injectable
class EnhancedAIService {
  String get _openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Enhanced bill scanning with AI processing
  Future<EnhancedScanResult> processBillImage(String imagePath) async {
    try {
      // Step 1: OCR Processing
      final ocrResult = await _performOCR(imagePath);
      
      // Step 2: AI Data Extraction
      final aiExtractedData = await _extractDataWithAI(ocrResult.rawText);
      
      // Step 3: Data Validation and Enhancement
      final validatedData = await _validateAndEnhanceData(aiExtractedData, ocrResult.rawText);
      
      // Step 4: Field Confidence Calculation
      final fieldConfidence = _calculateFieldConfidence(validatedData, ocrResult.rawText);
      
      // Step 5: Generate AI Suggestions
      final aiSuggestions = await _generateAISuggestions(validatedData, ocrResult.rawText);
      
      // Step 6: Create Field Mappings
      final fieldMappings = _createFieldMappings(validatedData);
      
      return EnhancedScanResult(
        rawText: ocrResult.rawText,
        confidence: _calculateOverallConfidence(fieldConfidence),
        processedAt: DateTime.now(),
        ocrProvider: 'Enhanced AI OCR',
        detectedBillType: _detectBillType(validatedData),
        extractedFields: validatedData,
        detectedLanguages: _detectLanguages(ocrResult.rawText),
        processingTimeMs: ocrResult.processingTimeMs,
        errorMessage: null,
        aiExtractedData: validatedData,
        fieldConfidence: fieldConfidence,
        aiSuggestions: aiSuggestions,
        fieldMappings: fieldMappings,
        isDataValidated: true,
        aiModelVersion: '2.0',
        processingMetadata: {
          'ocr_engine': 'Enhanced AI',
          'ai_model': 'GPT-4 Vision',
          'processing_steps': ['OCR', 'AI Extraction', 'Validation', 'Enhancement'],
          'confidence_threshold': 0.7,
        },
      );
    } catch (e) {
      debugPrint('Error processing bill image: $e');
      return _createErrorResult(e.toString());
    }
  }

  /// Perform OCR on image
  Future<OCRResult> _performOCR(String imagePath) async {
    try {
      final startTime = DateTime.now();
      
      // Load image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      // Call OCR API (using OpenAI Vision API for better accuracy)
      final ocrText = await _callOpenAIVisionAPI(base64Image);
      
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      
      return OCRResult(
        rawText: ocrText,
        processingTimeMs: processingTime.toDouble(),
      );
    } catch (e) {
      debugPrint('OCR Error: $e');
      rethrow;
    }
  }

  /// Call OpenAI Vision API for OCR
  Future<String> _callOpenAIVisionAPI(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openaiApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Extract all text from this invoice/bill image. Return only the raw text without any formatting or interpretation.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': 4096,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OpenAI Vision API Error: $e');
      rethrow;
    }
  }

  /// Extract structured data using AI
  Future<Map<String, dynamic>> _extractDataWithAI(String rawText) async {
    try {
      final prompt = '''
Analyze this invoice/bill text and extract structured data in JSON format:

Text: $rawText

Extract and return JSON with these fields:
{
  "storeName": "store/company name",
  "totalAmount": "total amount as number",
  "subtotal": "subtotal amount",
  "tax": "tax amount", 
  "currency": "currency code",
  "invoiceNumber": "invoice number",
  "date": "invoice date",
  "phone": "phone number",
  "email": "email address",
  "address": "full address",
  "items": [
    {
      "description": "item description",
      "quantity": "quantity as number",
      "unitPrice": "unit price as number",
      "totalPrice": "total price as number"
    }
  ],
  "customerName": "customer name if present",
  "paymentMethod": "payment method",
  "dueDate": "due date if present"
}

Return only valid JSON, no additional text.
''';

      final response = await _callOpenAICompletion(prompt);
      return _parseAIResponse(response);
    } catch (e) {
      debugPrint('AI Data Extraction Error: $e');
      return {};
    }
  }

  /// Validate and enhance extracted data
  Future<Map<String, dynamic>> _validateAndEnhanceData(
    Map<String, dynamic> extractedData,
    String rawText,
  ) async {
    try {
      var validatedData = <String, dynamic>{};
      
      // Validate and clean each field
      for (final entry in extractedData.entries) {
        final key = entry.key;
        final value = entry.value;
        
        switch (key) {
          case 'storeName':
            validatedData[key] = _validateAndCleanText(value);
            break;
          case 'totalAmount':
          case 'subtotal':
          case 'tax':
            validatedData[key] = _validateAndCleanNumber(value);
            break;
          case 'currency':
            validatedData[key] = _validateAndCleanCurrency(value);
            break;
          case 'phone':
            validatedData[key] = _validateAndCleanPhone(value);
            break;
          case 'email':
            validatedData[key] = _validateAndCleanEmail(value);
            break;
          case 'items':
            validatedData[key] = _validateAndCleanItems(value);
            break;
          default:
            validatedData[key] = value;
        }
      }
      
      return validatedData;
    } catch (e) {
      debugPrint('Data Validation Error: $e');
      return extractedData;
    }
  }

  /// Calculate confidence for each field
  Map<String, double> _calculateFieldConfidence(
    Map<String, dynamic> data,
    String rawText,
  ) {
    final confidence = <String, double>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      double fieldConfidence = 0.0;
      
      if (value != null && value.toString().isNotEmpty) {
        // Base confidence
        fieldConfidence = 0.7;
        
        // Check if value appears in raw text
        if (rawText.toLowerCase().contains(value.toString().toLowerCase())) {
          fieldConfidence += 0.2;
        }
        
        // Pattern validation
        if (_validateFieldPattern(key, value)) {
          fieldConfidence += 0.1;
        }
      }
      
      confidence[key] = fieldConfidence.clamp(0.0, 1.0);
    }
    
    return confidence;
  }

  /// Generate AI suggestions for data improvement
  Future<List<String>> _generateAISuggestions(
    Map<String, dynamic> data,
    String rawText,
  ) async {
    try {
      final prompt = '''
Based on this invoice data and raw text, provide suggestions for improvement:

Data: ${json.encode(data)}
Raw Text: $rawText

Provide 3-5 specific suggestions for:
1. Data accuracy improvements
2. Missing information to look for
3. Potential data corrections
4. Business logic validation

Format as a simple list, one suggestion per line.
''';

      final response = await _callOpenAICompletion(prompt);
      return _parseSuggestions(response);
    } catch (e) {
      debugPrint('AI Suggestions Error: $e');
      return [];
    }
  }

  /// Create field mappings for data processing
  Map<String, String> _createFieldMappings(Map<String, dynamic> data) {
    return {
      'storeName': 'customer.name',
      'customerName': 'customer.name',
      'phone': 'customer.phone',
      'email': 'customer.email',
      'address': 'customer.address',
      'totalAmount': 'invoice.total',
      'subtotal': 'invoice.subtotal',
      'tax': 'invoice.tax',
      'currency': 'invoice.currency',
      'invoiceNumber': 'invoice.number',
      'date': 'invoice.date',
      'items': 'invoice.items',
    };
  }

  /// Helper methods
  String _validateAndCleanText(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.isNotEmpty ? text : '';
  }

  double _validateAndCleanNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    
    final text = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(text) ?? 0.0;
  }

  String _validateAndCleanCurrency(dynamic value) {
    if (value == null) return 'USD';
    final currency = value.toString().toUpperCase().trim();
    return currency.isNotEmpty ? currency : 'USD';
  }

  String _validateAndCleanPhone(dynamic value) {
    if (value == null) return '';
    final phone = value.toString().replaceAll(RegExp(r'[^\d+\-\(\)\s]'), '');
    return phone.trim();
  }

  String _validateAndCleanEmail(dynamic value) {
    if (value == null) return '';
    final email = value.toString().trim();
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return email;
    }
    return '';
  }

  List<Map<String, dynamic>> _validateAndCleanItems(dynamic value) {
    if (value == null || value is! List) return [];
    
    final items = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        items.add({
          'description': _validateAndCleanText(item['description']),
          'quantity': _validateAndCleanNumber(item['quantity']),
          'unitPrice': _validateAndCleanNumber(item['unitPrice']),
          'totalPrice': _validateAndCleanNumber(item['totalPrice']),
        });
      }
    }
    return items;
  }

  bool _validateFieldPattern(String field, dynamic value) {
    switch (field) {
      case 'email':
        return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.toString());
      case 'phone':
        return RegExp(r'^[\d+\-\(\)\s]+$').hasMatch(value.toString());
      case 'totalAmount':
      case 'subtotal':
      case 'tax':
        return value is num && value > 0;
      default:
        return true;
    }
  }

  ScanConfidence _calculateOverallConfidence(Map<String, double> fieldConfidence) {
    if (fieldConfidence.isEmpty) return ScanConfidence.unknown;
    
    final averageConfidence = fieldConfidence.values.reduce((a, b) => a + b) / fieldConfidence.length;
    
    if (averageConfidence >= 0.8) return ScanConfidence.high;
    if (averageConfidence >= 0.6) return ScanConfidence.medium;
    return ScanConfidence.low;
  }

  BillType _detectBillType(Map<String, dynamic> data) {
    // Simple bill type detection logic
    if (data['invoiceNumber'] != null) return BillType.salesInvoice;
    if (data['paymentMethod'] != null) return BillType.paymentReceipt;
    return BillType.unknown;
  }

  List<String> _detectLanguages(String text) {
    // Simple language detection
    final languages = <String>[];
    if (RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]').hasMatch(text)) {
      languages.add('vi');
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      languages.add('en');
    }
    return languages.isEmpty ? ['en'] : languages;
  }

  Future<String> _callOpenAICompletion(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openaiApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 2048,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OpenAI Completion API Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseAIResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }
      return {};
    } catch (e) {
      debugPrint('AI Response Parsing Error: $e');
      return {};
    }
  }

  List<String> _parseSuggestions(String response) {
    try {
      final lines = response.split('\n');
      return lines
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Suggestions Parsing Error: $e');
      return [];
    }
  }

  EnhancedScanResult _createErrorResult(String errorMessage) {
    return EnhancedScanResult(
      rawText: '',
      confidence: ScanConfidence.unknown,
      processedAt: DateTime.now(),
      ocrProvider: 'Error',
      detectedBillType: null,
      extractedFields: {},
      detectedLanguages: [],
      processingTimeMs: 0,
      errorMessage: errorMessage,
      aiExtractedData: {},
      fieldConfidence: {},
      aiSuggestions: ['Error occurred during processing'],
      fieldMappings: {},
      isDataValidated: false,
      aiModelVersion: 'Error',
      processingMetadata: {'error': errorMessage},
    );
  }
}

class OCRResult {
  final String rawText;
  final double processingTimeMs;

  OCRResult({
    required this.rawText,
    required this.processingTimeMs,
  });
} 