import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/ai_service.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class GenerateSummaryUseCase {
  final AIService _aiService;

  GenerateSummaryUseCase(this._aiService);

  Future<String> call(Invoice invoice) async {
    return await _aiService.generateSummary(invoice);
  }
} 