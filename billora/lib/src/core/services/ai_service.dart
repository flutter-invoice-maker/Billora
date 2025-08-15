import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class AIService {
  static const String _metadataPath = 'assets/ai_models/metadata.json';
  
  String get _apiKey => dotenv.env['HUGGING_FACE_API_KEY'] ?? '';
  
  Map<String, dynamic>? _metadata;

  AIService() {
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final metadataString = await rootBundle.loadString(_metadataPath);
      _metadata = json.decode(metadataString);
    } catch (e) {
      debugPrint('Error loading AI metadata: $e');
    }
  }

  /// Suggest tags for invoice based on content analysis
  Future<List<String>> suggestTags(Invoice invoice) async {
    try {
      final config = _metadata?['invoice_analysis']?['tag_suggestion'];
      if (config == null) return [];

      final model = config['model'];
      final promptTemplate = config['prompt_template'];
      final maxTags = config['max_tags'] ?? 5;

      // Prepare invoice data for analysis
      final itemsText = invoice.items.map((item) => '${item.name} (${item.quantity}x)').join(', ');
      final total = invoice.total.toStringAsFixed(2);
      final note = invoice.note ?? '';

      // Create prompt
      final prompt = promptTemplate
          .replaceAll('{customer_name}', invoice.customerName)
          .replaceAll('{items}', itemsText)
          .replaceAll('{total}', total)
          .replaceAll('{note}', note);

      // Call AI model
      final response = await _callAIModel(model, prompt);
      
      if (response != null) {
        // Parse response to extract tags
        final tags = _parseTagsFromResponse(response, maxTags);
        return tags;
      }
    } catch (e) {
      debugPrint('Error suggesting tags: $e');
    }
    
    return [];
  }

  /// Classify invoice based on content
  Future<String> classifyInvoice(Invoice invoice) async {
    try {
      final config = _metadata?['invoice_analysis']?['invoice_classification'];
      if (config == null) return 'General';

      final model = config['model'];
      final promptTemplate = config['prompt_template'];
      final categories = List<String>.from(config['categories'] ?? ['General']);

      // Prepare invoice data
      final itemsText = invoice.items.map((item) => item.name).join(', ');
      final total = invoice.total.toStringAsFixed(2);

      // Create prompt
      final prompt = promptTemplate
          .replaceAll('{customer_name}', invoice.customerName)
          .replaceAll('{items}', itemsText)
          .replaceAll('{total}', total);

      // Call AI model
      final response = await _callAIModel(model, prompt);
      
      if (response != null) {
        // Parse response to get classification
        final classification = _parseClassificationFromResponse(response, categories);
        return classification;
      }
    } catch (e) {
      debugPrint('Error classifying invoice: $e');
    }
    
    return 'General';
  }

  /// Generate content summary for invoice
  Future<String> generateSummary(Invoice invoice) async {
    try {
      final config = _metadata?['invoice_analysis']?['content_summary'];
      if (config == null) return '';

      final model = config['model'];
      final promptTemplate = config['prompt_template'];
      final maxLength = config['max_length'] ?? 50;

      // Prepare invoice data
      final itemsText = invoice.items.map((item) => item.name).join(', ');
      final total = invoice.total.toStringAsFixed(2);

      // Create prompt
      final prompt = promptTemplate
          .replaceAll('{customer_name}', invoice.customerName)
          .replaceAll('{items}', itemsText)
          .replaceAll('{total}', total);

      // Call AI model
      final response = await _callAIModel(model, prompt);
      
      if (response != null) {
        // Parse response to get summary
        final summary = _parseSummaryFromResponse(response, maxLength);
        return summary;
      }
    } catch (e) {
      debugPrint('Error generating summary: $e');
    }
    
    return '';
  }

  /// Call AI model with prompt
  Future<String?> _callAIModel(String modelName, String prompt) async {
    try {
      final modelConfig = _metadata?['models']?[modelName];
      if (modelConfig == null) return null;

      final endpoint = modelConfig['api_endpoint'];
      final headers = Map<String, String>.from(modelConfig['headers'] ?? {});
      
      // Replace API key placeholder
      headers['Authorization'] = headers['Authorization']?.replaceAll('\${HUGGING_FACE_API_KEY}', _apiKey) ?? 'Bearer $_apiKey';
      headers['Content-Type'] = 'application/json';

      final requestBody = {
        'inputs': prompt,
        'parameters': {
          'max_new_tokens': modelConfig['max_tokens'] ?? 2048,
          'temperature': modelConfig['temperature'] ?? 0.7,
          'return_full_text': false,
        }
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData[0]?['generated_text'] ?? '';
      } else {
        debugPrint('AI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error calling AI model: $e');
    }
    
    return null;
  }

  /// Parse tags from AI response
  List<String> _parseTagsFromResponse(String response, int maxTags) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        if (jsonData['suggested_tags'] != null) {
          final tags = List<String>.from(jsonData['suggested_tags']);
          return tags.take(maxTags).toList();
        }
      }

      // Fallback: extract tags from text
      final lines = response.split('\n');
      final tags = <String>[];
      
      for (final line in lines) {
        if (line.toLowerCase().contains('tag') && line.contains(':')) {
          final tagText = line.split(':')[1].trim();
          if (tagText.isNotEmpty) {
            final lineTags = tagText.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty);
            tags.addAll(lineTags);
          }
        }
      }

      return tags.take(maxTags).toList();
    } catch (e) {
      debugPrint('Error parsing tags from response: $e');
      return [];
    }
  }

  /// Parse classification from AI response
  String _parseClassificationFromResponse(String response, List<String> categories) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        if (jsonData['classification'] != null) {
          final classification = jsonData['classification'].toString();
          if (categories.contains(classification)) {
            return classification;
          }
        }
      }

      // Fallback: find category in text
      final lowerResponse = response.toLowerCase();
      for (final category in categories) {
        if (lowerResponse.contains(category.toLowerCase())) {
          return category;
        }
      }

      return 'General';
    } catch (e) {
      debugPrint('Error parsing classification from response: $e');
      return 'General';
    }
  }

  /// Parse summary from AI response
  String _parseSummaryFromResponse(String response, int maxLength) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        if (jsonData['summary'] != null) {
          final summary = jsonData['summary'].toString();
          return summary.length > maxLength ? summary.substring(0, maxLength) : summary;
        }
      }

      // Fallback: extract summary from text
      final lines = response.split('\n');
      for (final line in lines) {
        if (line.toLowerCase().contains('summary') && line.contains(':')) {
          final summary = line.split(':')[1].trim();
          if (summary.isNotEmpty) {
            return summary.length > maxLength ? summary.substring(0, maxLength) : summary;
          }
        }
      }

      // If no summary found, use first meaningful line
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('{') && !trimmedLine.startsWith('}')) {
          return trimmedLine.length > maxLength ? trimmedLine.substring(0, maxLength) : trimmedLine;
        }
      }

      return 'Invoice analysis completed';
    } catch (e) {
      debugPrint('Error parsing summary from response: $e');
      return 'Invoice analysis completed';
    }
  }

  /// Get AI model metadata
  Map<String, dynamic>? getModelMetadata(String modelName) {
    return _metadata?['models']?[modelName];
  }

  /// Get available models
  List<String> getAvailableModels() {
    final models = _metadata?['models'];
    return models?.keys.toList() ?? [];
  }

  /// Check if AI service is available
  bool get isAvailable => _apiKey.isNotEmpty && _metadata != null;
} 