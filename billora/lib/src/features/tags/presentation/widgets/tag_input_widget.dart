import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/utils/app_strings.dart';

class TagInputWidget extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final String label;
  final String hint;

  const TagInputWidget({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.label = 'Tags',
    this.hint = 'Add tags...',
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _availableColors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
  ];

  @override
  void initState() {
    super.initState();
    // Load available tags with error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<TagsCubit>().getAllTags();
        } catch (e) {
          // Handle error silently or show a snackbar
          debugPrint('Error loading tags: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // Selected tags display
        if (widget.selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedTags.map((tagName) {
              return _buildTagChip(tagName);
            }).toList(),
          ),
        
        const SizedBox(height: 8),
        
        // Tag input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _showTagCreationDialog,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Available tags suggestions
        BlocBuilder<TagsCubit, TagsState>(
          builder: (context, state) {
            if (state is TagsLoaded) {
              final availableTags = state.tags
                  .where((tag) => !widget.selectedTags.contains(tag.name))
                  .toList();
              
              if (availableTags.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available tags:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: availableTags.take(10).map((tag) {
                        return InkWell(
                          onTap: () => _addExistingTag(tag.name),
                          child: Chip(
                            label: Text(
                              tag.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _parseColor(tag.color).withValues(alpha: 0.2),
                            side: BorderSide(color: _parseColor(tag.color)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }
            } else if (state is TagsError) {
              return Text(
                'Error loading tags: ${state.message}',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTagChip(String tagName) {
    return Chip(
      label: Text(tagName),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tagName),
      backgroundColor: Colors.blue.shade100,
      side: BorderSide(color: Colors.blue.shade300),
    );
  }

  void _addTag() {
    final tagName = _controller.text.trim();
    if (tagName.isNotEmpty && !widget.selectedTags.contains(tagName)) {
      final updatedTags = List<String>.from(widget.selectedTags)..add(tagName);
      widget.onTagsChanged(updatedTags);
      _controller.clear();
    }
  }

  void _addExistingTag(String tagName) {
    if (!widget.selectedTags.contains(tagName)) {
      final updatedTags = List<String>.from(widget.selectedTags)..add(tagName);
      widget.onTagsChanged(updatedTags);
    }
  }

  void _removeTag(String tagName) {
    final updatedTags = List<String>.from(widget.selectedTags)..remove(tagName);
    widget.onTagsChanged(updatedTags);
  }

  void _showTagCreationDialog() {
    final nameController = TextEditingController();
    String selectedColor = _availableColors.first;
    final tagsCubit = context.read<TagsCubit>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.invoiceCreateNewTag),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.invoiceTagName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.selectColor,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      selectedColor = color;
                      setDialogState(() {});
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.grey,
                          width: selectedColor == color ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.invoiceCancel),
            ),
            ElevatedButton(
              onPressed: () {
                final tagName = nameController.text.trim();
                if (tagName.isNotEmpty) {
                  try {
                    tagsCubit.createTag(
                      name: tagName,
                      color: selectedColor,
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.error} creating tag: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(AppStrings.invoiceCreateTag),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
} 