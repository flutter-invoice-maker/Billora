import 'dart:typed_data';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:billora/src/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<DashboardStats> getStats(
    DateRange dateRange,
    List<String> tagFilters,
  ) async {
    try {
      final statsData = await _remoteDataSource.getInvoiceStats(dateRange, tagFilters);
      final statsModel = DashboardStatsModel.fromJson(statsData);
      return Right(statsModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to get dashboard stats: $e'));
    }
  }

  @override
  ResultFuture<Uint8List> exportExcelReport(ReportParams params) async {
    try {
      final excelData = await _remoteDataSource.exportExcelReport(params);
      return Right(excelData);
    } catch (e) {
      return Left(ServerFailure('Failed to export Excel report: $e'));
    }
  }

  @override
  ResultFuture<List<Map<String, dynamic>>> getRevenueChartData(
    DateRange dateRange,
    List<String> tagFilters,
  ) async {
    try {
      final chartData = await _remoteDataSource.getRevenueChartData(dateRange, tagFilters);
      return Right(chartData);
    } catch (e) {
      return Left(ServerFailure('Failed to get revenue chart data: $e'));
    }
  }

  @override
  ResultFuture<List<Map<String, dynamic>>> getInvoiceChartData(
    DateRange dateRange,
    List<String> tagFilters,
  ) async {
    try {
      final chartData = await _remoteDataSource.getInvoiceChartData(dateRange, tagFilters);
      return Right(chartData);
    } catch (e) {
      return Left(ServerFailure('Failed to get invoice chart data: $e'));
    }
  }

  @override
  ResultFuture<List<Map<String, dynamic>>> getTopTags(
    DateRange dateRange,
    int limit,
  ) async {
    try {
      final topTags = await _remoteDataSource.getTopTags(dateRange, limit);
      return Right(topTags);
    } catch (e) {
      return Left(ServerFailure('Failed to get top tags: $e'));
    }
  }

  @override
  ResultFuture<Map<String, int>> getStatusDistribution(
    DateRange dateRange,
    List<String> tagFilters,
  ) async {
    try {
      final statusDistribution = await _remoteDataSource.getStatusDistribution(dateRange, tagFilters);
      return Right(statusDistribution);
    } catch (e) {
      return Left(ServerFailure('Failed to get status distribution: $e'));
    }
  }
} 