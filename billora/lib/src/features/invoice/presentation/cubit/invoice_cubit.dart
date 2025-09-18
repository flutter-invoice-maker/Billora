import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/generate_pdf_usecase.dart';
import '../../domain/usecases/send_invoice_email_usecase.dart';
import '../../domain/usecases/send_firebase_email_usecase.dart';
import '../../domain/usecases/upload_invoice_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:billora/src/core/services/notification_service.dart';
import 'package:billora/src/core/services/activity_service.dart';
import 'package:billora/src/core/services/customer_ranking_service.dart';
import 'package:billora/src/core/services/data_refresh_service.dart';
import 'package:billora/src/core/services/vip_threshold_service.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final GetInvoicesUseCase getInvoicesUseCase;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final DeleteInvoiceUseCase deleteInvoiceUseCase;
  final GeneratePdfUseCase generatePdfUseCase;
  final SendInvoiceEmailUseCase sendInvoiceEmailUseCase;
  final SendFirebaseEmailUseCase sendFirebaseEmailUseCase;
  final UploadInvoiceUseCase uploadInvoiceUseCase;

  InvoiceCubit({
    required this.getInvoicesUseCase,
    required this.createInvoiceUseCase,
    required this.deleteInvoiceUseCase,
    required this.generatePdfUseCase,
    required this.sendInvoiceEmailUseCase,
    required this.sendFirebaseEmailUseCase,
    required this.uploadInvoiceUseCase,
  }) : super(const InvoiceState.initial());

  Future<void> fetchInvoices() async {
    if (isClosed) return; // Prevent emitting after close
    emit(const InvoiceState.loading());
    final result = await getInvoicesUseCase();
    if (isClosed) return; // Check again after async operation
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (invoices) {
        emit(InvoiceState.loaded(invoices));
        // Load fresh data from Firestore for all services
        NotificationService().loadOverdueInvoices();
        ActivityService().loadActivities();
        CustomerRankingService().loadCustomerRankings();
      },
    );
  }

  Future<void> addInvoice(Invoice invoice) async {
    if (isClosed) return;
    emit(const InvoiceState.loading());
    final result = await createInvoiceUseCase(invoice);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (_) {
        // Add activity for invoice creation first
        ActivityService().addInvoiceCreatedActivity(invoice);
        // Then refresh invoices list which will trigger dashboard refresh
        fetchInvoices();
        // Notify other cubits to refresh their data
        _notifyDataChanged();
      },
    );
  }

  void _notifyDataChanged() {
    // This method can be used to notify other cubits that data has changed
    debugPrint('🔄 Invoice data changed, notifying other components');
    // Refresh dashboard data immediately
    DataRefreshService().refreshDashboard();
    // Update VIP status for all customers
    VipThresholdService().updateAllCustomersVipStatus();
  }

  Future<void> deleteInvoice(String id) async {
    if (isClosed) return;
    emit(const InvoiceState.loading());
    final result = await deleteInvoiceUseCase(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (_) => fetchInvoices(),
    );
  }

  Future<Uint8List> generatePdf(Invoice invoice) {
    return generatePdfUseCase(invoice);
  }

  Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
    required Uint8List pdfData,
    required String fileName,
  }) async {
    // Use direct SendGrid API for both mobile and web
    await sendInvoiceEmailUseCase(
      toEmail: toEmail,
      subject: subject,
      body: body,
      pdfData: pdfData,
      fileName: fileName,
    );
  }

  Future<String> uploadPdf({
    required String userId,
    required String invoiceId,
    required Uint8List pdfData,
  }) {
    return uploadInvoiceUseCase(
      userId: userId,
      invoiceId: invoiceId,
      pdfData: pdfData,
    );
  }
} 