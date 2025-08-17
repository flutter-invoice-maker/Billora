import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class AIService {
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-3.5-turbo';

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
- Customer: $invoice.customerName
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
- Customer: $invoice.customerName
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
- Customer: $invoice.customerName
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

  /// Call ChatGPT API with prompt
  Future<String?> _callChatGPT(String prompt) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('OpenAI API key not configured');
        return null;
      }

      final requestBody = {
        'model': _defaultModel,
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
        'max_tokens': 200,
        'temperature': 0.7,
      };

      final response = await http.post(
        Uri.parse(_openaiEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'] ?? '';
      } else {
        debugPrint('ChatGPT API error: $response.statusCode - $response.body');
      }
    } catch (e) {
      debugPrint('Error calling ChatGPT API: $e');
    }
    
    return null;
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