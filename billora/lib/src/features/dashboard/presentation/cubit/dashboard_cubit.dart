import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/domain/usecases/get_invoice_stats_usecase.dart';
import 'package:billora/src/features/dashboard/domain/usecases/export_invoice_report_usecase.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStats extends DashboardEvent {
  final DateRange dateRange;
  final List<String> tagFilters;

  const LoadDashboardStats({
    required this.dateRange,
    this.tagFilters = const [],
  });

  @override
  List<Object?> get props => [dateRange, tagFilters];
}

class ExportExcelReport extends DashboardEvent {
  final ReportParams params;

  const ExportExcelReport(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdateDateRange extends DashboardEvent {
  final DateRange dateRange;

  const UpdateDateRange(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class UpdateTagFilters extends DashboardEvent {
  final List<String> tagFilters;

  const UpdateTagFilters(this.tagFilters);

  @override
  List<Object?> get props => [tagFilters];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final DateRange currentDateRange;
  final List<String> currentTagFilters;

  const DashboardLoaded({
    required this.stats,
    required this.currentDateRange,
    required this.currentTagFilters,
  });

  @override
  List<Object?> get props => [stats, currentDateRange, currentTagFilters];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    DateRange? currentDateRange,
    List<String>? currentTagFilters,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      currentDateRange: currentDateRange ?? this.currentDateRange,
      currentTagFilters: currentTagFilters ?? this.currentTagFilters,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExportLoading extends DashboardState {}

class ExportSuccess extends DashboardState {
  final Uint8List excelData;
  final String fileName;

  const ExportSuccess({
    required this.excelData,
    required this.fileName,
  });

  @override
  List<Object?> get props => [excelData, fileName];
}

class ExportError extends DashboardState {
  final String message;

  const ExportError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final GetInvoiceStatsUseCase _getInvoiceStatsUseCase;
  final ExportInvoiceReportUseCase _exportInvoiceReportUseCase;

  DashboardCubit({
    required GetInvoiceStatsUseCase getInvoiceStatsUseCase,
    required ExportInvoiceReportUseCase exportInvoiceReportUseCase,
  })  : _getInvoiceStatsUseCase = getInvoiceStatsUseCase,
        _exportInvoiceReportUseCase = exportInvoiceReportUseCase,
        super(DashboardInitial());

  Future<void> loadDashboardStats({
    DateRange? dateRange,
    List<String>? tagFilters,
  }) async {
    try {
      if (isClosed) return;
      emit(DashboardLoading());

      final currentState = state;
      final currentDateRange = dateRange ?? 
          (currentState is DashboardLoaded ? currentState.currentDateRange : DateRange.thisMonth);
      final currentTagFilters = tagFilters ?? 
          (currentState is DashboardLoaded ? currentState.currentTagFilters : []);

      final params = GetInvoiceStatsParams(
        dateRange: currentDateRange,
        tagFilters: currentTagFilters,
      );

      final result = await _getInvoiceStatsUseCase(params);
      
      if (isClosed) return;
      result.fold(
        (failure) => emit(DashboardError(failure.message)),
        (stats) => emit(DashboardLoaded(
          stats: stats,
          currentDateRange: currentDateRange,
          currentTagFilters: currentTagFilters,
        )),
      );
    } catch (e) {
      if (isClosed) return;
      emit(DashboardError('Failed to load dashboard stats: $e'));
    }
  }

  Future<void> exportExcelReport(ReportParams params) async {
    try {
      if (isClosed) return;
      
      // Store current state before export
      final currentState = state;
      if (currentState is DashboardLoaded) {
        emit(ExportLoading());
      }

      final result = await _exportInvoiceReportUseCase(params);
      
      if (isClosed) return;
      result.fold(
        (failure) {
          // Restore previous state on error
          if (currentState is DashboardLoaded) {
            emit(currentState);
          }
          emit(ExportError(failure.message));
        },
        (excelData) {
          final fileName = 'invoice_report_${_generateFileName(params)}.xlsx';
          emit(ExportSuccess(
            excelData: excelData,
            fileName: fileName,
          ));
          // Restore previous state after success
          if (currentState is DashboardLoaded) {
            emit(currentState);
          }
        },
      );
    } catch (e) {
      if (isClosed) return;
      // Restore previous state on exception
      final currentState = state;
      if (currentState is DashboardLoaded) {
        emit(currentState);
      }
      emit(ExportError('Failed to export Excel report: $e'));
    }
  }

  void updateDateRange(DateRange dateRange) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(currentDateRange: dateRange));
      loadDashboardStats(dateRange: dateRange);
    }
  }

  void updateTagFilters(List<String> tagFilters) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(currentTagFilters: tagFilters));
      loadDashboardStats(tagFilters: tagFilters);
    }
  }

  String _generateFileName(ReportParams params) {
    final startDate = params.dateRange.startDate;
    final endDate = params.dateRange.endDate;
    
    return '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}_'
           '${endDate.year}${endDate.month.toString().padLeft(2, '0')}${endDate.day.toString().padLeft(2, '0')}';
  }
} 