import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
  }) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> register(String email, String password) async {
    emit(const AuthState.loading());
    final result = await registerUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(const AuthState.unauthenticated());
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    final result = await signInWithGoogleUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> signInWithApple() async {
    emit(const AuthState.loading());
    final result = await signInWithAppleUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
} 
