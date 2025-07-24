import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';
import 'src/core/di/injection_container.dart';
import 'src/features/customer/presentation/pages/customer_list_page.dart';
import 'src/features/customer/presentation/cubit/customer_cubit.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:billora/src/features/product/domain/usecases/create_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/search_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_usecase.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/pages/product_catalog_page.dart';
import 'src/features/invoice/presentation/pages/invoice_list_page.dart';
import 'src/features/invoice/presentation/cubit/invoice_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: LoginPage(onLocaleChanged: setLocale),
      ),
      routes: {
        '/login': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: LoginPage(onLocaleChanged: setLocale),
            ),
        '/register': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: RegisterPage(onLocaleChanged: setLocale),
            ),
        '/home': (context) => HomePage(onLocaleChanged: setLocale),
        '/customers': (context) => BlocProvider(
              create: (context) => CustomerCubit(
                getCustomersUseCase: sl(),
                createCustomerUseCase: sl(),
                updateCustomerUseCase: sl(),
                deleteCustomerUseCase: sl(),
                searchCustomersUseCase: sl(),
              )..fetchCustomers(),
              child: const CustomerListPage(),
            ),
        '/products': (context) => BlocProvider(
              create: (_) => ProductCubit(
                getProductsUseCase: sl<GetProductsUseCase>(),
                createProductUseCase: sl<CreateProductUseCase>(),
                updateProductUseCase: sl<UpdateProductUseCase>(),
                deleteProductUseCase: sl<DeleteProductUseCase>(),
                searchProductsUseCase: sl<SearchProductsUseCase>(),
                getCategoriesUseCase: sl<GetCategoriesUseCase>(),
              ),
              child: const ProductCatalogPage(),
            ),
        '/invoices': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<InvoiceCubit>(create: (_) => sl<InvoiceCubit>()..fetchInvoices()),
                BlocProvider<CustomerCubit>(create: (_) => sl<CustomerCubit>()..fetchCustomers()),
                BlocProvider<ProductCubit>(create: (_) => sl<ProductCubit>()..fetchProducts()),
              ],
              child: const InvoiceListPage(),
            ),
      },
    );
  }
}
