import '../repositories/product_repository.dart';
import '../entities/product.dart';
import 'package:billora/src/core/utils/typedef.dart';

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  ResultFuture<void> call(Product product) => repository.updateProduct(product);
} 