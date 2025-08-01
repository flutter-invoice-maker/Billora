import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/suggestions/data/models/suggestion_model.dart';

abstract class SuggestionsRemoteDataSource {
  Future<List<SuggestionModel>> getProductSuggestions({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  });

  Future<List<SuggestionModel>> getCustomerSuggestions({
    String? searchQuery,
    int limit = 10,
  });

  Future<void> recordProductUsage({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  });

  Future<void> recordCustomerUsage({
    required String customerId,
    required String customerName,
    required String email,
    List<String>? productIds,
  });

  Future<void> syncSuggestions();
}

class SuggestionsRemoteDataSourceImpl implements SuggestionsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SuggestionsRemoteDataSourceImpl(this.firestore, this.auth);

  String get _userId => auth.currentUser?.uid ?? '';

  @override
  Future<List<SuggestionModel>> getProductSuggestions({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  }) async {
    try {
      debugPrint('🔍 Getting product suggestions for user: $_userId');
      debugPrint('🔍 CustomerId: $customerId, SearchQuery: $searchQuery');
      
      Query query = firestore
          .collection('suggestions')
          .doc(_userId)
          .collection('products')
          .orderBy('usageCount', descending: true)
          .limit(limit);

      // Remove customerId filter for now to avoid index issues
      // if (customerId != null) {
      //   query = query.where('customerId', isEqualTo: customerId);
      // }

      final querySnapshot = await query.get();
      debugPrint('🔍 Found ${querySnapshot.docs.length} suggestions in Firestore');
      
      final suggestions = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            debugPrint('🔍 Suggestion data: ${doc.id} - $data');
            return SuggestionModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();

      // Apply filters client-side
      var filteredSuggestions = suggestions;
      
      // Filter by customerId if provided
      if (customerId != null) {
        filteredSuggestions = filteredSuggestions.where((suggestion) => 
          suggestion.customerId == customerId
        ).toList();
      }

      // Apply search filter client-side if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredSuggestions = filteredSuggestions.where((suggestion) =>
            suggestion.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }

      debugPrint('🔍 Returning ${filteredSuggestions.length} filtered suggestions');
      return filteredSuggestions;
    } catch (e) {
      debugPrint('❌ Error getting product suggestions: $e');
      throw Exception('Failed to get product suggestions: $e');
    }
  }

  @override
  Future<List<SuggestionModel>> getCustomerSuggestions({
    String? searchQuery,
    int limit = 10,
  }) async {
    try {
      Query query = firestore
          .collection('suggestions')
          .doc(_userId)
          .collection('customers')
          .orderBy('usageCount', descending: true)
          .orderBy('lastUsed', descending: true)
          .limit(limit);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.orderBy('name');
      }

      final querySnapshot = await query.get();
      final suggestions = querySnapshot.docs
          .map((doc) => SuggestionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Apply search filter client-side if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        suggestions.removeWhere((suggestion) =>
            !suggestion.name.toLowerCase().contains(searchQuery.toLowerCase()));
      }

      return suggestions;
    } catch (e) {
      throw Exception('Failed to get customer suggestions: $e');
    }
  }

  @override
  Future<void> recordProductUsage({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  }) async {
    try {
      debugPrint('📝 Recording product usage: $productName (ID: $productId)');
      debugPrint('📝 CustomerId: $customerId, Price: $price, Currency: $currency');
      
      // Validate productId
      if (productId.isEmpty) {
        throw Exception('Product ID cannot be empty');
      }
      
      final docRef = firestore
          .collection('suggestions')
          .doc(_userId)
          .collection('products')
          .doc(productId);

      final now = DateTime.now();

      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          // Update existing suggestion
          final data = doc.data() as Map<String, dynamic>;
          final currentUsageCount = data['usageCount'] as int? ?? 0;
          debugPrint('📝 Updating existing suggestion. Current usage: $currentUsageCount');

          transaction.update(docRef, {
            'usageCount': currentUsageCount + 1,
            'lastUsed': now.millisecondsSinceEpoch,
            'price': price,
            'currency': currency,
            if (customerId != null) 'customerId': customerId,
          });
        } else {
          // Create new suggestion
          debugPrint('📝 Creating new suggestion for: $productName');
          transaction.set(docRef, {
            'name': productName,
            'type': 'product',
            'usageCount': 1,
            'lastUsed': now.millisecondsSinceEpoch,
            'createdAt': now.millisecondsSinceEpoch,
            'productId': productId,
            'price': price,
            'currency': currency,
            if (customerId != null) 'customerId': customerId,
          });
        }
      });
      
      debugPrint('✅ Successfully recorded product usage for: $productName');
    } catch (e) {
      debugPrint('❌ Error recording product usage: $e');
      throw Exception('Failed to record product usage: $e');
    }
  }

  @override
  Future<void> recordCustomerUsage({
    required String customerId,
    required String customerName,
    required String email,
    List<String>? productIds,
  }) async {
    try {
      final docRef = firestore
          .collection('suggestions')
          .doc(_userId)
          .collection('customers')
          .doc(customerId);

      final now = DateTime.now();

      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          // Update existing suggestion
          final data = doc.data() as Map<String, dynamic>;
          final currentUsageCount = data['usageCount'] as int? ?? 0;
          final currentCommonProducts = List<String>.from(data['commonProducts'] ?? []);

          // Add new product IDs to common products
          if (productIds != null) {
            for (final productId in productIds) {
              if (!currentCommonProducts.contains(productId)) {
                currentCommonProducts.add(productId);
              }
            }
          }

          transaction.update(docRef, {
            'usageCount': currentUsageCount + 1,
            'lastUsed': now.millisecondsSinceEpoch,
            'commonProducts': currentCommonProducts,
          });
        } else {
          // Create new suggestion
          transaction.set(docRef, {
            'name': customerName,
            'type': 'customer',
            'usageCount': 1,
            'lastUsed': now.millisecondsSinceEpoch,
            'createdAt': now.millisecondsSinceEpoch,
            'customerId': customerId,
            'email': email,
            'commonProducts': productIds ?? [],
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to record customer usage: $e');
    }
  }

  @override
  Future<void> syncSuggestions() async {
    // This method can be used for background sync operations
    // For now, we'll implement basic sync logic
    try {
      // Sync local cache with remote data
      // This can be expanded based on offline requirements
    } catch (e) {
      throw Exception('Failed to sync suggestions: $e');
    }
  }
} 