import '../entities/product.dart';
import 'package:billora/src/core/utils/typedef.dart';

abstract class ProductRepository {
  ResultFuture<void> createProduct(Product product);
  ResultFuture<List<Product>> getProducts();
  ResultFuture<void> updateProduct(Product product);
  ResultFuture<void> deleteProduct(String id);
  ResultFuture<List<Product>> searchProducts(String query);
  ResultFuture<List<String>> getCategories();
} 