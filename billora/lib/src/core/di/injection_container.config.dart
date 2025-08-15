// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:billora/src/core/di/injection_container.dart' as _i107;
import 'package:billora/src/core/services/ai_service.dart' as _i17;
import 'package:billora/src/core/services/email_service.dart' as _i971;
import 'package:billora/src/core/services/firebase_email_service.dart' as _i365;
import 'package:billora/src/core/services/image_upload_service.dart' as _i957;
import 'package:billora/src/core/services/pdf_service.dart' as _i5;
import 'package:billora/src/core/services/qr_service.dart' as _i314;
import 'package:billora/src/core/services/storage_service.dart' as _i537;
import 'package:billora/src/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i910;
import 'package:billora/src/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1;
import 'package:billora/src/features/auth/domain/repositories/auth_repository.dart'
    as _i253;
import 'package:billora/src/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i330;
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
import 'package:billora/src/features/auth/domain/usecases/update_profile_usecase.dart'
    as _i866;
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart'
    as _i232;
import 'package:billora/src/features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i256;
import 'package:billora/src/features/dashboard/domain/usecases/export_invoice_report_usecase.dart'
    as _i423;
import 'package:billora/src/features/dashboard/domain/usecases/get_invoice_stats_usecase.dart'
    as _i873;
import 'package:billora/src/features/invoice/domain/usecases/classify_invoice_usecase.dart'
    as _i980;
import 'package:billora/src/features/invoice/domain/usecases/generate_pdf_usecase.dart'
    as _i936;
import 'package:billora/src/features/invoice/domain/usecases/generate_qr_code_usecase.dart'
    as _i486;
import 'package:billora/src/features/invoice/domain/usecases/generate_summary_usecase.dart'
    as _i760;
import 'package:billora/src/features/invoice/domain/usecases/send_firebase_email_usecase.dart'
    as _i1012;
import 'package:billora/src/features/invoice/domain/usecases/send_invoice_email_usecase.dart'
    as _i888;
import 'package:billora/src/features/invoice/domain/usecases/suggest_tags_usecase.dart'
    as _i261;
import 'package:billora/src/features/invoice/domain/usecases/upload_invoice_usecase.dart'
    as _i1014;
import 'package:billora/src/features/product/data/datasources/product_remote_datasource.dart'
    as _i520;
import 'package:billora/src/features/product/domain/repositories/product_repository.dart'
    as _i667;
import 'package:billora/src/features/product/domain/usecases/update_product_inventory_usecase.dart'
    as _i750;
import 'package:billora/src/features/suggestions/data/datasources/suggestions_remote_datasource.dart'
    as _i921;
import 'package:billora/src/features/suggestions/data/repositories/suggestions_repository_impl.dart'
    as _i771;
import 'package:billora/src/features/suggestions/domain/repositories/suggestions_repository.dart'
    as _i456;
import 'package:billora/src/features/suggestions/domain/usecases/calculate_suggestion_score_usecase.dart'
    as _i577;
import 'package:billora/src/features/suggestions/domain/usecases/get_product_suggestions_usecase.dart'
    as _i671;
import 'package:billora/src/features/suggestions/domain/usecases/record_product_usage_usecase.dart'
    as _i227;
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart'
    as _i694;
import 'package:billora/src/features/tags/data/datasources/tags_remote_datasource.dart'
    as _i897;
import 'package:billora/src/features/tags/data/repositories/tags_repository_impl.dart'
    as _i625;
import 'package:billora/src/features/tags/domain/repositories/tags_repository.dart'
    as _i18;
import 'package:billora/src/features/tags/domain/usecases/create_tag_usecase.dart'
    as _i281;
