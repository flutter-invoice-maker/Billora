import '../repositories/product_repository.dart';
import 'package:billora/src/core/utils/typedef.dart';

class GetCategoriesUseCase {
  final ProductRepository repository;
  GetCategoriesUseCase(this.repository);

  ResultFuture<List<String>> call() => repository.getCategories();
} 