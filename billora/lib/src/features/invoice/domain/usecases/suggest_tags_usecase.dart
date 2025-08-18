import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/huggingface_ai_service.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

@injectable
class SuggestTagsUseCase {
  final HuggingFaceAIService _aiService;

  SuggestTagsUseCase(this._aiService);

  Future<List<String>> call(Invoice invoice) async {
    return await _aiService.suggestTags(invoice);
  }
} 