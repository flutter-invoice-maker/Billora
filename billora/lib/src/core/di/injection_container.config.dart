// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:billora/src/core/di/injection_container.dart' as _i107;
import 'package:billora/src/core/services/email_service.dart' as _i971;
import 'package:billora/src/core/services/firebase_email_service.dart' as _i365;
import 'package:billora/src/core/services/pdf_service.dart' as _i5;
import 'package:billora/src/core/services/storage_service.dart' as _i537;
import 'package:billora/src/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i910;
import 'package:billora/src/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1;
import 'package:billora/src/features/auth/domain/repositories/auth_repository.dart'
    as _i253;
import 'package:billora/src/features/auth/domain/usecases/login_usecase.dart'
    as _i361;
import 'package:billora/src/features/auth/domain/usecases/logout_usecase.dart'
    as _i731;
import 'package:billora/src/features/auth/domain/usecases/register_usecase.dart'
    as _i46;
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_apple_usecase.dart'
    as _i579;
import 'package:billora/src/features/auth/domain/usecases/sign_in_with_google_usecase.dart'
    as _i1057;
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart'
    as _i232;
import 'package:billora/src/features/invoice/domain/usecases/generate_pdf_usecase.dart'
    as _i936;
import 'package:billora/src/features/invoice/domain/usecases/send_firebase_email_usecase.dart'
    as _i1012;
import 'package:billora/src/features/invoice/domain/usecases/send_invoice_email_usecase.dart'
    as _i888;
import 'package:billora/src/features/invoice/domain/usecases/upload_invoice_usecase.dart'
    as _i1014;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i1014.UploadInvoiceUseCase>(
      () => _i1014.UploadInvoiceUseCase(gh<_i537.StorageService>()),
    );
    gh.factory<_i936.GeneratePdfUseCase>(
      () => _i936.GeneratePdfUseCase(gh<_i5.PdfService>()),
    );
    gh.factory<_i1012.SendFirebaseEmailUseCase>(
      () => _i1012.SendFirebaseEmailUseCase(gh<_i365.FirebaseEmailService>()),
    );
    gh.lazySingleton<_i910.AuthRemoteDataSource>(
      () => _i910.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i888.SendInvoiceEmailUseCase>(
      () => _i888.SendInvoiceEmailUseCase(gh<_i971.EmailService>()),
    );
    gh.lazySingleton<_i253.AuthRepository>(
      () => _i1.AuthRepositoryImpl(gh<_i910.AuthRemoteDataSource>()),
    );
    gh.factory<_i361.LoginUseCase>(
      () => _i361.LoginUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i731.LogoutUseCase>(
      () => _i731.LogoutUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i46.RegisterUseCase>(
      () => _i46.RegisterUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i232.AuthCubit>(
      () => _i232.AuthCubit(
        loginUseCase: gh<_i361.LoginUseCase>(),
        registerUseCase: gh<_i46.RegisterUseCase>(),
        logoutUseCase: gh<_i731.LogoutUseCase>(),
        signInWithGoogleUseCase: gh<_i1057.SignInWithGoogleUseCase>(),
        signInWithAppleUseCase: gh<_i579.SignInWithAppleUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i107.FirebaseModule {}
