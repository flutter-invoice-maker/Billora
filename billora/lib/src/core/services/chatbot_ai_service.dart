import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';

/// Interface for Chatbot AI Service
abstract class ChatbotAIService {
  /// Send a message and get streaming response
  Stream<String> sendMessageStreaming({
    required String userId,
    required String message,
    required int currentTabIndex,
  });

  /// Send a message and get complete response
  Future<String> sendMessage({
    required String userId,
    required String message,
    required int currentTabIndex,
  });

  /// Cancel ongoing streaming for a specific conversation
  void cancelStreaming(String conversationId);

  /// Check if the service is available (API key configured)
  bool get isAvailable;
}

/// Implementation of Chatbot AI Service using OpenAI GPT
@injectable
class ChatbotAIServiceImpl implements ChatbotAIService {
  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;
  
  final Map<String, StreamController<String>> _streamControllers = {};
  final Map<String, bool> _cancelledStreams = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  static const String _defaultModel = 'gpt-3.5-turbo';

  @factoryMethod
  ChatbotAIServiceImpl({
    required InvoiceRepository invoiceRepository,
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
  }) : _invoiceRepository = invoiceRepository,
       _customerRepository = customerRepository,
       _productRepository = productRepository;

  @override
  bool get isAvailable {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    debugPrint('🔑 API Key check: ${apiKey != null ? 'Found' : 'Not found'}');
    if (apiKey != null) {
      debugPrint('🔑 API Key length: ${apiKey.length}');
      debugPrint('🔑 API Key starts with sk-: ${apiKey.startsWith('sk-')}');
    }
    return apiKey != null && apiKey.isNotEmpty && apiKey.startsWith('sk-');
  }

  @override
  Stream<String> sendMessageStreaming({
    required String userId,
    required String message,
    required int currentTabIndex,
  }) {
    final conversationId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final controller = StreamController<String>();
    _streamControllers[conversationId] = controller;
    _cancelledStreams[conversationId] = false;

    // Start the streaming process
    _processStreamingMessage(
      conversationId: conversationId,
      userId: userId,
      message: message,
      currentTabIndex: currentTabIndex,
      controller: controller,
    );

    return controller.stream;
  }

