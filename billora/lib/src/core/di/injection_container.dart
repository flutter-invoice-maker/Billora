import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart'; // import file config được sinh ra
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:billora/src/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
} 
