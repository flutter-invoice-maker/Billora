import '../../domain/entities/product.dart';
import 'dart:math';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final double tax;
  final int inventory;
  final bool isService;
  final String? companyOrShopName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyEmail;
  final String? companyWebsite;
  final String? imageUrl;
  final String userId;
  final List<String> searchKeywords;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.tax,
    required this.inventory,
    this.isService = false,
    this.companyOrShopName,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.imageUrl,
    required this.userId,
    this.searchKeywords = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String generateUniqueId() {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(9999);
      return '${timestamp}_$random';
    }
    
    return ProductModel(
        id: json['id']?.toString().isNotEmpty == true ? json['id'].toString() : generateUniqueId(),
        name: json['name'] ?? '',
        description: json['description'],
        price: (json['price'] ?? 0).toDouble(),
        category: json['category'] ?? '',
        tax: (json['tax'] ?? 0).toDouble(),
        inventory: (json['inventory'] ?? 0).toInt(),
        isService: json['isService'] ?? false,
        companyOrShopName: json['companyOrShopName'],
        companyAddress: json['companyAddress'],
        companyPhone: json['companyPhone'],
        companyEmail: json['companyEmail'],
        companyWebsite: json['companyWebsite'],
        imageUrl: json['imageUrl'],
        userId: json['userId'] ?? '',
        searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
      );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null && description!.isNotEmpty) 'description': description,
        'price': price,
        'category': category,
        'tax': tax,
        'inventory': inventory,
        'isService': isService,
        if (companyOrShopName != null && companyOrShopName!.isNotEmpty) 'companyOrShopName': companyOrShopName,
        if (companyAddress != null && companyAddress!.isNotEmpty) 'companyAddress': companyAddress,
        if (companyPhone != null && companyPhone!.isNotEmpty) 'companyPhone': companyPhone,
        if (companyEmail != null && companyEmail!.isNotEmpty) 'companyEmail': companyEmail,
        if (companyWebsite != null && companyWebsite!.isNotEmpty) 'companyWebsite': companyWebsite,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
        'userId': userId,
        'searchKeywords': searchKeywords,
      };

  Product toEntity() => Product(
        id: id,
        name: name,
        description: description,
        price: price,
        category: category,
        tax: tax,
        inventory: inventory,
        isService: isService,
        companyOrShopName: companyOrShopName,
        companyAddress: companyAddress,
        companyPhone: companyPhone,
        companyEmail: companyEmail,
        companyWebsite: companyWebsite,
        imageUrl: imageUrl,
      );

  factory ProductModel.fromEntity(Product product, String userId) => ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        category: product.category,
        tax: product.tax,
        inventory: product.inventory,
        isService: product.isService,
        companyOrShopName: product.companyOrShopName,
        companyAddress: product.companyAddress,
        companyPhone: product.companyPhone,
        companyEmail: product.companyEmail,
        companyWebsite: product.companyWebsite,
        imageUrl: product.imageUrl,
        userId: userId,
      );
} 