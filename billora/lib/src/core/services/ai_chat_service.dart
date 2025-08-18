import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/services/huggingface_ai_service.dart';

@injectable
class AIChatService {
  final HuggingFaceAIService _aiService;
  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;
  final FirebaseAuth _firebaseAuth;

  AIChatService({
    required HuggingFaceAIService aiService,
    required InvoiceRepository invoiceRepository,
    required CustomerRepository customerRepository,
    required ProductRepository productRepository,
    required FirebaseAuth firebaseAuth,
  }) : _aiService = aiService,
       _invoiceRepository = invoiceRepository,
       _customerRepository = customerRepository,
       _productRepository = productRepository,
       _firebaseAuth = firebaseAuth;

  /// Get current user ID for data isolation
  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  /// Get contextual quick action suggestions based on current tab and data
  List<QuickAction> getQuickActions(int currentTabIndex) {
    switch (currentTabIndex) {
      case 0: // Dashboard
        return [
          QuickAction(
            title: 'Revenue Analysis',
            icon: '📊',
            prompt: 'Can you analyze my revenue trends and provide insights?',
            category: 'Financial',
          ),
          QuickAction(
            title: 'Business Performance',
            icon: '🚀',
            prompt: 'How is my business performing overall?',
            category: 'Overview',
          ),
          QuickAction(
            title: 'Growth Opportunities',
            icon: '📈',
            prompt: 'What growth opportunities do you see in my data?',
            category: 'Strategy',
          ),
          QuickAction(
            title: 'Customer Insights',
            icon: '👥',
            prompt: 'What insights can you provide about my customers?',
            category: 'Customer',
          ),
        ];
      case 1: // Customers
        return [
          QuickAction(
            title: 'Customer Segmentation',
            icon: '🎯',
            prompt: 'How should I segment my customers for better targeting?',
            category: 'Strategy',
          ),
          QuickAction(
            title: 'Customer Lifetime Value',
            icon: '💰',
            prompt: 'Which customers have the highest lifetime value?',
            category: 'Analysis',
          ),
          QuickAction(
            title: 'Retention Analysis',
            icon: '🔄',
            prompt: 'How can I improve customer retention?',
            category: 'Strategy',
          ),
          QuickAction(
            title: 'Customer Behavior',
            icon: '📊',
            prompt: 'What patterns do you see in customer behavior?',
            category: 'Analysis',
          ),
        ];
      case 2: // Products
        return [
          QuickAction(
            title: 'Top Selling Products',
            icon: '🏆',
            prompt: 'What are my top selling products and why?',
            category: 'Performance',
          ),
          QuickAction(
            title: 'Inventory Optimization',
            icon: '📦',
            prompt: 'How can I optimize my inventory management?',
            category: 'Operations',
          ),
          QuickAction(
            title: 'Pricing Strategy',
            icon: '💲',
            prompt: 'What pricing strategies would you recommend?',
            category: 'Strategy',
          ),
          QuickAction(
            title: 'Product Categories',
            icon: '🏷️',
            prompt: 'How should I organize my product categories?',
            category: 'Organization',
          ),
        ];
      case 3: // Invoices
        return [
          QuickAction(
            title: 'Invoice Analysis',
            icon: '📄',
            prompt: 'Can you analyze my invoicing patterns and trends?',
            category: 'Analysis',
          ),
          QuickAction(
            title: 'Payment Status',
            icon: '💳',
            prompt: 'What\'s the status of my outstanding payments?',
            category: 'Financial',
          ),
          QuickAction(
            title: 'Overdue Tracking',
            icon: '⏰',
            prompt: 'Which invoices are overdue and need attention?',
            category: 'Monitoring',
          ),
          QuickAction(
            title: 'Revenue Trends',
            icon: '📈',
            prompt: 'What trends do you see in my revenue data?',
            category: 'Analysis',
          ),
        ];
      default:
        return [
          QuickAction(
            title: 'Business Overview',
            icon: '🏢',
            prompt: 'Can you give me an overview of my business?',
            category: 'General',
          ),
          QuickAction(
            title: 'Performance Metrics',
            icon: '📊',
            prompt: 'What are my key performance indicators?',
            category: 'Metrics',
          ),
        ];
    }
  }

  /// Send message to AI and get response based on user's actual data
  Future<ChatResponse> sendMessage(String message, int currentTabIndex) async {
    try {
      if (_currentUserId == null) {
        return ChatResponse(
          message: 'Please log in to access your business data.',
          isError: true,
          suggestions: [],
        );
      }

      // Check if AI service is available
      if (!_aiService.isAvailable) {
        return ChatResponse(
          message: 'AI service is not available. Please check your Hugging Face API configuration.',
          isError: true,
          suggestions: [],
        );
      }

      // Analyze business data and provide contextual response
      final response = await _aiService.analyzeBusinessData(message);
      
      // Check if response indicates an error
      final isError = response.contains('error') || 
                     response.contains('trouble') || 
                     response.contains('failed') ||
                     response.contains('invalid') ||
                     response.contains('not configured') ||
                     response.contains('quota exceeded') ||
                     response.contains('billing') ||
                     response.contains('payment');
      
      // Generate follow-up suggestions based on the response
      final suggestions = isError ? _generateErrorSuggestions(response) : _generateFollowUpSuggestions(message, response, currentTabIndex);
      
      return ChatResponse(
        message: response,
        isError: isError,
        suggestions: suggestions,
      );
    } catch (e) {
      debugPrint('AI Chat error: $e');
      return ChatResponse(
        message: 'Sorry, I encountered an error while processing your request. Please try again.',
        isError: true,
        suggestions: [],
      );
    }
  }

