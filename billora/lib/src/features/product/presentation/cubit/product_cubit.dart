import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductCubit({
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.searchProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(const ProductState.initial());

  Future<void> fetchProducts() async {
    emit(const ProductState.loading());
    final result = await getProductsUseCase();
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (products) => emit(ProductState.loaded(products)),
    );
  }

  Future<void> addProduct(Product product) async {
    emit(const ProductState.loading());
    final result = await createProductUseCase(product);
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (_) => fetchProducts(),
    );
  }

  Future<void> updateProduct(Product product) async {
    emit(const ProductState.loading());
    final result = await updateProductUseCase(product);
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (_) => fetchProducts(),
    );
  }

  Future<void> deleteProduct(String id) async {
    emit(const ProductState.loading());
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (_) => fetchProducts(),
    );
  }

  Future<void> searchProducts(String query) async {
    emit(const ProductState.loading());
    final result = await searchProductsUseCase(query);
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (products) => emit(ProductState.loaded(products)),
    );
  }

  Future<List<String>> getCategories() async {
    final result = await getCategoriesUseCase();
    return result.fold((failure) => [], (categories) => categories);
  }
} 