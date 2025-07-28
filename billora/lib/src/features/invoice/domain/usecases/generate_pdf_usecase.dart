import 'dart:typed_data';
import '../entities/invoice.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/pdf_service.dart';

@injectable
class GeneratePdfUseCase {
  final PdfService pdfService;
  GeneratePdfUseCase(this.pdfService);

  Future<Uint8List> call(Invoice invoice) {
    return pdfService.generateInvoicePdf(invoice);
  }
} 