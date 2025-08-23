import 'dart:typed_data';
import 'dart:developer' as developer;
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
  
  // Add loading state tracking to prevent multiple simultaneous calls
  bool _isLoadingStats = false;
  bool _isExporting = false;
  DateTime? _lastLoadTime;

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
    // Prevent multiple simultaneous loading calls
    if (_isLoadingStats) {
      developer.log('Already loading, skipping...', name: 'Dashboard');
      return;
    }

    // Debounce rapid calls
    final now = DateTime.now();
    if (_lastLoadTime != null && 
        now.difference(_lastLoadTime!) < const Duration(milliseconds: 300)) {
      developer.log('Too soon since last load, skipping...', name: 'Dashboard');
      return;
    }

    try {
      _isLoadingStats = true;
      _lastLoadTime = now;

      if (isClosed) return;

      // Only emit loading if we're not already in a loaded state
      final currentState = state;
      if (currentState is! DashboardLoaded) {
        emit(DashboardLoading());
      }

      final currentDateRange = dateRange ?? 
          (currentState is DashboardLoaded ? currentState.currentDateRange : DateRange.thisMonth);
      final currentTagFilters = tagFilters ?? 
          (currentState is DashboardLoaded ? currentState.currentTagFilters : <String>[]);

      final params = GetInvoiceStatsParams(
        dateRange: currentDateRange,
        tagFilters: currentTagFilters,
      );

      developer.log(
        'Loading stats with params - DateRange: ${currentDateRange.label}, TagFilters: ${currentTagFilters.length}',
        name: 'Dashboard',
      );

      final result = await _getInvoiceStatsUseCase(params);
      
      if (isClosed) return;
      
      result.fold(
        (failure) {
          developer.log('Load failed - ${failure.message}', name: 'Dashboard');
          emit(DashboardError(failure.message));
        },
        (stats) {
          developer.log(
            'Load successful - ${stats.totalInvoices} invoices, ${stats.totalRevenue} revenue',
            name: 'Dashboard',
          );
          emit(DashboardLoaded(
            stats: stats,
            currentDateRange: currentDateRange,
            currentTagFilters: currentTagFilters,
          ));
        },
      );
    } catch (e) {
      developer.log('Load exception - $e', name: 'Dashboard');
      if (isClosed) return;
      emit(DashboardError('Failed to load dashboard stats: $e'));
    } finally {
      _isLoadingStats = false;
    }
  }

  Future<void> exportExcelReport(ReportParams params) async {
    // Prevent multiple simultaneous exports
    if (_isExporting) {
      developer.log('Already exporting, skipping...', name: 'Dashboard');
      return;
    }

    try {
      _isExporting = true;
      if (isClosed) return;
      
      // Store current state before export
      final currentState = state;
      
      developer.log('Starting Excel export...', name: 'Dashboard');
      emit(ExportLoading());

      final result = await _exportInvoiceReportUseCase(params);
      
      if (isClosed) return;
      
      result.fold(
        (failure) {
          developer.log('Export failed - ${failure.message}', name: 'Dashboard');
          // Restore previous state on error
          if (currentState is DashboardLoaded) {
            emit(currentState);
          }
          // Then emit error
          Future.microtask(() {
            if (!isClosed) emit(ExportError(failure.message));
          });
        },
        (excelData) {
          final fileName = 'invoice_report_${_generateFileName(params)}.xlsx';
          developer.log('Export successful - $fileName', name: 'Dashboard');
          
          emit(ExportSuccess(
            excelData: excelData,
            fileName: fileName,
          ));
          
          // Restore previous state after a brief delay to show success
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!isClosed && currentState is DashboardLoaded) {
              emit(currentState);
            }
          });
        },
      );
    } catch (e) {
      developer.log('Export exception - $e', name: 'Dashboard');
      if (isClosed) return;
      
      // Restore previous state on exception
      final currentState = state;
      if (currentState is DashboardLoaded) {
        emit(currentState);
      }
      
      // Then emit error
      Future.microtask(() {
        if (!isClosed) emit(ExportError('Failed to export Excel report: $e'));
      });
    } finally {
      _isExporting = false;
    }
  }

  void updateDateRange(DateRange dateRange) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is DashboardLoaded) {
      developer.log('Updating date range to ${dateRange.label}', name: 'Dashboard');
      
      // Update state immediately for UI responsiveness
      emit(currentState.copyWith(currentDateRange: dateRange));
      
      // Then reload data
      loadDashboardStats(dateRange: dateRange);
    } else {
      // If not loaded yet, just load with new date range
      loadDashboardStats(dateRange: dateRange);
    }
  }

  void updateTagFilters(List<String> tagFilters) {
    if (isClosed) return;
    
    final currentState = state;
    if (currentState is DashboardLoaded) {
      developer.log('Updating tag filters to ${tagFilters.length} tags', name: 'Dashboard');
      
      // Update state immediately for UI responsiveness
      emit(currentState.copyWith(currentTagFilters: tagFilters));
      
      // Then reload data
      loadDashboardStats(tagFilters: tagFilters);
    } else {
      // If not loaded yet, just load with new tag filters
      loadDashboardStats(tagFilters: tagFilters);
    }
  }

  String _generateFileName(ReportParams params) {
    final startDate = params.dateRange.startDate;
    final endDate = params.dateRange.endDate;
    
    return '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}_'
           '${endDate.year}${endDate.month.toString().padLeft(2, '0')}${endDate.day.toString().padLeft(2, '0')}';
  }

  @override
  void onChange(Change<DashboardState> change) {
    super.onChange(change);
    developer.log(
      'State Change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      name: 'Dashboard',
    );
  }

  @override
  Future<void> close() {
    developer.log('Cubit closing...', name: 'Dashboard');
    return super.close();
  }
}