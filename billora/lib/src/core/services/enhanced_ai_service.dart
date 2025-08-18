import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

@injectable
class EnhancedAIService {
  /// Get OpenAI API key from environment
  String get _apiKey {
    final envKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    return envKey;
  }

  static const String _openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-3.5-turbo';

  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;
  final FirebaseAuth _firebaseAuth;

  @factoryMethod
  EnhancedAIService({
    required InvoiceRepository invoiceRepository,
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
    required FirebaseAuth firebaseAuth,
  })  : _invoiceRepository = invoiceRepository,
        _customerRepository = customerRepository,
        _productRepository = productRepository,
        _firebaseAuth = firebaseAuth;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  bool get _isValidApiKey {
    if (_apiKey.isEmpty) return false;
    if (!_apiKey.startsWith('sk-')) return false;
    if (_apiKey.length < 20) return false;
    return true;
  }

  /// Analyze business data and provide insights based on user's actual data
  Future<String> analyzeBusinessData(String query) async {
    try {
      if (_currentUserId == null) {
        return 'Please log in to access your business data.';
      }

      if (!_isValidApiKey) {
        return 'OpenAI API key is not configured or invalid. Please check your configuration.';
      }

      // Gather all relevant business data
      final businessData = await _gatherBusinessData();
      
      // Create comprehensive prompt with actual data
      final prompt = _createBusinessAnalysisPrompt(query, businessData);
      
      // Call AI with real data
      final response = await _callChatGPT(prompt);
      
      return response ?? 'I\'m having trouble analyzing your data right now. Please try again.';
    } catch (e) {
      debugPrint('Business data analysis error: $e');
      return 'Sorry, I encountered an error while analyzing your business data. Please try again.';
    }
  }

  /// Gather all business data for the current user
  Future<Map<String, dynamic>> _gatherBusinessData() async {
    try {
      final Map<String, dynamic> data = {};
      
      // Get invoices
      final invoiceResult = await _invoiceRepository.getInvoices();
      invoiceResult.fold(
        (failure) => data['invoices'] = [],
        (invoices) => data['invoices'] = invoices.map((i) => i.toJson()).toList(),
      );
      
      // Get customers
      final customerResult = await _customerRepository.getCustomers();
      customerResult.fold(
        (failure) => data['customers'] = [],
        (customers) => data['customers'] = customers.map((c) => c.toJson()).toList(),
      );
      
      // Get products
      final productResult = await _productRepository.getProducts();
      productResult.fold(
        (failure) => data['products'] = [],
        (products) => data['products'] = products.map((p) => p.toJson()).toList(),
      );
      
      return data;
    } catch (e) {
      debugPrint('Error gathering business data: $e');
      return {};
    }
  }

  /// Create comprehensive prompt for business analysis
  String _createBusinessAnalysisPrompt(String query, Map<String, dynamic> businessData) {
    final invoices = businessData['invoices'] as List? ?? [];
    final customers = businessData['customers'] as List? ?? [];
    final products = businessData['products'] as List? ?? [];
    
    return '''
You are an AI business analyst assistant. Analyze the following business data and answer the user's question: "$query"

BUSINESS DATA:
Invoices: ${invoices.length} total invoices
- Recent invoices: ${invoices.take(5).map((i) => '${i['customerName'] ?? 'Unknown'}: \$${i['total']?.toStringAsFixed(2) ?? '0.00'}').join(', ')}

Customers: ${customers.length} total customers
- Customer names: ${customers.take(5).map((c) => c['name'] ?? 'Unknown').join(', ')}

Products: ${products.length} total products
- Product names: ${products.take(5).map((p) => p['name'] ?? 'Unknown').join(', ')}

INSTRUCTIONS:
1. Analyze the actual data provided above
2. Provide specific insights based on the real business data
3. Give actionable recommendations
4. Use actual numbers and names from the data
5. If data is insufficient, acknowledge it and suggest what additional data would be helpful
6. Be specific and avoid generic responses

Please provide a comprehensive analysis and answer to: "$query"
''';
  }