  /// Generate contextual follow-up suggestions
  List<QuickAction> _generateFollowUpSuggestions(String originalMessage, String aiResponse, int currentTabIndex) {
    final suggestions = <QuickAction>[];
    final lowerMessage = originalMessage.toLowerCase();
    
    // Add contextual suggestions based on the original message and AI response
    if (lowerMessage.contains('revenue') || lowerMessage.contains('financial')) {
      suggestions.add(QuickAction(
        title: 'Revenue Breakdown',
        icon: '📊',
        prompt: 'Can you break down my revenue by month?',
        category: 'Financial',
      ));
      suggestions.add(QuickAction(
        title: 'Profit Margins',
        icon: '💹',
        prompt: 'What are my profit margins?',
        category: 'Financial',
      ));
    }
    
    if (lowerMessage.contains('customer') || lowerMessage.contains('client')) {
      suggestions.add(QuickAction(
        title: 'Customer Growth',
        icon: '📈',
        prompt: 'How has my customer base grown over time?',
        category: 'Customer',
      ));
      suggestions.add(QuickAction(
        title: 'Customer Satisfaction',
        icon: '😊',
        prompt: 'How can I improve customer satisfaction?',
        category: 'Customer',
      ));
    }
    
    if (lowerMessage.contains('product') || lowerMessage.contains('inventory')) {
      suggestions.add(QuickAction(
        title: 'Product Performance',
        icon: '🏆',
        prompt: 'Which products are underperforming?',
        category: 'Product',
      ));
      suggestions.add(QuickAction(
        title: 'Inventory Alerts',
        icon: '⚠️',
        prompt: 'Do I need to restock any products?',
        category: 'Product',
      ));
    }
    
    // Add general suggestions if no specific ones were added
    if (suggestions.isEmpty) {
      suggestions.addAll(getQuickActions(currentTabIndex).take(2).toList());
    }
    
    return suggestions;
  }

  /// Generate suggestions for error cases
  List<QuickAction> _generateErrorSuggestions(String errorMessage) {
    final suggestions = <QuickAction>[];
    
    if (errorMessage.contains('quota exceeded') || errorMessage.contains('billing')) {
      suggestions.add(QuickAction(
        title: 'Check OpenAI Billing',
        icon: '💳',
        prompt: 'How do I check my OpenAI billing?',
        category: 'Support',
      ));
      suggestions.add(QuickAction(
        title: 'Upgrade Plan',
        icon: '⬆️',
        prompt: 'How do I upgrade my OpenAI plan?',
        category: 'Support',
      ));
    } else if (errorMessage.contains('API key')) {
      suggestions.add(QuickAction(
        title: 'Check API Key',
        icon: '🔑',
        prompt: 'How do I check my OpenAI API key?',
        category: 'Support',
      ));
    } else if (errorMessage.contains('model not found')) {
      suggestions.add(QuickAction(
        title: 'Check Model Access',
        icon: '🤖',
        prompt: 'Which models do I have access to?',
        category: 'Support',
      ));
    }
    
    // Add general support suggestion
    if (suggestions.isEmpty) {
      suggestions.add(QuickAction(
        title: 'Get Help',
        icon: '❓',
        prompt: 'I need help with this error',
        category: 'Support',
      ));
    }
    
    return suggestions;
  }

  /// Get business data summary for context
  Future<BusinessDataSummary> getBusinessDataSummary() async {
    try {
      if (_currentUserId == null) {
        return BusinessDataSummary.empty();
      }

      final Map<String, dynamic> data = {};
      
      // Get invoices
      final invoiceResult = await _invoiceRepository.getInvoices();
      invoiceResult.fold(
        (failure) => data['invoices'] = [],
        (invoices) => data['invoices'] = invoices,
      );
      
      // Get customers
      final customerResult = await _customerRepository.getCustomers();
      customerResult.fold(
        (failure) => data['customers'] = [],
        (customers) => data['customers'] = customers,
      );
      
      // Get products
      final productResult = await _productRepository.getProducts();
      productResult.fold(
        (failure) => data['products'] = [],
        (products) => data['products'] = products,
      );

      return BusinessDataSummary(
        totalInvoices: (data['invoices'] as List).length,
        totalCustomers: (data['customers'] as List).length,
        totalProducts: (data['products'] as List).length,
        recentInvoices: (data['invoices'] as List).take(3).toList(),
        topCustomers: (data['customers'] as List).take(3).toList(),
        topProducts: (data['products'] as List).take(3).toList(),
      );
    } catch (e) {
      debugPrint('Error getting business data summary: $e');
      return BusinessDataSummary.empty();
    }
  }
}

/// Quick action for chat suggestions
class QuickAction {
  final String title;
  final String icon;
  final String prompt;
  final String category;

  QuickAction({
    required this.title,
    required this.icon,
    required this.prompt,
    required this.category,
  });
}

/// Chat response from AI
class ChatResponse {
  final String message;
  final bool isError;
  final List<QuickAction> suggestions;

  ChatResponse({
    required this.message,
    required this.isError,
    required this.suggestions,
  });
}

/// Business data summary for context
class BusinessDataSummary {
  final int totalInvoices;
  final int totalCustomers;
  final int totalProducts;
  final List<dynamic> recentInvoices;
  final List<dynamic> topCustomers;
  final List<dynamic> topProducts;

  BusinessDataSummary({
    required this.totalInvoices,
    required this.totalCustomers,
    required this.totalProducts,
    required this.recentInvoices,
    required this.topCustomers,
    required this.topProducts,
  });

  factory BusinessDataSummary.empty() {
    return BusinessDataSummary(
      totalInvoices: 0,
      totalCustomers: 0,
      totalProducts: 0,
      recentInvoices: [],
      topCustomers: [],
      topProducts: [],
    );
  }
} 