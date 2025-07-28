import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/services/storage_service.dart';

@injectable
class UploadInvoiceUseCase {
  final StorageService storageService;
  UploadInvoiceUseCase(this.storageService);

  Future<String> call({
    required String userId,
    required String invoiceId,
    required Uint8List pdfData,
  }) {
    return storageService.uploadInvoicePdf(
      userId: userId,
      invoiceId: invoiceId,
      pdfData: pdfData,
    );
  }
} 