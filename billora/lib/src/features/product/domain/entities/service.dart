import 'product.dart';

class Service extends Product {
  Service({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.category,
    super.tax = 0.0,
  }) : super(
    inventory: 0,
    isService: true,
  );
} 