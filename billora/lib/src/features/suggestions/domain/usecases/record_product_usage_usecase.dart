import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/suggestions/domain/repositories/suggestions_repository.dart';

@injectable
class RecordProductUsageUseCase {
  final SuggestionsRepository repository;

  RecordProductUsageUseCase(this.repository);

  ResultFuture<void> call({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? customerId,
  }) async {
    return await repository.recordProductUsage(
      productId: productId,
      productName: productName,
      price: price,
      currency: currency,
      customerId: customerId,
    );
  }
} 