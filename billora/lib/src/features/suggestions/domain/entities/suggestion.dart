import 'package:equatable/equatable.dart';

class Suggestion extends Equatable {
  final String id;
  final String name;
  final String type; // 'product' or 'customer'
  final int usageCount;
  final DateTime lastUsed;
  final DateTime createdAt;
  final String? customerId;
  final String? productId;
  final double? price;
  final String? currency;
  final List<String>? commonProducts;
  final String? email;
  final Map<String, dynamic>? metadata;

  const Suggestion({
    required this.id,
    required this.name,
    required this.type,
    required this.usageCount,
    required this.lastUsed,
    required this.createdAt,
    this.customerId,
    this.productId,
    this.price,
    this.currency,
    this.commonProducts,
    this.email,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        usageCount,
        lastUsed,
        createdAt,
        customerId,
        productId,
        price,
        currency,
        commonProducts,
        email,
        metadata,
      ];

  Suggestion copyWith({
    String? id,
    String? name,
    String? type,
    int? usageCount,
    DateTime? lastUsed,
    DateTime? createdAt,
    String? customerId,
    String? productId,
    double? price,
    String? currency,
    List<String>? commonProducts,
    String? email,
    Map<String, dynamic>? metadata,
  }) {
    return Suggestion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      commonProducts: commonProducts ?? this.commonProducts,
      email: email ?? this.email,
      metadata: metadata ?? this.metadata,
    );
  }

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

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
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
}

class SuggestionScore extends Equatable {
  final Suggestion suggestion;
  final double score;
  final double usageScore;
  final double recencyScore;
  final double relevanceScore;
  final double similarityScore;

  const SuggestionScore({
    required this.suggestion,
    required this.score,
    required this.usageScore,
    required this.recencyScore,
    required this.relevanceScore,
    required this.similarityScore,
  });

  @override
  List<Object?> get props => [
        suggestion,
        score,
        usageScore,
        recencyScore,
        relevanceScore,
        similarityScore,
      ];
} 