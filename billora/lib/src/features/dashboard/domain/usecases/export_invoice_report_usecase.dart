import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/core/usecase/usecase.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';
import 'package:billora/src/features/dashboard/domain/repositories/dashboard_repository.dart';

@injectable
class ExportInvoiceReportUseCase implements UseCase<Uint8List, ReportParams> {
  final DashboardRepository _repository;

  const ExportInvoiceReportUseCase(this._repository);

  @override
  Future<Either<Failure, Uint8List>> call(ReportParams params) async {
    return await _repository.exportExcelReport(params);
  }
} 