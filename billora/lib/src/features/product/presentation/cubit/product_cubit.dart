import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_product_inventory_usecase.dart';
import 'product_state.dart';
import 'package:flutter/foundation.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateProductInventoryUseCase updateProductInventoryUseCase;

  ProductCubit({
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.searchProductsUseCase,
    required this.getCategoriesUseCase,
    required this.updateProductInventoryUseCase,
  }) : super(const ProductState.initial());

  Future<void> fetchProducts() async {
    debugPrint('🔄 ProductCubit: Starting fetchProducts');
    if (isClosed) return;
    emit(const ProductState.loading());
    final result = await getProductsUseCase();
    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('❌ ProductCubit: fetchProducts failed: ${failure.message}');
        emit(ProductState.error(failure.message));
      },
      (products) {
        debugPrint('✅ ProductCubit: fetchProducts successful, loaded ${products.length} products');
        emit(ProductState.loaded(products));
      },
    );
  }

  Future<void> addProduct(Product product) async {
    debugPrint('🔄 ProductCubit: Starting addProduct with ID: ${product.id}');
    if (isClosed) return;
    emit(const ProductState.loading());
    final result = await createProductUseCase(product);
    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('❌ ProductCubit: addProduct failed: ${failure.message}');
        emit(ProductState.error(failure.message));
      },
      (_) {
        debugPrint('✅ ProductCubit: addProduct successful, refreshing products');
        fetchProducts();
      },
    );
  }

  Future<void> updateProduct(Product product) async {
    if (isClosed) return;
    emit(const ProductState.loading());
    final result = await updateProductUseCase(product);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (_) => fetchProducts(),
    );
  }

  Future<void> deleteProduct(String id) async {
    if (isClosed) return;
    emit(const ProductState.loading());
    final result = await deleteProductUseCase(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (_) => fetchProducts(),
    );
  }

  Future<void> searchProducts(String query) async {
    if (isClosed) return;
    emit(const ProductState.loading());
    final result = await searchProductsUseCase(query);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (products) => emit(ProductState.loaded(products)),
    );
  }

  Future<void> updateProductInventory(String productId, int quantity) async {
    debugPrint('🔄 ProductCubit: Starting inventory update for product $productId to $quantity');
    if (isClosed) return;
    final result = await updateProductInventoryUseCase(productId, quantity);
    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('❌ ProductCubit: Inventory update failed for product $productId: ${failure.message}');
        emit(ProductState.error(failure.message));
      },
      (_) {
        debugPrint('✅ ProductCubit: Inventory update successful for product $productId, refreshing products');
        fetchProducts(); // Refresh products after inventory update
      },
    );
  }

  Future<List<String>> getCategories() async {
    final result = await getCategoriesUseCase();
    return result.fold((failure) => [], (categories) => categories);
  }
} 