import 'package:billora/src/features/tags/domain/usecases/get_all_tags_usecase.dart'
    as _i53;
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart'
    as _i989;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:uuid/uuid.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.factory<_i17.AIService>(() => _i17.AIService());
    gh.factory<_i971.EmailService>(() => _i971.EmailService());
    gh.factory<_i5.PdfService>(() => _i5.PdfService());
    gh.factory<_i314.QRService>(() => _i314.QRService());
    gh.factory<_i577.CalculateSuggestionScoreUseCase>(
      () => _i577.CalculateSuggestionScoreUseCase(),
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<_i809.FirebaseFunctions>(
      () => firebaseModule.firebaseFunctions,
    );
    gh.lazySingleton<_i706.Uuid>(() => firebaseModule.uuid);
    gh.factory<_i936.GeneratePdfUseCase>(
      () => _i936.GeneratePdfUseCase(gh<_i5.PdfService>()),
    );
    gh.factory<_i520.ProductRemoteDatasourceImpl>(
      () => _i520.ProductRemoteDatasourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i897.TagsRemoteDataSource>(
      () => _i897.TagsRemoteDataSourceImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i18.TagsRepository>(
      () => _i625.TagsRepositoryImpl(gh<_i897.TagsRemoteDataSource>()),
    );
    gh.factory<_i423.ExportInvoiceReportUseCase>(
      () => _i423.ExportInvoiceReportUseCase(gh<_i256.DashboardRepository>()),
    );
    gh.factory<_i873.GetInvoiceStatsUseCase>(
      () => _i873.GetInvoiceStatsUseCase(gh<_i256.DashboardRepository>()),
    );
    gh.factory<_i750.UpdateProductInventoryUseCase>(
      () => _i750.UpdateProductInventoryUseCase(gh<_i667.ProductRepository>()),
    );
    gh.lazySingleton<_i910.AuthRemoteDataSource>(
      () => _i910.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i537.StorageService>(
      () => _i537.StorageService(
        gh<_i457.FirebaseStorage>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i888.SendInvoiceEmailUseCase>(
      () => _i888.SendInvoiceEmailUseCase(gh<_i971.EmailService>()),
    );
    gh.factory<_i980.ClassifyInvoiceUseCase>(
      () => _i980.ClassifyInvoiceUseCase(gh<_i17.AIService>()),
    );
    gh.factory<_i760.GenerateSummaryUseCase>(
      () => _i760.GenerateSummaryUseCase(gh<_i17.AIService>()),
    );
    gh.factory<_i261.SuggestTagsUseCase>(
      () => _i261.SuggestTagsUseCase(gh<_i17.AIService>()),
    );
    gh.factory<_i486.GenerateQRCodeUseCase>(
      () => _i486.GenerateQRCodeUseCase(gh<_i314.QRService>()),
    );
    gh.factory<_i957.ImageUploadService>(
      () => _i957.ImageUploadService(
        gh<_i457.FirebaseStorage>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i365.FirebaseEmailService>(
      () => _i365.FirebaseEmailService(
        gh<_i809.FirebaseFunctions>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i456.SuggestionsRepository>(
      () => _i771.SuggestionsRepositoryImpl(
        gh<_i921.SuggestionsRemoteDataSource>(),
      ),
    );
    gh.factory<_i1014.UploadInvoiceUseCase>(
      () => _i1014.UploadInvoiceUseCase(gh<_i537.StorageService>()),
    );
    gh.lazySingleton<_i253.AuthRepository>(
      () => _i1.AuthRepositoryImpl(gh<_i910.AuthRemoteDataSource>()),
    );
    gh.factory<_i281.CreateTagUseCase>(
      () => _i281.CreateTagUseCase(gh<_i18.TagsRepository>()),
    );
    gh.factory<_i53.GetAllTagsUseCase>(
      () => _i53.GetAllTagsUseCase(gh<_i18.TagsRepository>()),
    );
    gh.factory<_i1012.SendFirebaseEmailUseCase>(
      () => _i1012.SendFirebaseEmailUseCase(gh<_i365.FirebaseEmailService>()),
    );
    gh.factory<_i671.GetProductSuggestionsUseCase>(
      () =>
          _i671.GetProductSuggestionsUseCase(gh<_i456.SuggestionsRepository>()),
    );
    gh.factory<_i227.RecordProductUsageUseCase>(
      () => _i227.RecordProductUsageUseCase(gh<_i456.SuggestionsRepository>()),
    );
    gh.factory<_i330.GetCurrentUserUseCase>(
      () => _i330.GetCurrentUserUseCase(gh<_i253.AuthRepository>()),
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
    gh.factory<_i579.SignInWithAppleUseCase>(
      () => _i579.SignInWithAppleUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i1057.SignInWithGoogleUseCase>(
      () => _i1057.SignInWithGoogleUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i866.UpdateProfileUseCase>(
      () => _i866.UpdateProfileUseCase(gh<_i253.AuthRepository>()),
    );
    gh.factory<_i694.SuggestionsCubit>(
      () => _i694.SuggestionsCubit(
        getProductSuggestionsUseCase: gh<_i671.GetProductSuggestionsUseCase>(),
        recordProductUsageUseCase: gh<_i227.RecordProductUsageUseCase>(),
        calculateSuggestionScoreUseCase:
            gh<_i577.CalculateSuggestionScoreUseCase>(),
      ),
    );
    gh.factory<_i989.TagsCubit>(
      () => _i989.TagsCubit(
        getAllTagsUseCase: gh<_i53.GetAllTagsUseCase>(),
        createTagUseCase: gh<_i281.CreateTagUseCase>(),
      ),
    );
    gh.factory<_i232.AuthCubit>(
      () => _i232.AuthCubit(
        loginUseCase: gh<_i361.LoginUseCase>(),
        registerUseCase: gh<_i46.RegisterUseCase>(),
        logoutUseCase: gh<_i731.LogoutUseCase>(),
        signInWithGoogleUseCase: gh<_i1057.SignInWithGoogleUseCase>(),
        signInWithAppleUseCase: gh<_i579.SignInWithAppleUseCase>(),
        getCurrentUserUseCase: gh<_i330.GetCurrentUserUseCase>(),
        updateProfileUseCase: gh<_i866.UpdateProfileUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i107.FirebaseModule {}