  @override
  Future<String> sendMessage({
    required String userId,
    required String message,
    required int currentTabIndex,
  }) async {
    try {
      debugPrint('🤖 AI Service: Starting message processing...');
      debugPrint('🤖 AI Service: isAvailable = $isAvailable');
      
      if (!isAvailable) {
        debugPrint('❌ AI Service: API key not available');
        return 'OpenAI API key is not configured. Please check your .env file.';
      }

      debugPrint('🤖 AI Service: Getting user data for userId: $userId');
      // Get user's business data for context
      final userData = await _getUserData(userId);
      debugPrint('🤖 AI Service: User data length: ${userData.length}');
      
      // Create system prompt with user's data
      final systemPrompt = _createSystemPrompt(userData, currentTabIndex);
      debugPrint('🤖 AI Service: System prompt created, length: ${systemPrompt.length}');
      
      debugPrint('🤖 AI Service: Calling OpenAI API with model: $_defaultModel');
      // Call OpenAI API
      final chatCompletion = await OpenAI.instance.chat.create(
        model: _defaultModel,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(message)],
          ),
        ],
        maxTokens: 1000,
        temperature: 0.7,
      );

      debugPrint('🤖 AI Service: OpenAI API response received');
      final content = chatCompletion.choices.first.message.content;
      if (content != null) {
        // Extract text from content items
        String responseText = content
            .map((item) => item.text)
            .where((text) => text != null)
            .join('');
        
        debugPrint('✅ AI Service: Response content length: ${responseText.length}');
        return responseText;
      }
      debugPrint('⚠️ AI Service: No content in response');
      return 'No response received.';
    } catch (e, stackTrace) {
      debugPrint('❌ AI Service Error: $e');
      debugPrint('❌ AI Service StackTrace: $stackTrace');
      return 'Sorry, I encountered an error while processing your request. Please try again.';
    }
  }

  @override
  void cancelStreaming(String conversationId) {
    _cancelledStreams[conversationId] = true;
    _streamSubscriptions[conversationId]?.cancel();
    _streamControllers[conversationId]?.close();
    _streamControllers.remove(conversationId);
    _cancelledStreams.remove(conversationId);
    _streamSubscriptions.remove(conversationId);
  }

  /// Process streaming message with OpenAI API
  Future<void> _processStreamingMessage({
    required String conversationId,
    required String userId,
    required String message,
    required int currentTabIndex,
    required StreamController<String> controller,
  }) async {
    try {
      if (!isAvailable) {
        controller.add('OpenAI API key is not configured. Please check your .env file.');
        controller.close();
        return;
      }

      // Get user's business data for context
      final userData = await _getUserData(userId);
      
      // Create system prompt with user's data
      final systemPrompt = _createSystemPrompt(userData, currentTabIndex);
      
      // Create streaming chat completion
      final stream = OpenAI.instance.chat.createStream(
        model: _defaultModel,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(message)],
          ),
        ],
        maxTokens: 1000,
        temperature: 0.7,
      );

      // Store subscription for cancellation
      final subscription = stream.listen(
        (chatStreamEvent) {
          if (_cancelledStreams[conversationId] == true) {
            return;
          }

          final content = chatStreamEvent.choices.first.delta.content;
          if (content != null && content.isNotEmpty) {
            // Extract text from content items for streaming
            String contentText = content
                .map((item) => item?.text)
                .where((text) => text != null)
                .join('');
            
            if (contentText.isNotEmpty) {
              controller.add(contentText);
            }
          }
        },
        onError: (error) {
          debugPrint('Streaming error: $error');
          controller.addError(error);
        },
        onDone: () {
          if (!_cancelledStreams[conversationId]!) {
            controller.close();
          }
        },
      );

      _streamSubscriptions[conversationId] = subscription;
    } catch (e) {
      debugPrint('Error in streaming: $e');
      controller.addError(e);
    } finally {
      _streamControllers.remove(conversationId);
      _cancelledStreams.remove(conversationId);
      _streamSubscriptions.remove(conversationId);
    }
  }

  /// Get user's business data for context
  Future<String> _getUserData(String userId) async {
    try {
      final Map<String, dynamic> data = {};
      
      // Get invoices
      final invoiceResult = await _invoiceRepository.getInvoices();
      invoiceResult.fold(
        (failure) => data['invoices'] = [],
        (invoices) => data['invoices'] = invoices.map((i) => {
          'id': i.id,
          'customerName': i.customerName,
          'total': i.total,
          'status': i.status.toString().split('.').last, // Convert enum to string
          'createdAt': i.createdAt.toIso8601String(),
          'items': i.items.map((item) => {
            'name': item.name,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'total': item.total,
          }).toList(),
        }).toList(),
      );
      
      // Get customers
      final customerResult = await _customerRepository.getCustomers();
      customerResult.fold(
        (failure) => data['customers'] = [],
        (customers) => data['customers'] = customers.map((c) => {
          'id': c.id,
          'name': c.name,
          'email': c.email,
          'phone': c.phone,
          'address': c.address,
        }).toList(),
      );
      
      // Get products
      final productResult = await _productRepository.getProducts();
      productResult.fold(
        (failure) => data['products'] = [],
        (products) => data['products'] = products.map((p) => {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'category': p.category,
          'inventory': p.inventory,
        }).toList(),
      );

      return json.encode(data);
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return '{}';
    }
  }

  /// Create system prompt with user's business data
  String _createSystemPrompt(String userData, int currentTabIndex) {
    final tabNames = ['Dashboard', 'Customers', 'Products', 'Invoices'];
    final currentTab = currentTabIndex < tabNames.length ? tabNames[currentTabIndex] : 'General';
    
    return '''You are an AI business assistant specialized in invoice management and business intelligence. You have access to the user's complete business data and should provide specific, actionable insights based on their actual data.

CURRENT CONTEXT: User is viewing the $currentTab tab.

USER'S BUSINESS DATA:
$userData

INSTRUCTIONS:
1. Analyze the actual data provided above
2. Provide specific insights based on the real business data
3. Give actionable recommendations
4. Use actual numbers and names from the data
5. If data is insufficient, acknowledge it and suggest what additional data would be helpful
6. Be specific and avoid generic responses
7. Provide business intelligence insights
8. Focus on the current tab context ($currentTab) when relevant
9. Always maintain data privacy - only reference this user's data

You are helpful, professional, and data-driven in your responses.''';
  }
}
