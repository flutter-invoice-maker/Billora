import '../repositories/product_repository.dart';
import '../entities/product.dart';
import 'package:billora/src/core/utils/typedef.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  ResultFuture<List<Product>> call() => repository.getProducts();
} 