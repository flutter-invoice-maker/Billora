import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/presentation/pages/customer_list_page.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/search_customers_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';

class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockCreateCustomerUseCase extends Mock implements CreateCustomerUseCase {}
class MockUpdateCustomerUseCase extends Mock implements UpdateCustomerUseCase {}
class MockDeleteCustomerUseCase extends Mock implements DeleteCustomerUseCase {}
class MockSearchCustomersUseCase extends Mock implements SearchCustomersUseCase {}

class FakeCustomer extends Fake implements Customer {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCustomer());
  });
  late CustomerCubit cubit;
  late MockGetCustomersUseCase getCustomersUseCase;
  late MockCreateCustomerUseCase createCustomerUseCase;
  late MockUpdateCustomerUseCase updateCustomerUseCase;
  late MockDeleteCustomerUseCase deleteCustomerUseCase;
  late MockSearchCustomersUseCase searchCustomersUseCase;

  setUp(() {
    getCustomersUseCase = MockGetCustomersUseCase();
    createCustomerUseCase = MockCreateCustomerUseCase();
    updateCustomerUseCase = MockUpdateCustomerUseCase();
    deleteCustomerUseCase = MockDeleteCustomerUseCase();
    searchCustomersUseCase = MockSearchCustomersUseCase();
    cubit = CustomerCubit(
      getCustomersUseCase: getCustomersUseCase,
      createCustomerUseCase: createCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
      searchCustomersUseCase: searchCustomersUseCase,
    );
    when(() => getCustomersUseCase.call()).thenAnswer((_) async => Right(<Customer>[]));
    when(() => createCustomerUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => updateCustomerUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => deleteCustomerUseCase.call(any())).thenAnswer((_) async => const Right(null));
    when(() => searchCustomersUseCase.call(any())).thenAnswer((_) async => Right(<Customer>[]));
  });

  testWidgets('CustomerListPage renders search box and add button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<CustomerCubit>.value(
          value: cubit,
          child: const CustomerListPage(),
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.textContaining('Customer'), findsWidgets);
  });
} 