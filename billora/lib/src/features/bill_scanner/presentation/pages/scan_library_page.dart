import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scan_library_item.dart';
import '../cubit/scan_library_cubit.dart';
import 'scan_library_detail_page.dart';
import '../../../../core/utils/snackbar_helper.dart';

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
    // Load scan library when widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScanLibrary();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove duplicate data loading to prevent infinite loading
    // Check if we have route arguments with initial items
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['initialItems'] != null) {
      final initialItems = args['initialItems'] as List<ScanLibraryItem>;
      if (initialItems.isNotEmpty) {
        // Save initial items to the library
        _saveInitialItems(initialItems);
      }
    }
  }

  Future<void> _saveInitialItems(List<ScanLibraryItem> items) async {
    try {
      final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
      for (final item in items) {
        cubit.saveScanItem(item);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message: 'Error saving initial items: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScanLibrary() async {
    if (!mounted) return;
    
    try {
      // Use BlocProvider.of to get the cubit safely
      final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
      
      // If we have initial items, save them first
      if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
        for (final item in widget.initialItems!) {
          cubit.saveScanItem(item);
        }
      }
      
      // Then load all items
      cubit.loadScanItems();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message: 'Error loading scan library: $e',
        );
      }
    }
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
            onPressed: () {
              try {
                final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
                cubit.loadScanItems();
              } catch (e) {
                SnackBarHelper.showError(
                  context,
                  message: 'Error refreshing: $e',
                );
              }
            },
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
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ScanLibraryCubit, ScanLibraryState>(
      listener: (context, state) {
        if (state is ScanLibraryItemSaved) {
          SnackBarHelper.showSuccess(
            context,
            message: 'Scan saved successfully: ${state.item.fileName}',
          );
        } else if (state is ScanLibraryItemUpdated) {
          SnackBarHelper.showInfo(
            context,
            message: 'Scan updated successfully: ${state.item.fileName}',
          );
        } else if (state is ScanLibraryItemDeleted) {
          SnackBarHelper.showWarning(
            context,
            message: 'Scan deleted successfully',
          );
        } else if (state is ScanLibraryError) {
          SnackBarHelper.showError(
            context,
            message: 'Error: ${state.message}',
          );
        }
      },
      builder: (context, state) {
        if (state is ScanLibraryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ScanLibraryLoaded) {
          final items = _filterItems(state.items);
          return _buildScanItemsList(items);
        } else if (state is ScanLibraryError) {
          return _buildErrorState(state.message);
        } else {
          return const Center(
            child: Text('No scans found'),
          );
        }
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _loadScanLibrary();
            },
            child: const Text('Retry'),
          ),
        ],
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
            title: Text(
              item.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${item.scannedBill.storeName} • ${item.totalAmountString()} • ${_formatDate(item.createdAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openDetail(item),
            trailing: SizedBox(
              width: 80, // Fixed width to prevent overflow
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Rename',
                    onPressed: () => _promptRename(item),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Delete',
                    onPressed: () => _promptDelete(item),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
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
      try {
        final updatedItem = item.copyWith(
          fileName: newName,
          lastModifiedAt: DateTime.now(),
        );
        final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
        cubit.updateScanItem(updatedItem);
      } catch (e) {
        SnackBarHelper.showError(
          context,
          message: 'Error updating scan: $e',
        );
      }
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
      try {
        final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
        cubit.deleteScanItem(item.id);
      } catch (e) {
        SnackBarHelper.showError(
          context,
          message: 'Error deleting scan: $e',
        );
      }
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