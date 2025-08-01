import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';
import 'package:billora/src/features/suggestions/domain/usecases/get_product_suggestions_usecase.dart';
import 'package:billora/src/features/suggestions/domain/usecases/record_product_usage_usecase.dart';
import 'package:billora/src/features/suggestions/domain/usecases/calculate_suggestion_score_usecase.dart';

part 'suggestions_state.dart';

@injectable
class SuggestionsCubit extends Cubit<SuggestionsState> {
  final GetProductSuggestionsUseCase getProductSuggestionsUseCase;
  final RecordProductUsageUseCase recordProductUsageUseCase;
  final CalculateSuggestionScoreUseCase calculateSuggestionScoreUseCase;

  SuggestionsCubit({
    required this.getProductSuggestionsUseCase,
    required this.recordProductUsageUseCase,
    required this.calculateSuggestionScoreUseCase,
  }) : super(SuggestionsInitial());

  Future<void> getProductSuggestions({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  }) async {
    if (isClosed) return;
    debugPrint('🎯 SuggestionsCubit: Getting product suggestions');
    debugPrint('🎯 CustomerId: $customerId, SearchQuery: $searchQuery, Limit: $limit');
    
    emit(SuggestionsLoading());

    final result = await getProductSuggestionsUseCase(
      customerId: customerId,
      searchQuery: searchQuery,
      limit: limit,
    );

    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('❌ SuggestionsCubit: Error - ${failure.message}');
        emit(SuggestionsError(failure.message));
      },
      (suggestions) {
        debugPrint('✅ SuggestionsCubit: Got ${suggestions.length} suggestions');
        
        // Calculate scores for suggestions
        final scoredSuggestions = suggestions.map((suggestion) {
          final score = calculateSuggestionScoreUseCase(
            suggestion: suggestion,
            searchQuery: searchQuery,
            currentCustomerId: customerId,
          );
          return SuggestionScore(
            suggestion: suggestion,
            score: score,
            usageScore: 0.0, // These would be calculated in the usecase
            recencyScore: 0.0,
            relevanceScore: 0.0,
            similarityScore: 0.0,
          );
        }).toList();

        // Sort by score
        scoredSuggestions.sort((a, b) => b.score.compareTo(a.score));
        
        debugPrint('✅ SuggestionsCubit: Emitting ${scoredSuggestions.length} scored suggestions');
        emit(SuggestionsLoaded(scoredSuggestions));
      },
    );
  }

  Future<void> recordProductUsage({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  }) async {
    if (isClosed) return;
    debugPrint('📝 SuggestionsCubit: Recording product usage for $productName');
    
    final result = await recordProductUsageUseCase(
      productId: productId,
      productName: productName,
      price: price,
      currency: currency,
      customerId: customerId,
    );

    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('❌ SuggestionsCubit: Error recording usage - ${failure.message}');
        emit(SuggestionsError(failure.message));
      },
      (_) {
        debugPrint('✅ SuggestionsCubit: Successfully recorded product usage');
        // Optionally refresh suggestions after recording usage
        if (state is SuggestionsLoaded) {
          final currentState = state as SuggestionsLoaded;
          getProductSuggestions(
            customerId: customerId,
            limit: currentState.suggestions.isNotEmpty ? currentState.suggestions.length : 20,
          );
        }
      },
    );
  }

  Future<void> loadInitialSuggestions({String? customerId}) async {
    if (isClosed) return;
    debugPrint('🎯 SuggestionsCubit: Loading initial suggestions');
    await getProductSuggestions(
      customerId: customerId,
      limit: 20,
    );
  }

  Future<void> loadSuggestionsForCustomer(String customerId) async {
    if (isClosed) return;
    debugPrint('🎯 SuggestionsCubit: Loading suggestions for customer: $customerId');
    await getProductSuggestions(
      customerId: customerId,
      limit: 20,
    );
  }
} 