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
import 'src/features/customer/domain/usecases/get_customers_usecase.dart';
import 'src/features/customer/domain/usecases/create_customer_usecase.dart';
import 'src/features/customer/domain/usecases/update_customer_usecase.dart';
import 'src/features/customer/domain/usecases/delete_customer_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: const LoginPage(),
      ),
      routes: {
        '/login': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const LoginPage(),
            ),
        '/register': (context) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const RegisterPage(),
            ),
        '/customers': (context) => BlocProvider(
              create: (_) => CustomerCubit(
                getCustomersUseCase: sl<GetCustomersUseCase>(),
                createCustomerUseCase: sl<CreateCustomerUseCase>(),
                updateCustomerUseCase: sl<UpdateCustomerUseCase>(),
                deleteCustomerUseCase: sl<DeleteCustomerUseCase>(),
              ),
              child: const CustomerListPage(),
            ),
      },
    );
  }
}
