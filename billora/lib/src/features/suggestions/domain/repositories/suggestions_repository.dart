import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';

abstract class SuggestionsRepository {
  ResultFuture<List<Suggestion>> getProductSuggestions({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  });

  ResultFuture<void> recordProductUsage({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  });

  ResultFuture<void> recordCustomerUsage({
    required String customerId,
    required String customerName,
    required String email,
  });

  ResultFuture<void> syncSuggestions();
} 