import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
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
    try {
      emit(const AuthState.loading());
      await logoutUseCase();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      // Even if logout fails, we should still emit unauthenticated state
      // to ensure user is logged out from the UI perspective
      emit(const AuthState.unauthenticated());
    }
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

  Future<void> getCurrentUser() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) {
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    final result = await updateProfileUseCase(
      displayName: displayName,
      photoURL: photoURL,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> loginWithPasskey(String userId) async {
    emit(const AuthState.loading());
    
    try {
      // Simulate successful authentication
      // Note: In a real implementation, you would need to create a proper User object
      // For now, we'll emit an error since we can't create a proper User object
      emit(AuthState.error('Passkey authentication not fully implemented yet'));
    } catch (e) {
      emit(AuthState.error('Passkey authentication failed: $e'));
    }
  }
} 
