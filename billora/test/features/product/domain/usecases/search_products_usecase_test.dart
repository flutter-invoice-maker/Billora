import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/search_products_usecase.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late SearchProductsUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = SearchProductsUseCase(repository);
  });

  final products = [
    Product(
      id: '1',
      name: 'Test Product',
      price: 10.0,
      category: 'Test',
      tax: 0.0,
      inventory: 5,
      isService: false,
    ),
  ];

  test('should search products', () async {
    when(() => repository.searchProducts('query'))
        .thenAnswer((_) async => Right(products));
    final result = await usecase('query');
    expect(result, Right(products));
    verify(() => repository.searchProducts('query')).called(1);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.searchProducts('query'))
        .thenAnswer((_) async => Left(failure));
    final result = await usecase('query');
    expect(result, Left(failure));
    verify(() => repository.searchProducts('query')).called(1);
  });
} 