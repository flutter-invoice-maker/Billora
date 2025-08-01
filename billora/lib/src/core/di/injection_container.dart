import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart'; // import file config được sinh ra
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/search_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:billora/src/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billora/src/features/product/data/datasources/product_remote_datasource.dart';
import 'package:billora/src/features/product/data/repositories/product_repository_impl.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:billora/src/features/product/domain/usecases/create_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/update_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/search_products_usecase.dart';
import 'package:billora/src/features/product/domain/usecases/get_categories_usecase.dart';

import 'package:billora/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';

import 'package:billora/src/features/invoice/data/datasources/invoice_remote_datasource.dart';
import 'package:billora/src/features/invoice/data/repositories/invoice_repository_impl.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/invoice/domain/usecases/create_invoice_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/get_invoices_usecase.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/domain/usecases/delete_invoice_usecase.dart';
import 'package:billora/src/core/services/pdf_service.dart';
import 'package:billora/src/core/services/email_service.dart';
import 'package:billora/src/core/services/firebase_email_service.dart';
import 'package:billora/src/core/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:billora/src/features/invoice/domain/usecases/generate_pdf_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/send_invoice_email_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/send_firebase_email_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/upload_invoice_usecase.dart';

import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';

// Bill Scanner imports
import 'package:billora/src/features/bill_scanner/domain/repositories/bill_scanner_repository.dart';
import 'package:billora/src/features/bill_scanner/data/repositories/bill_scanner_repository_impl.dart';
import 'package:billora/src/features/bill_scanner/data/datasources/ocr_datasource.dart';
import 'package:billora/src/features/bill_scanner/data/datasources/free_ocr_api_datasource.dart';
import 'package:billora/src/features/bill_scanner/data/datasources/image_processing_datasource.dart';
import 'package:billora/src/features/bill_scanner/domain/usecases/scan_bill_usecase.dart';
import 'package:billora/src/features/bill_scanner/domain/usecases/extract_bill_data_usecase.dart';
import 'package:billora/src/features/bill_scanner/domain/usecases/validate_bill_data_usecase.dart';
import 'package:billora/src/features/bill_scanner/domain/usecases/process_with_regex_usecase.dart';
import 'package:billora/src/features/bill_scanner/presentation/cubit/bill_scanner_cubit.dart';

// Week 7 - Suggestions & Tags imports
import 'package:uuid/uuid.dart';
import 'package:billora/src/features/suggestions/domain/repositories/suggestions_repository.dart';
import 'package:billora/src/features/suggestions/data/repositories/suggestions_repository_impl.dart';
import 'package:billora/src/features/suggestions/data/datasources/suggestions_remote_datasource.dart';
import 'package:billora/src/features/suggestions/domain/usecases/get_product_suggestions_usecase.dart';
import 'package:billora/src/features/suggestions/domain/usecases/record_product_usage_usecase.dart';
import 'package:billora/src/features/suggestions/domain/usecases/calculate_suggestion_score_usecase.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';

