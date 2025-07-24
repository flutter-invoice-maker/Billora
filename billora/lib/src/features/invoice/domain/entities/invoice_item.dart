class InvoiceItem {
  final String id;
  final String name;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double tax;
  final double total;
  final String productId;

  InvoiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.tax,
    required this.total,
    required this.productId,
  });

  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? tax,
    double? total,
    String? productId,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      productId: productId ?? this.productId,
    );
  }
} 