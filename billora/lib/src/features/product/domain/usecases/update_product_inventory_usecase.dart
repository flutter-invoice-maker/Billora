import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateProductInventoryUseCase {
  final ProductRepository repository;

  UpdateProductInventoryUseCase(this.repository);

  ResultFuture<void> call(String productId, int quantity) async {
    return await repository.updateProductInventory(productId, quantity);
  }
} 