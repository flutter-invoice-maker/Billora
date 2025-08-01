import 'package:flutter_test/flutter_test.dart';
import 'package:billora/src/features/suggestions/domain/usecases/calculate_suggestion_score_usecase.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';

void main() {
  late CalculateSuggestionScoreUseCase useCase;

  setUp(() {
    useCase = CalculateSuggestionScoreUseCase();
  });

  group('CalculateSuggestionScoreUseCase', () {
    test('should calculate higher score for frequently used products', () {
      // Arrange
      final frequentProduct = Suggestion(
        id: '1',
        name: 'Frequent Product',
        type: 'product',
        usageCount: 50,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final rareProduct = Suggestion(
        id: '2',
        name: 'Rare Product',
        type: 'product',
        usageCount: 2,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Act
      final frequentScore = useCase(
        suggestion: frequentProduct,
        searchQuery: null,
        currentCustomerId: null,
      );

      final rareScore = useCase(
        suggestion: rareProduct,
        searchQuery: null,
        currentCustomerId: null,
      );

      // Assert
      expect(frequentScore, greaterThan(rareScore));
    });

    test('should calculate higher score for recently used products', () {
      // Arrange
      final recentProduct = Suggestion(
        id: '1',
        name: 'Recent Product',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final oldProduct = Suggestion(
        id: '2',
        name: 'Old Product',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );

      // Act
      final recentScore = useCase(
        suggestion: recentProduct,
        searchQuery: null,
        currentCustomerId: null,
      );

      final oldScore = useCase(
        suggestion: oldProduct,
        searchQuery: null,
        currentCustomerId: null,
      );

      // Assert
      expect(recentScore, greaterThan(oldScore));
    });

    test('should calculate higher score for customer-relevant products', () {
      // Arrange
      final customerId = 'customer-123';
      
      final relevantProduct = Suggestion(
        id: '1',
        name: 'Relevant Product',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        customerId: customerId,
      );

      final irrelevantProduct = Suggestion(
        id: '2',
        name: 'Irrelevant Product',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        customerId: 'different-customer',
      );

      // Act
      final relevantScore = useCase(
        suggestion: relevantProduct,
        searchQuery: null,
        currentCustomerId: customerId,
      );

      final irrelevantScore = useCase(
        suggestion: irrelevantProduct,
        searchQuery: null,
        currentCustomerId: customerId,
      );

      // Assert
      expect(relevantScore, greaterThan(irrelevantScore));
    });

    test('should calculate higher score for text-similar products', () {
      // Arrange
      final searchQuery = 'laptop';
      
      final similarProduct = Suggestion(
        id: '1',
        name: 'Gaming Laptop',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final differentProduct = Suggestion(
        id: '2',
        name: 'Coffee Mug',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Act
      final similarScore = useCase(
        suggestion: similarProduct,
        searchQuery: searchQuery,
        currentCustomerId: null,
      );

      final differentScore = useCase(
        suggestion: differentProduct,
        searchQuery: searchQuery,
        currentCustomerId: null,
      );

      // Assert
      expect(similarScore, greaterThan(differentScore));
    });

    test('should return score between 0 and 1', () {
      // Arrange
      final suggestion = Suggestion(
        id: '1',
        name: 'Test Product',
        type: 'product',
        usageCount: 10,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Act
      final score = useCase(
        suggestion: suggestion,
        searchQuery: null,
        currentCustomerId: null,
      );

      // Assert
      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(1.0));
    });
  });
} 