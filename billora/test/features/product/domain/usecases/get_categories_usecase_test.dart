import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetCategoriesUseCase usecase;
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
    usecase = GetCategoriesUseCase(repository);
  });

  final categories = ['Category1', 'Category2'];

  test('should get categories', () async {
    when(() => repository.getCategories())
        .thenAnswer((_) async => Right(categories));
    final result = await usecase();
    expect(result, Right(categories));
    verify(() => repository.getCategories()).called(1);
  });

  test('should return failure when repository fails', () async {
    final failure = AuthFailure('error');
    when(() => repository.getCategories())
        .thenAnswer((_) async => Left(failure));
    final result = await usecase();
    expect(result, Left(failure));
    verify(() => repository.getCategories()).called(1);
  });
} 