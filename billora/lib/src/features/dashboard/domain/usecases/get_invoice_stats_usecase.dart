import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/core/usecase/usecase.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetInvoiceStatsParams {
  final DateRange dateRange;
  final List<String> tagFilters;

  const GetInvoiceStatsParams({
    required this.dateRange,
    this.tagFilters = const [],
  });
}

@injectable
class GetInvoiceStatsUseCase implements UseCase<DashboardStats, GetInvoiceStatsParams> {
  final DashboardRepository _repository;

  const GetInvoiceStatsUseCase(this._repository);

  @override
  Future<Either<Failure, DashboardStats>> call(GetInvoiceStatsParams params) async {
    return await _repository.getStats(params.dateRange, params.tagFilters);
  }
} 