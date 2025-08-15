import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scan_library_item.dart';
import '../cubit/scan_library_cubit.dart';
import 'scan_library_detail_page.dart';

class ScanLibraryPage extends StatefulWidget {
  final List<ScanLibraryItem>? initialItems;
  const ScanLibraryPage({super.key, this.initialItems});

  @override
  State<ScanLibraryPage> createState() => _ScanLibraryPageState();
}

class _ScanLibraryPageState extends State<ScanLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadScanLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScanLibrary() async {
    final cubit = context.read<ScanLibraryCubit>();
    
    // If we have initial items, save them first
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      for (final item in widget.initialItems!) {
        await cubit.saveScanItem(item);
      }
    }
    
    // Then load all items
    await cubit.loadScanItems();
  }

  List<ScanLibraryItem> _filterItems(List<ScanLibraryItem> items) {
    return items.where((item) {
      final matchesSearch = item.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.scannedBill.storeName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'processed' && item.isProcessed) ||
          (_selectedFilter == 'pending' && !item.isProcessed);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Library'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ScanLibraryCubit>().loadScanItems(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchAndFilterSection(),
            Expanded(
              child: BlocConsumer<ScanLibraryCubit, ScanLibraryState>(
                listener: (context, state) {
                  if (state is ScanLibraryItemSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Scan saved successfully: ${state.item.fileName}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ScanLibraryItemUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Scan updated successfully: ${state.item.fileName}'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  } else if (state is ScanLibraryItemDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Scan deleted successfully'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else if (state is ScanLibraryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ScanLibraryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ScanLibraryLoaded) {
                    final filteredItems = _filterItems(state.items);
                    if (filteredItems.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildScanItemsList(filteredItems);
                  } else if (state is ScanLibraryError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<ScanLibraryCubit>().loadScanItems(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by file name or store name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('processed', 'Processed'),
              const SizedBox(width: 8),
              _buildFilterChip('pending', 'Pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool selected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books, size: 72, color: Colors.blue.shade300),
            const SizedBox(height: 12),
            const Text('No scans yet'),
            const SizedBox(height: 6),
            const Text('Scanned files will appear here'),
          ],
        ),
      ),
    );
  }

  Widget _buildScanItemsList(List<ScanLibraryItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title: Text(item.fileName),
            subtitle: Text('${item.scannedBill.storeName} • ${item.totalAmountString()} • ${_formatDate(item.createdAt)}'),
            onTap: () => _openDetail(item),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Rename',
                  onPressed: () => _promptRename(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: () => _promptDelete(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _promptRename(ScanLibraryItem item) async {
    final controller = TextEditingController(text: item.fileName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && mounted) {
      final updatedItem = item.copyWith(
        fileName: newName,
        lastModifiedAt: DateTime.now(),
      );
      context.read<ScanLibraryCubit>().updateScanItem(updatedItem);
    }
  }

  Future<void> _promptDelete(ScanLibraryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete scan'),
        content: Text('Are you sure you want to delete "${item.fileName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ScanLibraryCubit>().deleteScanItem(item.id);
    }
  }

  void _openDetail(ScanLibraryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanLibraryDetailPage(scanItem: item),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
} 