  /// Suggest tags for invoice based on content analysis
  Future<List<String>> suggestTags(Invoice invoice) async {
    try {
      // Prepare invoice data for analysis
      final itemsText = invoice.items.map((item) => '${item.name} (${item.quantity}x)').join(', ');
      final total = invoice.total.toStringAsFixed(2);
      final note = invoice.note ?? '';

      // Create prompt for ChatGPT
      final prompt = '''
Analyze the following invoice content and suggest relevant tags for categorization.

Invoice details:
- Customer: ${invoice.customerName}
- Items: $itemsText
- Total: \$$total
- Note: $note

Please suggest 3-5 relevant tags separated by commas. Return only the tags, no additional text.
Example format: tag1, tag2, tag3, tag4
''';

      // Call ChatGPT API
      final response = await _callChatGPT(prompt);
      
      if (response != null) {
        // Parse response to extract tags
        final tags = _parseTagsFromResponse(response);
        return tags;
      }
    } catch (e) {
      debugPrint('Error suggesting tags: $e');
    }
    
    return ['General', 'Business', 'Invoice'];
  }

  /// Classify invoice based on content
  Future<String> classifyInvoice(Invoice invoice) async {
    try {
      // Prepare invoice data for analysis
      final itemsText = invoice.items.map((item) => '${item.name} (${item.quantity}x)').join(', ');
      final total = invoice.total.toStringAsFixed(2);

      // Create prompt for ChatGPT
      final prompt = '''
Classify this invoice based on its content and context.

Invoice: 
- Customer: ${invoice.customerName}
- Items: $itemsText
- Total: \$$total

Classify into one of these categories: [Food & Beverage, Electronics, Services, Clothing, Software, Hardware, General]

Provide only the category name, no additional text.
''';

      // Call ChatGPT API
      final response = await _callChatGPT(prompt);
      
      if (response != null) {
        // Parse response to get classification
        final classification = _parseClassificationFromResponse(response);
        return classification;
      }
    } catch (e) {
      debugPrint('Error classifying invoice: $e');
    }
    
    return 'General';
  }

  /// Generate summary for invoice
  Future<String> generateSummary(Invoice invoice) async {
    try {
      // Prepare invoice data for analysis
      final itemsText = invoice.items.map((item) => '${item.name} (${item.quantity}x)').join(', ');
      final total = invoice.total.toStringAsFixed(2);

      // Create prompt for ChatGPT
      final prompt = '''
Create a brief summary of this invoice for quick reference.

Invoice: 
- Customer: ${invoice.customerName}
- Items: $itemsText
- Total: \$$total

Format: 'Invoice Type - Customer Name - Number of Items'
Keep summary under 50 characters. Return only the summary, no additional text.
''';

      // Call ChatGPT API
      final response = await _callChatGPT(prompt);
      
      if (response != null) {
        // Parse response to get summary
        final summary = _parseSummaryFromResponse(response, 50);
        return summary;
      }
    } catch (e) {
      debugPrint('Error generating summary: $e');
    }
    
    return 'Invoice summary generated';
  }

