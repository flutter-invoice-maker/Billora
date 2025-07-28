import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/services/email_service.dart';

@injectable
class SendInvoiceEmailUseCase {
  final EmailService emailService;
  SendInvoiceEmailUseCase(this.emailService);

  Future<void> call({
    required String toEmail,
    required String subject,
    required String body,
    required Uint8List pdfData,
    required String fileName,
  }) {
    return emailService.sendInvoiceEmail(
      toEmail: toEmail,
      subject: subject,
      body: body,
      pdfData: pdfData,
      fileName: fileName,
    );
  }
} 