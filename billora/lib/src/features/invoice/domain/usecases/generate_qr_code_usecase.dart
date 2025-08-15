import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/qr_service.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class GenerateQRCodeUseCase {
  final QRService _qrService;

  GenerateQRCodeUseCase(this._qrService);

  String call(Invoice invoice) {
    return _qrService.generateInvoiceQRString(invoice);
  }

  Map<String, dynamic> generateQRData(Invoice invoice) {
    return _qrService.generateInvoiceQRData(invoice);
  }

  String generateLookupURL(String invoiceId) {
    // Generate a simple lookup URL
    return 'https://billora.app/invoice/$invoiceId';
  }

  Map<String, dynamic> generateSummaryQRData(Invoice invoice) {
    return _qrService.generateInvoiceSummaryQRData(invoice);
  }

  Map<String, dynamic> generateVerificationQRData(Invoice invoice) {
    return _qrService.generateInvoiceVerificationQRData(invoice);
  }
} 