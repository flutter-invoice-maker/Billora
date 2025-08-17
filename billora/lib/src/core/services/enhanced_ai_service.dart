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
  static const String _openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-4';

  /// Enhanced bill scanning with AI processing
  Future<EnhancedScanResult> processBillImage(String imagePath) async {
    try {
      // Step 1: OCR Processing using ChatGPT Vision API
      final ocrResult = await _performOCRWithChatGPT(imagePath);
      
      // Step 2: AI Data Extraction
      final aiExtractedData = await _extractDataWithAI(ocrResult);
      
      // Step 3: Data Validation and Enhancement
      final validatedData = await _validateAndEnhanceData(aiExtractedData, ocrResult);
      
      // Step 4: Field Confidence Calculation
      final fieldConfidence = _calculateFieldConfidence(validatedData, ocrResult);
      
      // Step 5: Generate AI Suggestions
      final aiSuggestions = await _generateAISuggestions(validatedData, ocrResult);
      
      // Step 6: Create Field Mappings
      final fieldMappings = _createFieldMappings(validatedData);
      
      return EnhancedScanResult(
        rawText: ocrResult,
        confidence: _calculateOverallConfidence(fieldConfidence),
        processedAt: DateTime.now(),
        ocrProvider: 'ChatGPT Vision API',
        detectedBillType: _detectBillType(validatedData),
        extractedFields: validatedData,
        detectedLanguages: _detectLanguages(ocrResult),
        processingTimeMs: 0,
        errorMessage: null,
        aiExtractedData: validatedData,
        fieldConfidence: fieldConfidence,
        aiSuggestions: aiSuggestions,
        fieldMappings: fieldMappings,
        isDataValidated: true,
        aiModelVersion: _defaultModel,
        processingMetadata: {
          'ocr_engine': 'ChatGPT Vision',
          'ai_model': _defaultModel,
          'processing_steps': ['OCR', 'AI Extraction', 'Validation', 'Enhancement'],
          'confidence_threshold': 0.7,
        },
      );
    } catch (e) {
      debugPrint('Enhanced AI processing error: $e');
      rethrow;
    }
  }

  /// Call ChatGPT Vision API for OCR
  Future<String> _performOCRWithChatGPT(String imagePath) async {
    try {
      // Convert image to base64
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

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
        throw Exception('ChatGPT Vision API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ChatGPT Vision API Error: $e');
      rethrow;
    }
  }

  /// Extract structured data using ChatGPT
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

      final response = await _callChatGPT(prompt);
      return _parseAIResponse(response);
    } catch (e) {
      debugPrint('AI Data Extraction Error: $e');
      return {};
    }
  }

  /// Call ChatGPT API for text completion
  Future<String> _callChatGPT(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_openaiEndpoint),
        headers: {
          'Authorization': 'Bearer $_openaiApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _defaultModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an AI assistant specialized in invoice analysis and data extraction. Return only valid JSON responses.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 2048,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('ChatGPT API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ChatGPT API Error: $e');
      rethrow;
    }
  }

  /// Validate and enhance extracted data
  Future<Map<String, dynamic>> _validateAndEnhanceData(
    Map<String, dynamic> extractedData, 
    String rawText
  ) async {
    try {
      final validatedData = Map<String, dynamic>.from(extractedData);
      
      // Validate required fields
      if (validatedData['storeName'] == null || validatedData['storeName'].toString().isEmpty) {
        validatedData['storeName'] = 'Unknown Store';
      }
      
      if (validatedData['totalAmount'] == null) {
        validatedData['totalAmount'] = 0.0;
      }
      
      if (validatedData['currency'] == null || validatedData['currency'].toString().isEmpty) {
        validatedData['currency'] = 'USD';
      }
      
      if (validatedData['items'] == null) {
        validatedData['items'] = [];
      }
      
      // Enhance with additional context from raw text
      if (validatedData['date'] == null) {
        validatedData['date'] = DateTime.now().toIso8601String();
      }
      
      return validatedData;
    } catch (e) {
      debugPrint('Data validation error: $e');
      return extractedData;
    }
  }

  /// Calculate confidence for each field
  Map<String, double> _calculateFieldConfidence(
    Map<String, dynamic> validatedData, 
    String rawText
  ) {
    final confidence = <String, double>{};
    
    // Calculate confidence based on data quality
    confidence['storeName'] = validatedData['storeName'] != null && 
        validatedData['storeName'].toString().isNotEmpty ? 0.9 : 0.3;
    
    confidence['totalAmount'] = validatedData['totalAmount'] != null && 
        validatedData['totalAmount'] > 0 ? 0.95 : 0.2;
    
    confidence['items'] = validatedData['items'] != null && 
        (validatedData['items'] as List).isNotEmpty ? 0.85 : 0.4;
    
    confidence['date'] = validatedData['date'] != null ? 0.8 : 0.3;
    
    return confidence;
  }

  /// Generate AI suggestions for data improvement
  Future<List<String>> _generateAISuggestions(
    Map<String, dynamic> validatedData, 
    String rawText
  ) async {
    try {
      final prompt = '''
Based on this extracted invoice data, suggest improvements or additional information that could be captured:

Extracted Data: ${json.encode(validatedData)}
Raw Text: $rawText

Provide 3-5 suggestions for improving data quality or capturing additional fields.
Return only the suggestions, one per line.
''';

      final response = await _callChatGPT(prompt);
      return response.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('AI suggestions error: $e');
      return [
        'Verify extracted amounts match raw text',
        'Check for missing tax information',
        'Validate item descriptions'
      ];
    }
  }

  /// Create field mappings for UI
  Map<String, String> _createFieldMappings(Map<String, dynamic> validatedData) {
    return {
      'storeName': 'Store Name',
      'totalAmount': 'Total Amount',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'currency': 'Currency',
      'invoiceNumber': 'Invoice Number',
      'date': 'Date',
      'phone': 'Phone',
      'email': 'Email',
      'address': 'Address',
      'items': 'Items',
      'customerName': 'Customer Name',
      'paymentMethod': 'Payment Method',
      'dueDate': 'Due Date',
    };
  }

  /// Get service status
  bool get isAvailable => _openaiApiKey.isNotEmpty;

  /// Get current model
  String get currentModel => _defaultModel;

  /// Calculate overall confidence from field confidence
  ScanConfidence _calculateOverallConfidence(Map<String, double> fieldConfidence) {
    if (fieldConfidence.isEmpty) return ScanConfidence.unknown;
    
    final averageConfidence = fieldConfidence.values.reduce((a, b) => a + b) / fieldConfidence.length;
    
    if (averageConfidence >= 0.8) return ScanConfidence.high;
    if (averageConfidence >= 0.6) return ScanConfidence.medium;
    return ScanConfidence.low;
  }

  /// Detect bill type from extracted data
  BillType _detectBillType(Map<String, dynamic> data) {
    // Simple bill type detection logic
    if (data['invoiceNumber'] != null) return BillType.salesInvoice;
    if (data['paymentMethod'] != null) return BillType.paymentReceipt;
    return BillType.unknown;
  }

  /// Detect languages from text
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
} 