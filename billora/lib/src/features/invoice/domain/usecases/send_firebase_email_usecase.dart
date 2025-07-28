import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/core/usecase/usecase.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/services/firebase_email_service.dart';
import 'dart:typed_data';

@injectable
class SendFirebaseEmailUseCase implements UseCase<void, SendFirebaseEmailParams> {
  final FirebaseEmailService _emailService;

  SendFirebaseEmailUseCase(this._emailService);

  @override
  Future<Either<Failure, void>> call(SendFirebaseEmailParams params) async {
    try {
      await _emailService.sendInvoiceEmail(
        toEmail: params.toEmail,
        subject: params.subject,
        body: params.body,
        pdfData: params.pdfData,
        fileName: params.fileName,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class SendFirebaseEmailParams {
  final String toEmail;
  final String subject;
  final String body;
  final Uint8List pdfData;
  final String fileName;

  SendFirebaseEmailParams({
    required this.toEmail,
    required this.subject,
    required this.body,
    required this.pdfData,
    required this.fileName,
  });
} 