  /// Extract structured data from invoice text using AI
  Future<Map<String, dynamic>> extractInvoiceData(String rawText) async {
    try {
      final prompt = '''
Extract structured data from this invoice text:

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

  /// Call ChatGPT API with prompt
  Future<String?> _callChatGPT(String prompt) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('❌ OpenAI API key not configured or empty');
        return null;
      }

      if (!_isValidApiKey) {
        debugPrint('❌ OpenAI API key format is invalid');
        return null;
      }

      debugPrint('🔑 Using API key: ${_apiKey.substring(0, 7)}...');
      debugPrint('🤖 Using model: $_defaultModel');

      // Try with primary model first
      String? response = await _tryModel(_defaultModel, prompt);
      
      // If primary model fails, try with fallback model
      if (response == null) {
        debugPrint('⚠️ Primary model failed, trying fallback model...');
        response = await _tryModel('gpt-3.5-turbo-16k', prompt);
      }
      
      // If both models fail, try with basic model
      if (response == null) {
        debugPrint('⚠️ Fallback model failed, trying basic model...');
        response = await _tryModel('gpt-3.5-turbo', prompt);
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Error calling ChatGPT API: $e');
      return 'Network error occurred. Please check your internet connection.';
    }
  }

  /// Try calling API with specific model
  Future<String?> _tryModel(String model, String prompt) async {
    try {
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are an AI assistant specialized in invoice analysis and business intelligence. Be concise and professional in your responses.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      debugPrint('📤 Sending request to OpenAI API with model: $model...');
      final response = await http.post(
        Uri.parse(_openaiEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('✅ API call successful with model: $model');
        return responseData['choices'][0]['message']['content'] ?? '';
      } else {
        debugPrint('❌ ChatGPT API error with model $model: ${response.statusCode} - ${response.body}');
        
        // Handle specific error cases
        if (response.statusCode == 401) {
          return 'Authentication failed. Please check your OpenAI API key.';
        } else if (response.statusCode == 404) {
          return 'Model $model not found. Please check your OpenAI subscription.';
        } else if (response.statusCode == 429) {
          // Quota exceeded - try to provide helpful information
          return 'OpenAI API quota exceeded. This usually means:\n\n1. You\'ve reached your monthly usage limit\n2. Your billing plan needs to be updated\n3. You need to add payment method\n\nPlease check your OpenAI billing at: https://platform.openai.com/account/billing';
        } else if (response.statusCode == 402) {
          return 'Payment required. Please check your OpenAI billing and payment method.';
        } else if (response.statusCode == 500) {
          return 'OpenAI server error. Please try again later.';
        } else {
          return 'API error occurred (Status: ${response.statusCode}). Please try again.';
        }
      }
    } catch (e) {
      debugPrint('❌ Error calling ChatGPT API with model $model: $e');
      return null;
    }
  }

  /// Parse AI response for data extraction
  Map<String, dynamic> _parseAIResponse(String? response) {
    if (response == null || response.isEmpty) return {};
    
    try {
      // Clean response and extract JSON
      final cleanResponse = response.trim();
      final jsonStart = cleanResponse.indexOf('{');
      final jsonEnd = cleanResponse.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = cleanResponse.substring(jsonStart, jsonEnd + 1);
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
    }
    
    return {};
  }

  /// Parse tags from ChatGPT response
  List<String> _parseTagsFromResponse(String response) {
    try {
      // Clean response and split by comma
      final cleanResponse = response.trim().replaceAll('\n', '');
      final tags = cleanResponse.split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .take(5)
          .toList();
      
      return tags.isNotEmpty ? tags : ['General', 'Business', 'Invoice'];
    } catch (e) {
      debugPrint('Error parsing tags: $e');
      return ['General', 'Business', 'Invoice'];
    }
  }

  /// Parse classification from ChatGPT response
  String _parseClassificationFromResponse(String response) {
    try {
      final cleanResponse = response.trim().toLowerCase();
      final validCategories = [
        'food & beverage', 'electronics', 'services', 'clothing', 
        'software', 'hardware', 'general'
      ];
      
      for (final category in validCategories) {
        if (cleanResponse.contains(category)) {
          return category.split(' ').map((word) => 
            word.substring(0, 1).toUpperCase() + word.substring(1)
          ).join(' ');
        }
      }
      
      return 'General';
    } catch (e) {
      debugPrint('Error parsing classification: $e');
      return 'General';
    }
  }

  /// Parse summary from ChatGPT response
  String _parseSummaryFromResponse(String response, int maxLength) {
    try {
      final cleanResponse = response.trim();
      if (cleanResponse.length <= maxLength) {
        return cleanResponse;
      }
      
      return '${cleanResponse.substring(0, maxLength - 3)}...';
    } catch (e) {
      debugPrint('Error parsing summary: $e');
      return 'Invoice analysis completed';
    }
  }

  /// Get AI service status
  bool get isAvailable => _apiKey.isNotEmpty;

  /// Get current model being used
  String get currentModel => _defaultModel;
} 