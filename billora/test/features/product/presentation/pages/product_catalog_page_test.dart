import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/product/presentation/pages/product_catalog_page.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/domain/usecases/get_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/create_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/search_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_inventory_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockCreateProductUseCase extends Mock implements CreateProductUseCase {}
class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}
class MockDeleteProductUseCase extends Mock implements DeleteProductUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockUpdateProductInventoryUseCase extends Mock implements UpdateProductInventoryUseCase {}

class FakeProduct extends Fake implements Product {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProduct());
  });
  late ProductCubit cubit;
  late MockGetProductsUseCase getProductsUseCase;
  late MockCreateProductUseCase createProductUseCase;
  late MockUpdateProductUseCase updateProductUseCase;
  late MockDeleteProductUseCase deleteProductUseCase;
  late MockSearchProductsUseCase searchProductsUseCase;
  late MockGetCategoriesUseCase getCategoriesUseCase;
  late MockUpdateProductInventoryUseCase updateProductInventoryUseCase;

  setUp(() {
    getProductsUseCase = MockGetProductsUseCase();
    createProductUseCase = MockCreateProductUseCase();
    updateProductUseCase = MockUpdateProductUseCase();
    deleteProductUseCase = MockDeleteProductUseCase();
    searchProductsUseCase = MockSearchProductsUseCase();
    getCategoriesUseCase = MockGetCategoriesUseCase();
    updateProductInventoryUseCase = MockUpdateProductInventoryUseCase();
    cubit = ProductCubit(
      getProductsUseCase: getProductsUseCase,
      createProductUseCase: createProductUseCase,
      updateProductUseCase: updateProductUseCase,
      deleteProductUseCase: deleteProductUseCase,
      searchProductsUseCase: searchProductsUseCase,
      getCategoriesUseCase: getCategoriesUseCase,
      updateProductInventoryUseCase: updateProductInventoryUseCase,
    );
    when(() => getProductsUseCase.call()).thenAnswer((_) async => Right(<Product>[]));
    when(() => createProductUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => updateProductUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => deleteProductUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => searchProductsUseCase.call(any())).thenAnswer((_) async => Right(<Product>[]));
    when(() => getCategoriesUseCase.call()).thenAnswer((_) async => Right(<String>[]));
  });

  testWidgets('ProductCatalogPage renders search box, category dropdown, and add button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ProductCubit>.value(
          value: cubit,
          child: const ProductCatalogPage(),
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.textContaining('Product'), findsWidgets);
  });
} 