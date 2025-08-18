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
class HuggingFaceAIService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _defaultModel = 'microsoft/DialoGPT-medium';
  
  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;
  final FirebaseAuth _firebaseAuth;

  @factoryMethod
  HuggingFaceAIService({
    required InvoiceRepository invoiceRepository,
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
    required FirebaseAuth firebaseAuth,
  }) : _invoiceRepository = invoiceRepository,
       _customerRepository = customerRepository,
       _productRepository = productRepository,
       _firebaseAuth = firebaseAuth;

  /// Get current user ID for data isolation
  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  /// Get Hugging Face API key
  String get _apiKey => dotenv.env['HUGGING_FACE_API_KEY'] ?? '';

  /// Validate API key format
  bool get _isValidApiKey {
    if (_apiKey.isEmpty) return false;
    if (!_apiKey.startsWith('hf_')) return false;
    if (_apiKey.length < 10) return false;
    return true;
  }

  /// Check if API key is valid and service is available
  bool get isAvailable => _isValidApiKey;

  /// Analyze business data and provide insights based on user's actual data
  Future<String> analyzeBusinessData(String query) async {
    try {
      if (_currentUserId == null) {
        return 'Please log in to access your business data.';
      }

      if (!_isValidApiKey) {
        return 'Hugging Face API key is not configured or invalid. Please check your configuration.';
      }

      // Gather all relevant business data
      final businessData = await _gatherBusinessData();
      
      // Create comprehensive prompt with actual data
      final prompt = _createBusinessAnalysisPrompt(query, businessData);
      
      // Call AI with real data
      final response = await _callHuggingFaceAPI(prompt);
      
      return response ?? 'I\'m having trouble analyzing your data right now. Please try again.';
    } catch (e) {
      debugPrint('Business data analysis error: $e');
      return 'Sorry, I encountered an error while analyzing your business data. Please try again.';
    }
  }

  /// Call Hugging Face API with prompt
  Future<String?> _callHuggingFaceAPI(String prompt) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('❌ Hugging Face API key not configured');
        return null;
      }

      if (!_isValidApiKey) {
        debugPrint('❌ Hugging Face API key format is invalid');
        return null;
      }

      debugPrint('🔑 Using Hugging Face API key: ${_apiKey.substring(0, 7)}...');
      debugPrint('🤖 Using model: $_defaultModel');

      final requestBody = {
        'inputs': prompt,
        'parameters': {
          'max_length': 500,
          'temperature': 0.7,
          'do_sample': true,
          'return_full_text': false,
        }
      };

      debugPrint('📤 Sending request to Hugging Face API...');
      final response = await http.post(
        Uri.parse('$_baseUrl/$_defaultModel'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('✅ Hugging Face API call successful');
        
        // Handle different response formats
        if (responseData is List && responseData.isNotEmpty) {
          return responseData[0]['generated_text'] ?? responseData[0]['text'] ?? '';
        } else if (responseData is Map) {
          return responseData['generated_text'] ?? responseData['text'] ?? '';
        }
        
        return 'Analysis completed successfully.';
      } else {
        debugPrint('❌ Hugging Face API error: ${response.statusCode} - ${response.body}');
        
        // Handle specific error cases
        if (response.statusCode == 401) {
          return 'Authentication failed. Please check your Hugging Face API key.';
        } else if (response.statusCode == 429) {
          return 'Rate limit exceeded. Please try again later.';
        } else if (response.statusCode == 503) {
          return 'Model is currently loading. Please try again in a few moments.';
        } else {
          return 'API error occurred (Status: ${response.statusCode}). Please try again.';
        }
      }
    } catch (e) {
      debugPrint('❌ Error calling Hugging Face API: $e');
      return 'Network error occurred. Please check your internet connection.';
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
7. Provide business intelligence insights

Please provide a comprehensive analysis and answer to: "$query"
''';
  }

  /// Suggest tags for invoice
  Future<List<String>> suggestTags(Invoice invoice) async {
    try {
      final prompt = '''
Analyze this invoice and suggest relevant tags for categorization:

Invoice Details:
- Customer: ${invoice.customerName}
- Total: \$${invoice.total.toStringAsFixed(2)}
- Items: ${invoice.items.map((i) => i.name).join(', ')}

Please suggest 3-5 relevant tags for this invoice. Return only the tags, separated by commas.
''';

      final response = await _callHuggingFaceAPI(prompt);
      if (response != null && response.isNotEmpty) {
        return response.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error suggesting tags: $e');
      return [];
    }
  }

  /// Classify invoice type
  Future<String> classifyInvoice(Invoice invoice) async {
    try {
      final prompt = '''
Classify this invoice into one of these categories:
- Service Invoice
- Product Invoice
- Subscription Invoice
- One-time Purchase
- Recurring Billing

Invoice Details:
- Customer: ${invoice.customerName}
- Total: \$${invoice.total.toStringAsFixed(2)}
- Items: ${invoice.items.map((i) => i.name).join(', ')}

Return only the category name.
''';

      final response = await _callHuggingFaceAPI(prompt);
      return response ?? 'Unknown';
    } catch (e) {
      debugPrint('Error classifying invoice: $e');
      return 'Unknown';
    }
  }

  /// Generate summary for invoice
  Future<String> generateSummary(Invoice invoice) async {
    try {
      final prompt = '''
Generate a concise summary for this invoice:

Invoice Details:
- Customer: ${invoice.customerName}
- Total: \$${invoice.total.toStringAsFixed(2)}
- Items: ${invoice.items.map((i) => '${i.name} (${i.quantity}x \$${i.unitPrice})').join(', ')}
- Date: ${invoice.createdAt.toString()}

Please provide a 1-2 sentence summary highlighting key points.
''';

      final response = await _callHuggingFaceAPI(prompt);
      return response ?? 'Summary generation failed.';
    } catch (e) {
      debugPrint('Error generating summary: $e');
      return 'Summary generation failed.';
    }
  }
} 