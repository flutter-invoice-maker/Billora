import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};
  bool _initialItemsProcessed = false;
  bool _isBatchSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Load scan library after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadScanLibrary();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (!_initialItemsProcessed && args != null && args['initialItems'] != null) {
      final initialItems = args['initialItems'] as List<ScanLibraryItem>;
      if (initialItems.isNotEmpty) {
        _initialItemsProcessed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _saveInitialItems(initialItems);
          }
        });
      }
    }
  }

  Future<void> _saveInitialItems(List<ScanLibraryItem> items) async {
    try {
      final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
      _isBatchSaving = true;
      
      // Save each item individually
      for (final item in items) {
        await cubit.saveScanItem(item);
      }
      
      // After saving all items, refresh the display
      await cubit.loadScanItems();
      
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: '${items.length} scan(s) saved successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message: 'Error saving initial items: $e',
        );
      }
    } finally {
      _isBatchSaving = false;
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
      final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
      // Load all scan items
      await cubit.loadScanItems();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message: 'Error loading scan library: $e',
        );
      }
    }
  }

  void _refreshData() {
    _loadScanLibrary();
  }

  List<ScanLibraryItem> _filterItems(List<ScanLibraryItem> items) {
    return items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.fileName.toLowerCase().contains(q) ||
          item.scannedBill.storeName.toLowerCase().contains(q);
    }).toList();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A), size: 20),
        tooltip: 'Back',
      ),
      title: Text(
        _selectionMode ? '${_selectedIds.length} selected' : 'Scan Library',
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_selectionMode)
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (_selectedIds.isEmpty) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete selected?'),
                      content: Text('Delete ${_selectedIds.length} item(s)?'),
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
                    final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
                    for (final id in _selectedIds.toList()) {
                      await cubit.deleteScanItem(id);
                    }
                    _exitSelection();
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
                tooltip: 'Delete',
              ),
              IconButton(
                onPressed: _exitSelection,
                icon: const Icon(Icons.close, color: Color(0xFF1A1A1A), size: 22),
                tooltip: 'Cancel selection',
              ),
            ],
          )
        else
          Row(
            children: [
              IconButton(
                onPressed: () {
                  try {
                    final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
                    cubit.loadScanItems();
                  } catch (e) {
                    SnackBarHelper.showError(context, message: 'Error refreshing: $e');
                  }
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A), size: 20),
                tooltip: 'Refresh',
              ),
              IconButton(
                onPressed: () {
                  try {
                    final cubit = BlocProvider.of<ScanLibraryCubit>(context, listen: false);
                    cubit.loadScanItems();
                  } catch (e) {
                    SnackBarHelper.showError(context, message: 'Error refreshing: $e');
                  }
                },
                icon: const Icon(Icons.notifications_none, color: Color(0xFF1A1A1A), size: 20),
                tooltip: 'Notifications',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search scans...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ScanLibraryCubit, ScanLibraryState>(
      listener: (context, state) {
        if (state is ScanLibraryItemSaved) {
          if (!_isBatchSaving) {
            SnackBarHelper.showSuccess(context, message: 'Scan saved successfully: ${state.item.fileName}');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _refreshData();
            }
          });
        } else if (state is ScanLibraryItemUpdated) {
          SnackBarHelper.showInfo(context, message: 'Scan updated successfully: ${state.item.fileName}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _refreshData();
            }
          });
        } else if (state is ScanLibraryItemDeleted) {
          SnackBarHelper.showWarning(context, message: 'Scan deleted successfully');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _refreshData();
            }
          });
        } else if (state is ScanLibraryError) {
          SnackBarHelper.showError(context, message: 'Error: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is ScanLibraryLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading scans...'),
              ],
            ),
          );
        } else if (state is ScanLibraryLoaded) {
          final items = _filterItems(state.items);
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scans found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start scanning documents to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildGrid(items);
        } else if (state is ScanLibraryError) {
          return _buildErrorState(state.message);
        }
        
        // Initial state - show loading
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<ScanLibraryItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid similar to Product page
        int crossAxisCount;
        double cardWidth;
        
        final screenWidth = constraints.maxWidth;
        const double minCardWidth = 140.0; // Minimum card width
        const double maxCardWidth = 180.0; // Maximum card width
        const double spacing = 12.0;
        
        // Calculate how many cards can fit with minimum width
        crossAxisCount = ((screenWidth - 32 + spacing) / (minCardWidth + spacing)).floor();
        crossAxisCount = math.max(2, crossAxisCount); // Minimum 2 columns
        crossAxisCount = math.min(6, crossAxisCount); // Maximum 6 columns for very large screens
        
        // Calculate actual card width
        cardWidth = (screenWidth - 32 - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        
        // Ensure card width is within reasonable bounds
        cardWidth = math.max(minCardWidth, math.min(maxCardWidth, cardWidth));
        
        // Calculate aspect ratio to maintain consistent card height similar to Product cards
        const double cardHeight = 275.0; // Increased to prevent bottom overflow
        final double aspectRatio = cardWidth / cardHeight;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = _selectedIds.contains(item.id);
              return _ScanCard(
                item: item,
                showCheckbox: _selectionMode,
                selected: selected,
                onLongPress: () => _enterSelection(item.id),
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelect(item.id);
                  } else {
                    _openDetail(item);
                  }
                },
                onChanged: (val) => _toggleSelect(item.id),
              );
            },
          ),
        );
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
          const Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadScanLibrary, child: const Text('Retry')),
        ],
      ),
    );
  }

  void _openDetail(ScanLibraryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanLibraryDetailPage(scanItem: item),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final ScanLibraryItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showCheckbox;
  final bool selected;
  final ValueChanged<bool?> onChanged;
  const _ScanCard({required this.item, required this.onTap, required this.onLongPress, required this.showCheckbox, required this.selected, required this.onChanged});

  String _statusLabel() {
    final status = item.metadata['status']?.toString().toLowerCase();
    if (status == 'rejected') return 'Rejected';
    if (status == 'draft') return 'Draft';
    return item.isProcessed ? 'Completed' : 'Pending';
  }

  Color _statusColor() {
    final status = _statusLabel();
    switch (status) {
      case 'Completed':
        return const Color(0xFF3B82F6);
      case 'Pending':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel();
    final statusColor = _statusColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showCheckbox)
                      Checkbox(value: selected, onChanged: onChanged)
                    else
                      const SizedBox(width: 0, height: 0),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: _buildThumbnail(item.imagePath),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '\$${item.scannedBill.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: const Color(0xFF1F2937),
                      backgroundColor: const Color(0xFFF8FAFC),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

  Widget _buildThumbnail(String path) {
    final isUrl = path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:image');
    final placeholder = Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(child: Icon(Icons.image, color: Color(0xFF9CA3AF))),
    );

    if (kIsWeb) {
      if (isUrl) {
        return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
      }
      return placeholder;
    }

    if (isUrl) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
    }
    try {
      return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }
} 