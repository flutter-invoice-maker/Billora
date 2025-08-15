import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';

class SuggestionModel extends Suggestion {
  const SuggestionModel({
    required super.id,
    required super.name,
    required super.type,
    required super.usageCount,
    required super.lastUsed,
    required super.createdAt,
    super.customerId,
    super.productId,
    super.price,
    super.currency,
    super.commonProducts,
    super.email,
    super.metadata,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      usageCount: json['usageCount'] as int,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(json['lastUsed'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      customerId: json['customerId'] as String?,
      productId: json['productId'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      commonProducts: (json['commonProducts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      email: json['email'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory SuggestionModel.fromEntity(Suggestion suggestion) {
    return SuggestionModel(
      id: suggestion.id,
      name: suggestion.name,
      type: suggestion.type,
      usageCount: suggestion.usageCount,
      lastUsed: suggestion.lastUsed,
      createdAt: suggestion.createdAt,
      customerId: suggestion.customerId,
      productId: suggestion.productId,
      price: suggestion.price,
      currency: suggestion.currency,
      commonProducts: suggestion.commonProducts,
      email: suggestion.email,
      metadata: suggestion.metadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'usageCount': usageCount,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'customerId': customerId,
      'productId': productId,
      'price': price,
      'currency': currency,
      'commonProducts': commonProducts,
      'email': email,
      'metadata': metadata,
    };
  }
} 