import 'package:billora/src/features/tags/domain/repositories/tags_repository.dart';
import 'package:billora/src/features/tags/data/repositories/tags_repository_impl.dart';
import 'package:billora/src/features/tags/data/datasources/tags_remote_datasource.dart';
import 'package:billora/src/features/tags/domain/usecases/get_all_tags_usecase.dart';
import 'package:billora/src/features/tags/domain/usecases/create_tag_usecase.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  sl.init();
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }
  if (!sl.isRegistered<CustomerRemoteDatasource>()) {
    sl.registerLazySingleton<CustomerRemoteDatasource>(
      () => CustomerRemoteDatasourceImpl(sl()),
    );
  }
  if (!sl.isRegistered<CustomerRepository>()) {
    sl.registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<GetCustomersUseCase>()) {
    sl.registerLazySingleton<GetCustomersUseCase>(
      () => GetCustomersUseCase(sl()),
    );
  }
  if (!sl.isRegistered<CreateCustomerUseCase>()) {
    sl.registerLazySingleton<CreateCustomerUseCase>(
      () => CreateCustomerUseCase(sl()),
    );
  }
  if (!sl.isRegistered<UpdateCustomerUseCase>()) {
    sl.registerLazySingleton<UpdateCustomerUseCase>(
      () => UpdateCustomerUseCase(sl()),
    );
  }
  if (!sl.isRegistered<DeleteCustomerUseCase>()) {
    sl.registerLazySingleton<DeleteCustomerUseCase>(
      () => DeleteCustomerUseCase(sl()),
    );
  }
  if (!sl.isRegistered<SearchCustomersUseCase>()) {
    sl.registerLazySingleton<SearchCustomersUseCase>(
      () => SearchCustomersUseCase(sl()),
    );
  }
  if (!sl.isRegistered<ProductRemoteDatasource>()) {
    sl.registerLazySingleton<ProductRemoteDatasource>(
      () => ProductRemoteDatasourceImpl(sl()),
    );
  }
  if (!sl.isRegistered<ProductRepository>()) {
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<GetProductsUseCase>()) {
    sl.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(sl()),
    );
  }
  if (!sl.isRegistered<CreateProductUseCase>()) {
    sl.registerLazySingleton<CreateProductUseCase>(
      () => CreateProductUseCase(sl()),
    );
  }
  if (!sl.isRegistered<UpdateProductUseCase>()) {
    sl.registerLazySingleton<UpdateProductUseCase>(
      () => UpdateProductUseCase(sl()),
    );
  }
  if (!sl.isRegistered<DeleteProductUseCase>()) {
    sl.registerLazySingleton<DeleteProductUseCase>(
      () => DeleteProductUseCase(sl()),
    );
  }
  if (!sl.isRegistered<SearchProductsUseCase>()) {
    sl.registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCase(sl()),
    );
  }
  if (!sl.isRegistered<GetCategoriesUseCase>()) {
    sl.registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(sl()),
    );
  }
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<FirebaseAuth>(), sl<GoogleSignIn>()),
    );
  }
  if (!sl.isRegistered<SignInWithGoogleUseCase>()) {
    sl.registerLazySingleton<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(sl()),
    );
  }
  if (!sl.isRegistered<SignInWithAppleUseCase>()) {
    sl.registerLazySingleton<SignInWithAppleUseCase>(
      () => SignInWithAppleUseCase(sl()),
    );
  }
  if (!sl.isRegistered<AuthCubit>()) {
    sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        signInWithGoogleUseCase: sl(),
        signInWithAppleUseCase: sl(),
      ),
    );
  }
  if (!sl.isRegistered<InvoiceRemoteDatasource>()) {
    sl.registerLazySingleton<InvoiceRemoteDatasource>(
      () => InvoiceRemoteDatasourceImpl(sl()),
    );
  }
  if (!sl.isRegistered<InvoiceRepository>()) {
    sl.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<GetInvoicesUseCase>()) {
    sl.registerLazySingleton<GetInvoicesUseCase>(
      () => GetInvoicesUseCase(sl()),
    );
  }
  if (!sl.isRegistered<CreateInvoiceUseCase>()) {
    sl.registerLazySingleton<CreateInvoiceUseCase>(
      () => CreateInvoiceUseCase(sl()),
    );
  }
  if (!sl.isRegistered<DeleteInvoiceUseCase>()) {
    sl.registerLazySingleton<DeleteInvoiceUseCase>(
      () => DeleteInvoiceUseCase(sl()),
    );
  }
  if (!sl.isRegistered<InvoiceCubit>()) {
    sl.registerLazySingleton<InvoiceCubit>(
      () => InvoiceCubit(
        getInvoicesUseCase: sl(),
        createInvoiceUseCase: sl(),
        deleteInvoiceUseCase: sl(),
        generatePdfUseCase: sl(),
        sendInvoiceEmailUseCase: sl(),
        sendFirebaseEmailUseCase: sl(),
        uploadInvoiceUseCase: sl(),
      ),
    );
  }
  if (!sl.isRegistered<CustomerCubit>()) {
    sl.registerLazySingleton<CustomerCubit>(() => CustomerCubit(
      getCustomersUseCase: sl(),
      createCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
      searchCustomersUseCase: sl(),
    ));
  }
  if (!sl.isRegistered<ProductCubit>()) {
    sl.registerLazySingleton<ProductCubit>(() => ProductCubit(
      getProductsUseCase: sl(),
      createProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      searchProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
    ));
  }
  if (!sl.isRegistered<PdfService>()) {
    sl.registerLazySingleton<PdfService>(() => PdfService());
  }
  if (!sl.isRegistered<EmailService>()) {
    sl.registerLazySingleton<EmailService>(() => EmailService());
  }
  if (!sl.isRegistered<FirebaseEmailService>()) {
    sl.registerLazySingleton<FirebaseEmailService>(() => FirebaseEmailService(sl<FirebaseFunctions>(), sl<FirebaseAuth>()));
  }
  if (!sl.isRegistered<FirebaseStorage>()) {
    sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  }
  if (!sl.isRegistered<FirebaseFunctions>()) {
    sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);
  }
  if (!sl.isRegistered<StorageService>()) {
    sl.registerLazySingleton<StorageService>(() => StorageService(sl<FirebaseStorage>(), sl<FirebaseAuth>()));
  }
  if (!sl.isRegistered<GeneratePdfUseCase>()) {
    sl.registerLazySingleton<GeneratePdfUseCase>(() => GeneratePdfUseCase(sl()));
  }
  if (!sl.isRegistered<SendInvoiceEmailUseCase>()) {
    sl.registerLazySingleton<SendInvoiceEmailUseCase>(() => SendInvoiceEmailUseCase(sl()));
  }
  if (!sl.isRegistered<SendFirebaseEmailUseCase>()) {
    sl.registerLazySingleton<SendFirebaseEmailUseCase>(() => SendFirebaseEmailUseCase(sl()));
  }
  if (!sl.isRegistered<UploadInvoiceUseCase>()) {
    sl.registerLazySingleton<UploadInvoiceUseCase>(() => UploadInvoiceUseCase(sl()));
  }

  // Bill Scanner Dependencies
  if (!sl.isRegistered<OCRDataSource>()) {
    sl.registerLazySingleton<OCRDataSource>(() => MLKitOCRDataSource());
  }
  if (!sl.isRegistered<FreeOCRApiDataSource>()) {
    sl.registerLazySingleton<FreeOCRApiDataSource>(() => FreeOCRApiDataSource());
  }
  if (!sl.isRegistered<ImageProcessingDataSource>()) {
    sl.registerLazySingleton<ImageProcessingDataSource>(() => ImageProcessingDataSource());
  }
  if (!sl.isRegistered<BillScannerRepository>()) {
    sl.registerLazySingleton<BillScannerRepository>(
      () => BillScannerRepositoryImpl(
            mlKitDataSource: sl(),
            apiDataSource: sl(),
            imageProcessingDataSource: sl(),
          ),
    );
  }
  if (!sl.isRegistered<ScanBillUseCase>()) {
    sl.registerLazySingleton<ScanBillUseCase>(() => ScanBillUseCase(sl()));
  }
  if (!sl.isRegistered<ExtractBillDataUseCase>()) {
    sl.registerLazySingleton<ExtractBillDataUseCase>(() => ExtractBillDataUseCase(sl()));
  }
  if (!sl.isRegistered<ValidateBillDataUseCase>()) {
    sl.registerLazySingleton<ValidateBillDataUseCase>(() => ValidateBillDataUseCase(sl()));
  }
  if (!sl.isRegistered<ProcessWithRegexUseCase>()) {
    sl.registerLazySingleton<ProcessWithRegexUseCase>(() => ProcessWithRegexUseCase(sl()));
  }
  if (!sl.isRegistered<BillScannerCubit>()) {
    sl.registerLazySingleton<BillScannerCubit>(
      () => BillScannerCubit(
        scanBillUseCase: sl(),
        extractBillDataUseCase: sl(),
        validateBillDataUseCase: sl(),
      ),
    );
  }

  // Week 7 - Suggestions & Tags Dependencies
  if (!sl.isRegistered<Uuid>()) {
    sl.registerLazySingleton<Uuid>(() => const Uuid());
  }
  
  // Suggestions Dependencies
  if (!sl.isRegistered<SuggestionsRemoteDataSource>()) {
    sl.registerLazySingleton<SuggestionsRemoteDataSource>(
      () => SuggestionsRemoteDataSourceImpl(sl(), sl()),
    );
  }
  if (!sl.isRegistered<SuggestionsRepository>()) {
    sl.registerLazySingleton<SuggestionsRepository>(
      () => SuggestionsRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<GetProductSuggestionsUseCase>()) {
    sl.registerLazySingleton<GetProductSuggestionsUseCase>(
      () => GetProductSuggestionsUseCase(sl()),
    );
  }
  if (!sl.isRegistered<RecordProductUsageUseCase>()) {
    sl.registerLazySingleton<RecordProductUsageUseCase>(
      () => RecordProductUsageUseCase(sl()),
    );
  }
  if (!sl.isRegistered<CalculateSuggestionScoreUseCase>()) {
    sl.registerLazySingleton<CalculateSuggestionScoreUseCase>(
      () => CalculateSuggestionScoreUseCase(),
    );
  }
  if (!sl.isRegistered<SuggestionsCubit>()) {
    sl.registerLazySingleton<SuggestionsCubit>(
      () => SuggestionsCubit(
        getProductSuggestionsUseCase: sl(),
        recordProductUsageUseCase: sl(),
        calculateSuggestionScoreUseCase: sl(),
      ),
    );
  }

  // Tags Dependencies
  if (!sl.isRegistered<TagsRemoteDataSource>()) {
    sl.registerLazySingleton<TagsRemoteDataSource>(
      () => TagsRemoteDataSourceImpl(sl(), sl(), sl()),
    );
  }
  if (!sl.isRegistered<TagsRepository>()) {
    sl.registerLazySingleton<TagsRepository>(
      () => TagsRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<GetAllTagsUseCase>()) {
    sl.registerLazySingleton<GetAllTagsUseCase>(
      () => GetAllTagsUseCase(sl()),
    );
  }
  if (!sl.isRegistered<CreateTagUseCase>()) {
    sl.registerLazySingleton<CreateTagUseCase>(
      () => CreateTagUseCase(sl()),
    );
  }
  if (!sl.isRegistered<TagsCubit>()) {
    sl.registerLazySingleton<TagsCubit>(
      () => TagsCubit(
        getAllTagsUseCase: sl(),
        createTagUseCase: sl(),
      ),
    );
  }
}

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();
  
  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
  
  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;
  
  @lazySingleton
  FirebaseFunctions get firebaseFunctions => FirebaseFunctions.instance;
  
  @lazySingleton
  Uuid get uuid => const Uuid();
} 
