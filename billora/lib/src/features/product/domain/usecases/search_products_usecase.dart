import '../repositories/product_repository.dart';
import '../entities/product.dart';
import 'package:billora/src/core/utils/typedef.dart';

class SearchProductsUseCase {
  final ProductRepository repository;
  SearchProductsUseCase(this.repository);

  ResultFuture<List<Product>> call(String query) => repository.searchProducts(query);
} 