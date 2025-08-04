import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  ProductRepositoryImpl(this.remoteDatasource);

  @override
  ResultFuture<void> createProduct(Product product) async {
    debugPrint('🔄 ProductRepositoryImpl: Starting createProduct with ID: ${product.id}');
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      debugPrint('🔄 ProductRepositoryImpl: User ID: $userId');
      if (userId.isEmpty) {
        debugPrint('❌ ProductRepositoryImpl: User not authenticated');
        return Left(AuthFailure('User not authenticated'));
      }
      final model = ProductModel.fromEntity(product, userId);
      debugPrint('🔄 ProductRepositoryImpl: Created ProductModel with ID: ${model.id}');
      await remoteDatasource.createProduct(model);
      debugPrint('✅ ProductRepositoryImpl: Successfully created product with ID: ${product.id}');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ ProductRepositoryImpl: Error creating product: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Product>> getProducts() async {
    try {
      final models = await remoteDatasource.getProducts();
      final products = models.map((m) => m.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateProduct(Product product) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final model = ProductModel.fromEntity(product, userId);
      await remoteDatasource.updateProduct(model);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteProduct(String id) async {
    try {
      await remoteDatasource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateProductInventory(String productId, int quantity) async {
    debugPrint('🔄 ProductRepositoryImpl: Updating inventory for product $productId to $quantity');
    try {
      await remoteDatasource.updateProductInventory(productId, quantity);
      debugPrint('✅ ProductRepositoryImpl: Successfully updated inventory for product $productId to $quantity');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ ProductRepositoryImpl: Error updating inventory for product $productId: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Product>> searchProducts(String query) async {
    try {
      final models = await remoteDatasource.searchProducts(query);
      final products = models.map((m) => m.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<String>> getCategories() async {
    try {
      final categories = await remoteDatasource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
} 