import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final GetInvoicesUseCase getInvoicesUseCase;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final DeleteInvoiceUseCase deleteInvoiceUseCase;

  InvoiceCubit({
    required this.getInvoicesUseCase,
    required this.createInvoiceUseCase,
    required this.deleteInvoiceUseCase,
  }) : super(const InvoiceState.initial());

  Future<void> fetchInvoices() async {
    emit(const InvoiceState.loading());
    final result = await getInvoicesUseCase();
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (invoices) => emit(InvoiceState.loaded(invoices)),
    );
  }

  Future<void> addInvoice(Invoice invoice) async {
    emit(const InvoiceState.loading());
    final result = await createInvoiceUseCase(invoice);
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (_) => fetchInvoices(),
    );
  }

  Future<void> deleteInvoice(String id) async {
    emit(const InvoiceState.loading());
    final result = await deleteInvoiceUseCase(id);
    result.fold(
      (failure) => emit(InvoiceState.error(failure.message)),
      (_) => fetchInvoices(),
    );
  }
} 