import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_usecase.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late UpdateProductUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = UpdateProductUseCase(repository);
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

  test('should update product', () async {
    when(() => repository.updateProduct(product))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase(product);
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.updateProduct(product)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.updateProduct(product))
        .thenAnswer((_) async => Left(failure));
    final result = await usecase(product);
    expect(result, Left(failure));
    verify(() => repository.updateProduct(product)).called(1);
    verifyNoMoreInteractions(repository);
  });
} 