import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';
import 'package:billora/src/features/suggestions/domain/repositories/suggestions_repository.dart';
import 'package:billora/src/features/suggestions/data/datasources/suggestions_remote_datasource.dart';

@Injectable(as: SuggestionsRepository)
class SuggestionsRepositoryImpl implements SuggestionsRepository {
  final SuggestionsRemoteDataSource remoteDataSource;

  SuggestionsRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<Suggestion>> getProductSuggestions({
    String? customerId,
    String? searchQuery,
    int limit = 10,
  }) async {
    try {
      final suggestions = await remoteDataSource.getProductSuggestions(
        customerId: customerId,
        searchQuery: searchQuery,
        limit: limit,
      );
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> recordProductUsage({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  }) async {
    try {
      await remoteDataSource.recordProductUsage(
        productId: productId,
        productName: productName,
        price: price,
        currency: currency,
        customerId: customerId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> recordCustomerUsage({
    required String customerId,
    required String customerName,
    required String email,
  }) async {
    try {
      await remoteDataSource.recordCustomerUsage(
        customerId: customerId,
        customerName: customerName,
        email: email,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> syncSuggestions() async {
    try {
      await remoteDataSource.syncSuggestions();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 