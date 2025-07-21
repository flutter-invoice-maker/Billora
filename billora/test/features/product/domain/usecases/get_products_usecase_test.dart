import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/get_products_usecase.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = GetProductsUseCase(repository);
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

  test('should get products', () async {
    when(() => repository.getProducts())
        .thenAnswer((_) async => Right(products));
    final result = await usecase();
    expect(result, Right(products));
    verify(() => repository.getProducts()).called(1);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.getProducts())
        .thenAnswer((_) async => Left(failure));
    final result = await usecase();
    expect(result, Left(failure));
    verify(() => repository.getProducts()).called(1);
  });
} 