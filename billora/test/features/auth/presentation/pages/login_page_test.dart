import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/auth/presentation/pages/login_page.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billora/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:billora/src/features/auth/domain/usecases/register_usecase.dart';
import 'package:billora/src/features/auth/domain/usecases/logout_usecase.dart';
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/features/auth/domain/entities/user.dart';
import 'package:billora/src/core/errors/failures.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}
class MockSignInWithAppleUseCase extends Mock implements SignInWithAppleUseCase {}

void main() {
  late AuthCubit cubit;
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockSignInWithGoogleUseCase signInWithGoogleUseCase;
  late MockSignInWithAppleUseCase signInWithAppleUseCase;

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    signInWithGoogleUseCase = MockSignInWithGoogleUseCase();
    signInWithAppleUseCase = MockSignInWithAppleUseCase();
    cubit = AuthCubit(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      signInWithGoogleUseCase: signInWithGoogleUseCase,
      signInWithAppleUseCase: signInWithAppleUseCase,
    );
    when(() => loginUseCase.call(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => Right(User(id: '1', email: 'test', displayName: 'Test')));
    when(() => registerUseCase.call(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => Right(User(id: '1', email: 'test', displayName: 'Test')));
    when(() => logoutUseCase.call()).thenAnswer((_) async => Future.value());
    when(() => signInWithGoogleUseCase.call()).thenAnswer((_) async => Right(User(id: '1', email: 'test', displayName: 'Test')));
    when(() => signInWithAppleUseCase.call()).thenAnswer((_) async => Right(User(id: '1', email: 'test', displayName: 'Test')));
  });

  testWidgets('LoginPage renders form and login button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const LoginPage(),
        ),
      ),
    );
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.textContaining('Login'), findsWidgets);
  });
} 