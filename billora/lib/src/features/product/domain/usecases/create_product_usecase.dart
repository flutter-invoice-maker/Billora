import '../repositories/product_repository.dart';
import '../entities/product.dart';
import 'package:billora/src/core/utils/typedef.dart';

class CreateProductUseCase {
  final ProductRepository repository;
  CreateProductUseCase(this.repository);

  ResultFuture<void> call(Product product) => repository.createProduct(product);
} 