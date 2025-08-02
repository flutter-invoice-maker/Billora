import 'dart:typed_data';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';

abstract class DashboardRepository {
  /// Get dashboard statistics for a given date range and tag filters
  ResultFuture<DashboardStats> getStats(
    DateRange dateRange,
    List<String> tagFilters,
  );

  /// Export invoice report to Excel format
  ResultFuture<Uint8List> exportExcelReport(ReportParams params);

  /// Get chart data for revenue over time
  ResultFuture<List<Map<String, dynamic>>> getRevenueChartData(
    DateRange dateRange,
    List<String> tagFilters,
  );

  /// Get chart data for invoice count over time
  ResultFuture<List<Map<String, dynamic>>> getInvoiceChartData(
    DateRange dateRange,
    List<String> tagFilters,
  );

  /// Get top tags by revenue
  ResultFuture<List<Map<String, dynamic>>> getTopTags(
    DateRange dateRange,
    int limit,
  );

  /// Get status distribution
  ResultFuture<Map<String, int>> getStatusDistribution(
    DateRange dateRange,
    List<String> tagFilters,
  );
} 