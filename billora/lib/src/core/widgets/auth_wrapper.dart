import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:billora/src/features/home/presentation/pages/home_page.dart';
import 'package:billora/src/features/auth/presentation/pages/login_page.dart';
import 'package:billora/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    setState(() {
      _isFirstTime = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    setState(() {
      _isFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isFirstTime) {
      return OnboardingPage(
        onComplete: _completeOnboarding,
      );
    }

    return BlocProvider(
      create: (context) => sl<AuthCubit>()..getCurrentUser(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            authenticated: (user) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthCubit>()),
                  BlocProvider<DashboardCubit>(create: (_) => sl<DashboardCubit>()),
                ],
                child: const HomePage(),
              );
            },
            unauthenticated: () {
              return BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: const LoginPage(),
              );
            },
            error: (message) {
              return BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: const LoginPage(),
              );
            },
          );
        },
      ),
    );
  }
}
