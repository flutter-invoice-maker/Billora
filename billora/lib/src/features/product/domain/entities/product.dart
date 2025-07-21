class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final double tax;
  final int inventory;
  final bool isService;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.tax,
    required this.inventory,
    this.isService = false,
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
    );
  }
} 