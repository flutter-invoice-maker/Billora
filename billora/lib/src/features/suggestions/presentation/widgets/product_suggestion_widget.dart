import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';

class ProductSuggestionWidget extends StatefulWidget {
  final String? customerId;
  final Function(Suggestion) onSuggestionSelected;
  final String? initialValue;
  final String label;
  final String hint;

  const ProductSuggestionWidget({
    super.key,
    this.customerId,
    required this.onSuggestionSelected,
    this.initialValue,
    this.label = 'Product',
    this.hint = 'Search products...',
  });

  @override
  State<ProductSuggestionWidget> createState() => _ProductSuggestionWidgetState();
}

class _ProductSuggestionWidgetState extends State<ProductSuggestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Suggestion>(
      controller: _controller,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.search),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return [];
        
        debugPrint('🔍 ProductSuggestionWidget: Searching for "$pattern"');
        final cubit = context.read<SuggestionsCubit>();
        await cubit.getProductSuggestions(
          customerId: widget.customerId,
          searchQuery: pattern,
          limit: 10,
        );
        
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 100));
        
        final state = cubit.state;
        debugPrint('🔍 ProductSuggestionWidget: State is $state');
        
        if (state is SuggestionsLoaded) {
          final suggestions = state.suggestions.map((scored) => scored.suggestion).toList();
          debugPrint('🔍 ProductSuggestionWidget: Returning ${suggestions.length} suggestions');
          return suggestions;
        }
        debugPrint('🔍 ProductSuggestionWidget: No suggestions available');
        return [];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.name),
          subtitle: suggestion.price != null
              ? Text('${suggestion.price} ${suggestion.currency ?? 'USD'}')
              : null,
          trailing: suggestion.usageCount > 0
              ? Chip(
                  label: Text('${suggestion.usageCount}'),
                  backgroundColor: Colors.blue.shade100,
                )
              : null,
        );
      },
      onSelected: (suggestion) {
        _controller.text = suggestion.name;
        widget.onSuggestionSelected(suggestion);
      },
    );
  }
} 