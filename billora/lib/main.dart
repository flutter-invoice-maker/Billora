import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';

import 'src/core/di/injection_container.dart';
import 'src/features/customer/presentation/pages/customer_list_page.dart';
import 'src/features/customer/presentation/cubit/customer_cubit.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:billora/src/features/product/domain/usecases/create_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/search_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_inventory_usecase.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/pages/product_catalog_page.dart';
import 'src/features/invoice/presentation/pages/invoice_list_page.dart';
import 'src/features/invoice/presentation/pages/invoice_form_page.dart';
import 'src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'src/features/bill_scanner/presentation/pages/image_upload_page.dart';
import 'src/features/bill_scanner/presentation/pages/enhanced_image_upload_page.dart';
// import 'src/features/bill_scanner/presentation/cubit/bill_scanner_cubit.dart';
import 'src/features/suggestions/presentation/pages/suggestions_demo_page.dart';
import 'src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'src/features/tags/presentation/cubit/tags_cubit.dart';
import 'src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'src/features/bill_scanner/presentation/pages/scan_library_page.dart';
import 'src/features/bill_scanner/presentation/cubit/scan_library_cubit.dart';

import 'package:billora/src/features/invoice/domain/usecases/generate_summary_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/suggest_tags_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/classify_invoice_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (ignore errors on web if asset not bundled)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
    debugPrint('🔑 API Key loaded: ${dotenv.env['OPENAI_API_KEY']?.substring(0, 7) ?? 'NOT_FOUND'}...');
  } catch (e) {
    debugPrint('❌ Failed to load .env file: $e');
    debugPrint('⚠️ Make sure .env file exists in project root with OPENAI_API_KEY');
  }
  
  // Initialize Firebase safely across platforms
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      // Ignore duplicate-app or rethrow others
      if (e.code != 'duplicate-app') rethrow;
    }
  }

  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: const OnboardingPage(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: LoginPage(),
            ),
        '/register': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: RegisterPage(),
            ),
        '/home': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<DashboardCubit>(create: (_) => sl<DashboardCubit>()),
              ],
              child: HomePage(),
            ),
        '/customers': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<CustomerCubit>(
                  create: (context) => CustomerCubit(
                    getCustomersUseCase: sl(),
                    createCustomerUseCase: sl(),
                    updateCustomerUseCase: sl(),
                    deleteCustomerUseCase: sl(),
                    searchCustomersUseCase: sl(),
                  )..fetchCustomers(),
                ),
              ],
              child: const CustomerListPage(),
            ),
        '/products': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<ProductCubit>(
                  create: (_) => ProductCubit(
                    getProductsUseCase: sl<GetProductsUseCase>(),
                    createProductUseCase: sl<CreateProductUseCase>(),
                    updateProductUseCase: sl<UpdateProductUseCase>(),
                    deleteProductUseCase: sl<DeleteProductUseCase>(),
                    searchProductsUseCase: sl<SearchProductsUseCase>(),
                    getCategoriesUseCase: sl<GetCategoriesUseCase>(),
                    updateProductInventoryUseCase: sl<UpdateProductInventoryUseCase>(),
                  ),
                ),
              ],
              child: const ProductCatalogPage(),
            ),
        '/invoices': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<InvoiceCubit>(create: (_) => sl<InvoiceCubit>()..fetchInvoices()),
                BlocProvider<CustomerCubit>(create: (_) => sl<CustomerCubit>()..fetchCustomers()),
                BlocProvider<ProductCubit>(create: (_) => sl<ProductCubit>()..fetchProducts()),
                BlocProvider<SuggestionsCubit>(create: (_) => sl<SuggestionsCubit>()),
                BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
                // Add AI UseCase providers
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
                Provider<SuggestTagsUseCase>(create: (_) => sl<SuggestTagsUseCase>()),
                Provider<ClassifyInvoiceUseCase>(create: (_) => sl<ClassifyInvoiceUseCase>()),
              ],
              child: const InvoiceListPage(),
            ),
        '/invoice-form': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<InvoiceCubit>(create: (_) => sl<InvoiceCubit>()),
                BlocProvider<CustomerCubit>(create: (_) => sl<CustomerCubit>()..fetchCustomers()),
                BlocProvider<ProductCubit>(create: (_) => sl<ProductCubit>()..fetchProducts()),
                BlocProvider<SuggestionsCubit>(create: (_) => sl<SuggestionsCubit>()),
                BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
                Provider<SuggestTagsUseCase>(create: (_) => sl<SuggestTagsUseCase>()),
                Provider<ClassifyInvoiceUseCase>(create: (_) => sl<ClassifyInvoiceUseCase>()),
              ],
              child: const InvoiceFormPage(),
            ),
        // '/bill-scanner': (context) => BlocProvider(
        //       create: (context) => sl<BillScannerCubit>(),
        //       child: const BillScannerHubPage(),
        //     ),
        '/bill-scanner': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const ImageUploadPage(),
            ),
        '/enhanced-bill-scanner': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const EnhancedImageUploadPage(),
            ),
        '/scan-library': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<ScanLibraryCubit>(create: (_) => sl<ScanLibraryCubit>()),
                // Add AI UseCase providers for scan library
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
                Provider<SuggestTagsUseCase>(create: (_) => sl<SuggestTagsUseCase>()),
                Provider<ClassifyInvoiceUseCase>(create: (_) => sl<ClassifyInvoiceUseCase>()),
              ],
              child: const ScanLibraryPage(),
            ),
        '/suggestions-demo': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<SuggestionsCubit>(create: (_) => sl<SuggestionsCubit>()),
                BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
              ],
              child: const SuggestionsDemoPage(),
            ),
        '/dashboard': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<DashboardCubit>(create: (_) => sl<DashboardCubit>()),
                BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
                BlocProvider<InvoiceCubit>(create: (_) => sl<InvoiceCubit>()..fetchInvoices()),
                BlocProvider.value(value: sl<CustomerCubit>()),
                BlocProvider<ProductCubit>(create: (_) => sl<ProductCubit>()..fetchProducts()),
              ],
              child: const DashboardPage(),
            ),
      },
    );
  }
}
