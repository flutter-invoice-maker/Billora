import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/usecases/suggest_tags_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/classify_invoice_usecase.dart';
import 'package:billora/src/features/invoice/domain/usecases/generate_summary_usecase.dart';

class AISuggestionsWidget extends StatefulWidget {
  final Invoice? invoice;
  final Function(List<String>) onTagsSuggested;
  final Function(String) onClassificationSuggested;
  final Function(String) onSummarySuggested;
  final Color primaryColor;

  const AISuggestionsWidget({
    super.key,
    this.invoice,
    required this.onTagsSuggested,
    required this.onClassificationSuggested,
    required this.onSummarySuggested,
    required this.primaryColor,
  });

  @override
  State<AISuggestionsWidget> createState() => _AISuggestionsWidgetState();
}

class _AISuggestionsWidgetState extends State<AISuggestionsWidget> {
  bool _isLoading = false;
  List<String> _suggestedTags = [];
  String? _suggestedClassification;
  String? _suggestedSummary;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _generateAISuggestions();
    }
  }

  Future<void> _generateAISuggestions() async {
    if (widget.invoice == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate AI suggestions in parallel
      await Future.wait([
        _generateTagSuggestions(),
        _generateClassification(),
        _generateSummary(),
      ]);
    } catch (e) {
      debugPrint('Error generating AI suggestions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTagSuggestions() async {
    try {
      final suggestTagsUseCase = context.read<SuggestTagsUseCase>();
      final tags = await suggestTagsUseCase(widget.invoice!);
      
      setState(() {
        _suggestedTags = tags;
      });
      
      widget.onTagsSuggested(tags);
    } catch (e) {
      debugPrint('Error generating tag suggestions: $e');
    }
  }

  Future<void> _generateClassification() async {
    try {
      final classifyUseCase = context.read<ClassifyInvoiceUseCase>();
      final classification = await classifyUseCase(widget.invoice!);
      
      setState(() {
        _suggestedClassification = classification;
      });
      
      widget.onClassificationSuggested(classification);
    } catch (e) {
      debugPrint('Error generating classification: $e');
    }
  }

  Future<void> _generateSummary() async {
    try {
      final summaryUseCase = context.read<GenerateSummaryUseCase>();
      final summary = await summaryUseCase(widget.invoice!);
      
      setState(() {
        _suggestedSummary = summary;
      });
      
      widget.onSummarySuggested(summary);
    } catch (e) {
      debugPrint('Error generating summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_suggestedTags.isEmpty && _suggestedClassification == null && _suggestedSummary == null) {
      return _buildEmptyCard();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: widget.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Suggestions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _generateAISuggestions,
                  icon: Icon(
                    Icons.refresh,
                    color: widget.primaryColor,
                    size: 18,
                  ),
                  tooltip: 'Regenerate suggestions',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tag Suggestions
            if (_suggestedTags.isNotEmpty) ...[
              _buildSuggestionSection(
                'Suggested Tags',
                Icons.label,
                _buildTagChips(_suggestedTags),
              ),
              const SizedBox(height: 12),
            ],

            // Classification
            if (_suggestedClassification != null) ...[
              _buildSuggestionSection(
                'Classification',
                Icons.category,
                _buildClassificationChip(_suggestedClassification!),
              ),
              const SizedBox(height: 12),
            ],

            // Summary
            if (_suggestedSummary != null) ...[
              _buildSuggestionSection(
                'Summary',
                Icons.summarize,
                _buildSummaryText(_suggestedSummary!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: widget.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Generating AI suggestions...',
            style: TextStyle(
              fontSize: 14,
              color: widget.primaryColor,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Add items to get AI suggestions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: widget.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildTagChips(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) => _buildTagChip(tag)).toList(),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 12,
          color: widget.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClassificationChip(String classification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        classification,
        style: TextStyle(
          fontSize: 13,
          color: widget.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummaryText(String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Text(
        summary,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
} 