import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late DeleteProductUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = DeleteProductUseCase(repository);
  });

  test('should delete product', () async {
    when(() => repository.deleteProduct('1'))
        .thenAnswer((_) async => const Right(null));
    final result = await usecase('1');
    expect(result, const Right<Failure, void>(null));
    verify(() => repository.deleteProduct('1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.deleteProduct('1'))
        .thenAnswer((_) async => Left(failure));
    final result = await usecase('1');
    expect(result, Left(failure));
    verify(() => repository.deleteProduct('1')).called(1);
    verifyNoMoreInteractions(repository);
  });
} 