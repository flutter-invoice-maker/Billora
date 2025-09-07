class Product {
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
  final Map<String, dynamic> extraFields;

  Product({
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
    this.extraFields = const {},
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    double? tax,
    int? inventory,
    bool? isService,
    String? companyOrShopName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyWebsite,
    String? imageUrl,
    Map<String, dynamic>? extraFields,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      tax: tax ?? this.tax,
      inventory: inventory ?? this.inventory,
      isService: isService ?? this.isService,
      companyOrShopName: companyOrShopName ?? this.companyOrShopName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      imageUrl: imageUrl ?? this.imageUrl,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'tax': tax,
      'inventory': inventory,
      'isService': isService,
      'companyOrShopName': companyOrShopName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'companyWebsite': companyWebsite,
      'imageUrl': imageUrl,
      'extraFields': extraFields,
    };
  }
} 