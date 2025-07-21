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
}

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();
} 
