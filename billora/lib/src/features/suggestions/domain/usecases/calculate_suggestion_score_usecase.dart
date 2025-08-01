import 'package:injectable/injectable.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';

@injectable
class CalculateSuggestionScoreUseCase {
  double call({
    required Suggestion suggestion,
    String? searchQuery,
    String? currentCustomerId,
  }) {
    final usageScore = _calculateUsageScore(suggestion.usageCount);
    final recencyScore = _calculateRecencyScore(suggestion.lastUsed);
    final relevanceScore = _calculateRelevanceScore(suggestion, currentCustomerId);
    final similarityScore = _calculateSimilarityScore(suggestion.name, searchQuery);

    // Weighted scoring system
    final totalScore = (usageScore * 0.4) +
        (recencyScore * 0.3) +
        (relevanceScore * 0.2) +
        (similarityScore * 0.1);

    return totalScore;
  }

  double _calculateUsageScore(int usageCount) {
    // Normalize usage count to 0-1 range
    // More usage = higher score
    return (usageCount / (usageCount + 10)).clamp(0.0, 1.0);
  }

  double _calculateRecencyScore(DateTime lastUsed) {
    final now = DateTime.now();
    final daysSinceLastUsed = now.difference(lastUsed).inDays;
    
    // Recent usage gets higher score
    // Exponential decay: e^(-days/30)
    return (1.0 / (1.0 + (daysSinceLastUsed / 30.0))).clamp(0.0, 1.0);
  }

  double _calculateRelevanceScore(Suggestion suggestion, String? currentCustomerId) {
    if (currentCustomerId == null || suggestion.customerId == null) {
      return 0.5; // Neutral score if no customer context
    }

    // Check if this suggestion is relevant to current customer
    if (suggestion.customerId == currentCustomerId) {
      return 1.0; // High relevance
    }

    // Check if current customer has used this product before
    if (suggestion.commonProducts?.contains(currentCustomerId) == true) {
      return 0.8; // Medium-high relevance
    }

    return 0.3; // Low relevance
  }

  double _calculateSimilarityScore(String suggestionName, String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return 0.5; // Neutral score if no search query
    }

    // Simple string similarity using Levenshtein distance
    final distance = _levenshteinDistance(
      searchQuery.toLowerCase(),
      suggestionName.toLowerCase(),
    );

    final maxLength = searchQuery.length > suggestionName.length
        ? searchQuery.length
        : suggestionName.length;

    if (maxLength == 0) return 1.0;

    // Convert distance to similarity score (0-1)
    final similarity = 1.0 - (distance / maxLength);
    return similarity.clamp(0.0, 1.0);
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final List<int> v0 = List<int>.filled(s2.length + 1, 0);
    final List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        final cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }

      // Swap arrays instead of clearing and adding
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[s2.length];
  }
} 