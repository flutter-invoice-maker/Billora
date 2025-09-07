import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/chatbot_ai_service.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:firebase_auth/firebase_auth.dart';

@injectable
class GenerateSummaryUseCase {
  final ChatbotAIService _aiService;
  final FirebaseAuth _firebaseAuth;

  GenerateSummaryUseCase(this._aiService, this._firebaseAuth);

  Future<String> call(Invoice invoice) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return 'Summary generation failed.';

    final prompt = '''
Generate a concise summary for this invoice:

Invoice Details:
- Customer: ${invoice.customerName}
- Total: \$${invoice.total.toStringAsFixed(2)}
- Items: ${invoice.items.map((i) => '${i.name} (${i.quantity}x \$${i.unitPrice})').join(', ')}
- Date: ${invoice.createdAt.toString()}

Please provide a 1-2 sentence summary highlighting key points.
''';

    final response = await _aiService.sendMessage(
      userId: userId,
      message: prompt,
      currentTabIndex: 3, // Invoices tab
    );

    return response.isNotEmpty ? response : 'Summary generation failed.';
  }
} 