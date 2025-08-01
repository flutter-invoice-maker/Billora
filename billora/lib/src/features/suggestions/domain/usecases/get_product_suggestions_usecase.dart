import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';
import 'package:billora/src/features/suggestions/domain/repositories/suggestions_repository.dart';

@injectable
class GetProductSuggestionsUseCase {
  final SuggestionsRepository repository;

  GetProductSuggestionsUseCase(this.repository);

  ResultFuture<List<Suggestion>> call({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  }) async {
    return await repository.getProductSuggestions(
      customerId: customerId,
      searchQuery: searchQuery,
      limit: limit,
    );
  }
} 