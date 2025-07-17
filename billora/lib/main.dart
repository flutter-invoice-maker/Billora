import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/auth/presentation/cubit/auth_cubit.dart';
import 'src/core/di/injection_container.dart';

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
      },
    );
  }
}
