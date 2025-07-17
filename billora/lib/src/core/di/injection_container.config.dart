// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:billora/src/core/di/injection_container.dart' as _i107;
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
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart'
    as _i232;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
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
    gh.lazySingleton<_i910.AuthRemoteDataSource>(
      () => _i910.AuthRemoteDataSourceImpl(gh<_i59.FirebaseAuth>()),
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
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i107.FirebaseModule {}
