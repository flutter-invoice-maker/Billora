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
      extraFields: extraFields ?? this.extraFields,
    );
  }
} 