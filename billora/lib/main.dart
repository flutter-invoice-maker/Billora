import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:dart_openai/dart_openai.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';

import 'src/core/di/injection_container.dart';
import 'src/features/customer/presentation/pages/customer_list_page.dart';
import 'src/features/customer/presentation/cubit/customer_cubit.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/onboarding/presentation/pages/onboarding_page.dart';








import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/pages/product_catalog_page.dart';
import 'package:billora/src/features/product/presentation/pages/product_form_page.dart';
import 'src/features/invoice/presentation/pages/invoice_list_page.dart';
import 'src/features/invoice/presentation/pages/invoice_form_page.dart';
import 'src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'src/features/bill_scanner/presentation/pages/image_upload_page.dart';
import 'src/features/bill_scanner/presentation/pages/enhanced_image_upload_page.dart';
import 'src/features/bill_scanner/presentation/pages/qr_scanner_page.dart';
// import 'src/features/bill_scanner/presentation/cubit/bill_scanner_cubit.dart';
import 'src/features/suggestions/presentation/pages/suggestions_demo_page.dart';
import 'src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'src/features/tags/presentation/cubit/tags_cubit.dart';
import 'src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'src/features/bill_scanner/presentation/pages/scan_library_page.dart';
import 'src/features/bill_scanner/presentation/cubit/scan_library_cubit.dart';

import 'package:billora/src/features/invoice/domain/usecases/generate_summary_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/classify_invoice_usecase.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/customer/presentation/pages/customer_form_page.dart';
import 'src/features/auth/presentation/widgets/profile_form.dart';
import 'src/features/auth/presentation/cubit/auth_state.dart';
import 'src/features/invoice/presentation/pages/invoice_template_page.dart';
import 'src/core/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (ignore errors on web if asset not bundled)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
    
    // Initialize OpenAI with API key
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
      debugPrint('🔑 OpenAI API Key loaded: ${apiKey.substring(0, 7)}...');
    } else {
      debugPrint('⚠️ OpenAI API key not found in .env file');
    }
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
      theme: AppTheme.lightTheme,

      home: const AuthWrapper(),
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
            BlocProvider.value(value: sl<CustomerCubit>()),
          ],
          child: const CustomerListPage(),
        ),
        '/customer-form': (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<AuthCubit>()),
            BlocProvider.value(value: sl<CustomerCubit>()),
          ],
          child: const CustomerFormPage(),
        ),
        '/products': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider.value(value: sl<ProductCubit>()),
              ],
              child: const ProductCatalogPage(),
            ),
        '/product-form': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider.value(value: sl<ProductCubit>()),
              ],
              child: const ProductFormPage(),
            ),
        '/invoices': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider.value(value: sl<InvoiceCubit>()),
                BlocProvider.value(value: sl<CustomerCubit>()),
                BlocProvider.value(value: sl<ProductCubit>()),
                BlocProvider.value(value: sl<SuggestionsCubit>()),
                BlocProvider.value(value: sl<TagsCubit>()),
                // Add AI UseCase providers
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
                Provider<ClassifyInvoiceUseCase>(create: (_) => sl<ClassifyInvoiceUseCase>()),
              ],
              child: const InvoiceListPage(),
            ),
        '/invoice-form': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider.value(value: sl<InvoiceCubit>()),
                BlocProvider.value(value: sl<CustomerCubit>()),
                BlocProvider.value(value: sl<ProductCubit>()),
                BlocProvider.value(value: sl<SuggestionsCubit>()),
                BlocProvider.value(value: sl<TagsCubit>()),
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
                Provider<ClassifyInvoiceUseCase>(create: (_) => sl<ClassifyInvoiceUseCase>()),
              ],
              child: const InvoiceFormPage(),
            ),
        '/invoice-template': (context) => const InvoiceTemplatePage(),
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
        '/qr-scanner': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const QRScannerPage(),
            ),
        '/scan-library': (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AuthCubit>()),
                BlocProvider<ScanLibraryCubit>(create: (_) => sl<ScanLibraryCubit>()),
                // Add AI UseCase providers for scan library
                Provider<GenerateSummaryUseCase>(create: (_) => sl<GenerateSummaryUseCase>()),
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
        '/profile': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: ProfilePage(),
            ),
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Ensure we refresh the auth state when opening profile
    context.read<AuthCubit>().getCurrentUser();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return state.maybeWhen(
              authenticated: (user) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ProfileForm(user: user),
              ),
              orElse: () => const Center(child: Text('Please log in')),
            );
          },
        ),
      ),
    );
  }
}
