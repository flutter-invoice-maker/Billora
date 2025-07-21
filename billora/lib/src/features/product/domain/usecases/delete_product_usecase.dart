import '../repositories/product_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  ResultFuture<void> call(String id) => repository.deleteProduct(id);
} 