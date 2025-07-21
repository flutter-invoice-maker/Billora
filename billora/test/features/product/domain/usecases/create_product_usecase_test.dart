import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/create_product_usecase.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late CreateProductUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = CreateProductUseCase(repository);
  });

  final product = Product(
    id: '1',
    name: 'Test Product',
    price: 10.0,
    category: 'Test',
    tax: 0.0,
    inventory: 5,
    isService: false,
  );

  test('should create product', () async {
    when(() => repository.createProduct(product))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase(product);
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.createProduct(product)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.createProduct(product))
        .thenAnswer((_) async => Left(failure));
    final result = await usecase(product);
    expect(result, Left(failure));
    verify(() => repository.createProduct(product)).called(1);
    verifyNoMoreInteractions(repository);
  });
} 