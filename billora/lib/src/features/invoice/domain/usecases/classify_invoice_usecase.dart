import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/chatbot_ai_service.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:firebase_auth/firebase_auth.dart';

@injectable
class ClassifyInvoiceUseCase {
  final ChatbotAIService _aiService;
  final FirebaseAuth _firebaseAuth;

  ClassifyInvoiceUseCase(this._aiService, this._firebaseAuth);

  Future<String> call(Invoice invoice) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return 'Unknown';

    final prompt = '''
Classify this invoice into one of these categories:
- Service Invoice
- Product Invoice
- Subscription Invoice
- One-time Purchase
- Recurring Billing

Invoice Details:
- Customer: ${invoice.customerName}
- Total: \$${invoice.total.toStringAsFixed(2)}
- Items: ${invoice.items.map((i) => i.name).join(', ')}

Return only the category name.
''';

    final response = await _aiService.sendMessage(
      userId: userId,
      message: prompt,
      currentTabIndex: 3, // Invoices tab
    );

    return response.isNotEmpty ? response : 'Unknown';
  }
} 