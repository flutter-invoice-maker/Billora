import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  DateRange? _selectedDateRange;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    // Use post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load tags
      context.read<TagsCubit>().getAllTags();
      
      // Get current filters from cubit
      final currentState = context.read<DashboardCubit>().state;
      if (currentState is DashboardLoaded) {
        setState(() {
          _selectedDateRange = currentState.currentDateRange;
          _selectedTags = currentState.currentTagFilters;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text(
                'Bộ lọc',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Range Selection
          Text(
            'Khoảng thời gian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildDateRangeSelector(),
          
          const SizedBox(height: 24),
          
          // Tag Selection
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildTagSelector(),
          
          const SizedBox(height: 24),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Áp dụng bộ lọc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateRange.predefinedRanges.map((dateRange) {
          final isSelected = _selectedDateRange?.type == dateRange.type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(dateRange.label ?? 'Custom'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDateRange = selected ? dateRange : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagSelector() {
    return BlocBuilder<TagsCubit, dynamic>(
      builder: (context, state) {
        if (state is TagsLoaded) {
          final tags = state.tags;
          return Wrap(
            spacing: 8,
            children: tags.map((tag) {
              final isSelected = _selectedTags.contains(tag.name);
              return FilterChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag.name);
                    } else {
                      _selectedTags.remove(tag.name);
                    }
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue,
              );
            }).toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _applyFilters() {
    if (_selectedDateRange != null) {
      context.read<DashboardCubit>().loadDashboardStats(
        dateRange: _selectedDateRange!,
        tagFilters: _selectedTags,
      );
    }
    Navigator.pop(context);
  }
} 