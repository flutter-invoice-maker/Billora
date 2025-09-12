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
import '../../../../core/utils/logger.dart';

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
    if (isClosed) return;
    
    Logger.productOperation('fetch products');
    emit(const ProductState.loading());
    final result = await getProductsUseCase();
    if (isClosed) return;
    result.fold(
      (failure) {
        Logger.productError('fetch products', Exception(failure.message));
        emit(ProductState.error(failure.message));
      },
      (products) {
        Logger.productSuccess('fetch products', productName: '${products.length} products');
        emit(ProductState.loaded(products));
      },
    );
  }

  Future<void> addProduct(Product product) async {
    if (isClosed) return;
    
    Logger.productOperation('add product', productId: product.id, productName: product.name);
    emit(const ProductState.loading());
    final result = await createProductUseCase(product);
    if (isClosed) return;
    result.fold(
      (failure) {
        Logger.productError('add product', Exception(failure.message), productId: product.id);
        emit(ProductState.error(failure.message));
      },
      (_) {
        Logger.productSuccess('add product', productId: product.id, productName: product.name);
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
    if (isClosed) return;
    
    Logger.productOperation('update inventory', productId: productId);
    final result = await updateProductInventoryUseCase(productId, quantity);
    if (isClosed) return;
    result.fold(
      (failure) {
        Logger.productError('update inventory', Exception(failure.message), productId: productId);
        emit(ProductState.error(failure.message));
      },
      (_) {
        Logger.productSuccess('update inventory', productId: productId);
        fetchProducts(); // Refresh products after inventory update
      },
    );
  }

  Future<List<String>> getCategories() async {
    final result = await getCategoriesUseCase();
    return result.fold((failure) => [], (categories) => categories);
  }

  Future<void> addProductsFromScan(List<Map<String, dynamic>> scanProducts) async {
    if (isClosed) return;
    
    Logger.productOperation('add products from scan', productName: '${scanProducts.length} products');
    emit(const ProductState.loading());
    
    try {
      int successCount = 0;
      int failureCount = 0;
      
      for (final productData in scanProducts) {
        try {
          // Create Product entity from scan data
          final product = Product(
            id: '${DateTime.now().millisecondsSinceEpoch}_$successCount',
            name: productData['name']?.toString() ?? 'Unknown Product',
            description: productData['description']?.toString(),
            price: double.tryParse(productData['price']?.toString() ?? '0') ?? 0.0,
            category: productData['category']?.toString() ?? 'professional_business',
            inventory: int.tryParse(productData['inventory']?.toString() ?? '1') ?? 1,
            isService: productData['isService'] == true,
            tax: double.tryParse(productData['tax']?.toString() ?? '0') ?? 0.0,
            companyOrShopName: productData['companyOrShopName']?.toString(),
          );
          
          final result = await createProductUseCase(product);
          result.fold(
            (failure) {
              Logger.productError('add product from scan', Exception(failure.message), productId: product.id);
              failureCount++;
            },
            (_) {
              Logger.productSuccess('add product from scan', productId: product.id, productName: product.name);
              successCount++;
            },
          );
        } catch (e) {
          Logger.productError('process product data', e);
          failureCount++;
        }
      }
      
      if (isClosed) return;
      
      // Refresh products list
      await fetchProducts();
      
      Logger.productSuccess('add products from scan', productName: 'Success: $successCount, Failed: $failureCount');
      
    } catch (e) {
      if (isClosed) return;
      Logger.productError('add products from scan', e);
      emit(ProductState.error('Failed to add products from scan: $e'));
    }
  }
} 