import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../cubit/invoice_cubit.dart';
import '../cubit/invoice_state.dart';
import '../../domain/entities/invoice.dart';
import 'invoice_form_page.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/core/utils/snackbar_helper.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/invoice/presentation/pages/invoice_preview_page.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:flutter/services.dart';
import 'package:billora/src/core/widgets/delete_dialog.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> with TickerProviderStateMixin {
  String _searchTerm = '';
  InvoiceStatus? _filterStatus;
  String? _selectedTag;
  String? _expandedInvoiceId;
  
  // Animation controllers
  late AnimationController _pullToRefreshController;
  late AnimationController _listController;
  late ScrollController _scrollController;
  
  // Pull to refresh
  bool _isRefreshing = false;
  final double _refreshThreshold = 100.0;
  
  // Virtual scroll
  final GlobalKey _listKey = GlobalKey();
  final double _itemHeight = 90.0; // Reduced item height
  int _visibleStart = 0;
  int _visibleCount = 10;
  
  // Selection mode
  bool _isSelectionMode = false;
  Set<String> _selectedInvoices = {};
  
  // Timeline for quick navigation
  final List<String> _timeline = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedInvoices.clear();
      }
    });
  }

  void _selectAll(List<Invoice> invoices) {
    setState(() {
      if (_selectedInvoices.length == invoices.length) {
        _selectedInvoices.clear();
      } else {
        _selectedInvoices = invoices.map((i) => i.id).toSet();
      }
    });
  }

  void _deleteSelectedInvoices() {
    if (_selectedInvoices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => DeleteDialog(
          title: 'Delete Invoices',
          message: 'Are you sure you want to delete ${_selectedInvoices.length} invoice(s)? This action cannot be undone.',
          itemName: '${_selectedInvoices.length} invoices',
          onDelete: () {
            for (String id in _selectedInvoices) {
              context.read<InvoiceCubit>().deleteInvoice(id);
            }
            _selectedInvoices.clear();
            _toggleSelectionMode();
          },
        ),
      );
    }
  }

  void _showTagsFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter by Tags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // All Tags option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_selectedTag == null ? Colors.black : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.all_inclusive,
                  color: _selectedTag == null ? Colors.white : const Color(0xFF666666),
                  size: 20,
                ),
              ),
              title: Text(
                'All Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedTag == null ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() => _selectedTag = null);
                Navigator.pop(context);
              },
            ),
            
            // Dynamic tags from invoices
            FutureBuilder<List<String>>(
              future: _getAvailableTags(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  );
                }
                
                final tags = snapshot.data ?? [];
                if (tags.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No tags available',
                      style: TextStyle(color: Color(0xFF999999)),
                    ),
                  );
                }
                
                return Column(
                  children: tags.map((tag) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_selectedTag == tag ? Colors.black : const Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.label_outline,
                        color: _selectedTag == tag ? Colors.white : const Color(0xFF666666),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedTag == tag ? FontWeight.w600 : FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedTag = tag);
                      Navigator.pop(context);
                    },
                  )).toList(),
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getAvailableTags() async {
    final state = context.read<InvoiceCubit>().state;
    return state.when(
      loaded: (invoices) {
        final allTags = <String>{};
        for (final invoice in invoices) {
          allTags.addAll(invoice.tags);
        }
        return allTags.toList()..sort();
      },
      initial: () => <String>[],
      loading: () => <String>[],
      error: (_) => <String>[],
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchInitialData();
  }

  void _initializeControllers() {
    _pullToRefreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    final currentState = context.read<InvoiceCubit>().state;
    currentState.when(
      initial: () => context.read<InvoiceCubit>().fetchInvoices(),
      loading: () => null,
      loaded: (_) => null,
      error: (_) => context.read<InvoiceCubit>().fetchInvoices(),
    );
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final pixels = _scrollController.position.pixels;
      
      // Pull to refresh
      if (pixels < -_refreshThreshold && !_isRefreshing) {
        _triggerRefresh();
      }
      
      // Virtual scrolling calculation
      _updateVisibleRange();
    }
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;
    
    final pixels = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    final start = math.max(0, (pixels / _itemHeight).floor() - 2);
    final count = ((viewportHeight / _itemHeight).ceil() + 4);
    
    if (start != _visibleStart || count != _visibleCount) {
      setState(() {
        _visibleStart = start;
        _visibleCount = count;
      });
    }
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    _pullToRefreshController.forward();
    
    HapticFeedback.lightImpact();
    
    try {
      await context.read<InvoiceCubit>().fetchInvoices();
      await Future.delayed(const Duration(milliseconds: 800)); // Smooth UX
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _pullToRefreshController.reverse();
      }
    }
  }

  void _jumpToLetter(String letter) {
    final state = context.read<InvoiceCubit>().state;
    state.whenOrNull(
      loaded: (invoices) {
        final filteredInvoices = _filterInvoices(invoices);
        final index = filteredInvoices.indexWhere(
          (invoice) => invoice.customerName.toUpperCase().startsWith(letter),
        );
        
        if (index >= 0 && _scrollController.hasClients) {
          _scrollController.animateTo(
            index * _itemHeight,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _pullToRefreshController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 4,
      pageTitle: AppStrings.invoiceListTitle,
      headerBottom: _InvoiceHeaderSearch(
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
        },
        selectedTag: _selectedTag,
        onTagTap: () {
          HapticFeedback.lightImpact();
          _showTagsFilter();
        },
      ),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: Stack(
          children: [
            Column(
              children: [
                // Selection toolbar
                if (_isSelectionMode)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSelectionMode ? 56 : 0,
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final filteredInvoices = context.read<InvoiceCubit>().state.maybeWhen(
                                loaded: (invoices) => _filterInvoices(invoices),
                                orElse: () => <Invoice>[],
                              );
                              _selectAll(filteredInvoices);
                            },
                            child: const Text(
                              'Select All',
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_selectedInvoices.length} selected',
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_selectedInvoices.isNotEmpty)
                            GestureDetector(
                              onTap: _deleteSelectedInvoices,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3B30),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _toggleSelectionMode,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF8E8E93),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
                
                // Filter Categories
                if (!_isSelectionMode) _buildFilterCategories(),

                const SizedBox(height: 8),

                Expanded(child: _buildInvoiceList()),
              ],
            ),
            // Chỉ hiển thị pull-to-refresh indicator khi đang refresh
            if (_isRefreshing) _buildPullToRefreshIndicator(),
            _buildTimelineScroll(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCategories() {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(
            icon: Icons.apps_rounded,
            label: 'All',
            isSelected: _filterStatus == null,
            onTap: () => setState(() {
              _filterStatus = null;
            }),
          ),
          _buildCategoryChip(
            icon: Icons.edit_outlined,
            label: 'Draft',
            isSelected: _filterStatus == InvoiceStatus.draft,
            onTap: () => setState(() {
              _filterStatus = InvoiceStatus.draft;
            }),
          ),
          _buildCategoryChip(
            icon: Icons.send_outlined,
            label: 'Sent',
            isSelected: _filterStatus == InvoiceStatus.sent,
            onTap: () => setState(() {
              _filterStatus = InvoiceStatus.sent;
            }),
          ),
          _buildCategoryChip(
            icon: Icons.check_circle_outline,
            label: 'Paid',
            isSelected: _filterStatus == InvoiceStatus.paid,
            onTap: () => setState(() {
              _filterStatus = InvoiceStatus.paid;
            }),
          ),
          _buildCategoryChip(
            icon: Icons.warning_outlined,
            label: 'Overdue',
            isSelected: _filterStatus == InvoiceStatus.overdue,
            onTap: () => setState(() {
              _filterStatus = InvoiceStatus.overdue;
            }),
          ),
          _buildCategoryChip(
            icon: Icons.cancel_outlined,
            label: 'Cancelled',
            isSelected: _filterStatus == InvoiceStatus.cancelled,
            onTap: () => setState(() {
              _filterStatus = InvoiceStatus.cancelled;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF666666),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF666666),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceList() {
  return BlocBuilder<InvoiceCubit, InvoiceState>(
    builder: (context, state) {
      // Nếu đang refreshing, giữ nguyên danh sách hiện tại và không show loading ở giữa
      if (_isRefreshing) {
        final loadedInvoices = state.maybeWhen(
          loaded: (invoices) => invoices,
          orElse: () => <Invoice>[],
        );
        return _buildVirtualScrollList(loadedInvoices);
      }

      return state.when(
        initial: () => _buildLoadingState(),
        loading: () => _buildLoadingState(),
        loaded: (invoices) {
          final filteredInvoices = _filterInvoices(invoices);
          if (filteredInvoices.isEmpty) {
            return _buildEmptyState();
          }
          return _buildVirtualScrollList(filteredInvoices);
        },
        error: (message) => _buildErrorState(message),
      );
    },
  );
}

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    return invoices.where((invoice) {
      final matchesSearch = _searchTerm.isEmpty ||
          invoice.customerName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          invoice.id.toLowerCase().contains(_searchTerm.toLowerCase());
      
      final matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
      final matchesTag = _selectedTag == null || invoice.tags.contains(_selectedTag);
      
      return matchesSearch && matchesStatus && matchesTag;
    }).toList();
  }

  Widget _buildVirtualScrollList(List<Invoice> invoices) {
    return RefreshIndicator(
      onRefresh: _triggerRefresh,
      backgroundColor: Colors.white,
      color: Colors.black,
      child: ListView.builder(
        key: _listKey,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          // Virtual scrolling optimization
          if (index < _visibleStart || index > _visibleStart + _visibleCount) {
            return SizedBox(height: _itemHeight);
          }
          
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _listController,
              curve: Interval(
                (index % 10) * 0.05,
                1.0,
                curve: Curves.easeOutQuart,
              ),
            )),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: _listController,
                curve: Interval(
                  (index % 10) * 0.05,
                  1.0,
                  curve: Curves.easeOutQuart,
                ),
              )),
              child: _buildCompactInvoiceCard(invoices[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactInvoiceCard(Invoice invoice, int index) {
    final isExpanded = _expandedInvoiceId == invoice.id;
    final isSelected = _selectedInvoices.contains(invoice.id);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: const Color(0xFF007AFF), width: 1)
            : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedInvoices.remove(invoice.id);
                } else {
                  _selectedInvoices.add(invoice.id);
                }
              });
            } else {
              HapticFeedback.lightImpact();
              setState(() {
                _expandedInvoiceId = isExpanded ? null : invoice.id;
              });
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              setState(() {
                _selectedInvoices.add(invoice.id);
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              _buildCompactCardHeader(invoice),
              if (isExpanded) _buildCardActions(invoice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCardHeader(Invoice invoice) {
    final isSelected = _selectedInvoices.contains(invoice.id);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Avatar, Name/ID, Status, Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCustomerColor(invoice.customerName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    invoice.customerName.isNotEmpty
                        ? invoice.customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Company name and ID (stacked)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#${invoice.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status badge + first Tag (stacked) shifted down slightly
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(invoice.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (invoice.tags.isNotEmpty)
                      Text(
                        '#${invoice.tags.first}',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.1,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Bottom row: Amount Due, Due Date, Tags, Expand Icon
          Row(
            children: [
              // Amount Due column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount Due',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.total.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              

              
              // Due Date column
              if (invoice.dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateShort(invoice.dueDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Expand/Collapse indicator and selection checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSelectionMode) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(Invoice invoice) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.visibility_outlined,
            label: 'Preview',
            onTap: () => _previewInvoice(invoice),
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => _showShareOptions(context, invoice, context.read<InvoiceCubit>()),
          ),
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () => _openForm(invoice),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF666666),
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineScroll() {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return state.whenOrNull(
          loaded: (invoices) {
            final filteredInvoices = _filterInvoices(invoices);
            if (filteredInvoices.length < 20) return const SizedBox.shrink();
            
            return Positioned(
              right: 8,
              top: 160,
              bottom: 100,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _timeline.map((letter) => GestureDetector(
                    onTap: () => _jumpToLetter(letter),
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            );
          },
        ) ?? const SizedBox.shrink();
      },
    );
  }

  Widget _buildPullToRefreshIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _pullToRefreshController,
        builder: (context, child) {
          return Container(
            height: 60,
            alignment: Alignment.center,
            child: Transform.scale(
              scale: _pullToRefreshController.value,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(height: 16),
          Text(
            'Loading invoices...',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No invoices found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first invoice to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<InvoiceCubit>().fetchInvoices(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getCustomerColor(String name) {
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF7ED321),
      const Color(0xFFF5A623),
      const Color(0xFFD0021B),
      const Color(0xFF9013FE),
      const Color(0xFF50E3C2),
    ];
    return colors[name.hashCode % colors.length];
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return const Color(0xFF8E8E93);
      case InvoiceStatus.sent:
        return const Color(0xFF007AFF);
      case InvoiceStatus.paid:
        return const Color(0xFF34C759);
      case InvoiceStatus.overdue:
        return const Color(0xFFFF3B30);
      case InvoiceStatus.cancelled:
        return const Color(0xFF6D6D70);
    }
  }

  // ignore: unused_element
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Keep existing methods for form, delete, preview, share with minimal changes
  void _openForm([Invoice? invoice]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<InvoiceCubit>()),
            BlocProvider.value(value: context.read<CustomerCubit>()),
            BlocProvider.value(value: context.read<ProductCubit>()),
            BlocProvider.value(value: context.read<SuggestionsCubit>()),
            BlocProvider.value(value: context.read<TagsCubit>()),
          ],
          child: InvoiceFormPage(invoice: invoice),
        ),
      ),
    );
    if (!mounted) return;
    context.read<InvoiceCubit>().fetchInvoices();
  }


  void _previewInvoice(Invoice invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InvoiceCubit>(),
          child: InvoicePreviewPage(invoice: invoice),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, Invoice invoice, InvoiceCubit cubit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Invoice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Download PDF
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              title: const Text(
                'Download PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: const Text(
                'Save to device',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              onTap: () async {
                if (!context.mounted) return;
                final currentContext = context;
                Navigator.pop(currentContext);
                
                SnackBarHelper.showInfo(
                  currentContext,
                  message: AppStrings.generatingPdf,
                  duration: const Duration(seconds: 1),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await Printing.layoutPdf(onLayout: (format) async => pdfData);
                  
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showSuccess(
                    currentContext,
                    message: AppStrings.pdfReady,
                    duration: const Duration(seconds: 2),
                  );
                } catch (e) {
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showError(
                    currentContext,
                    message: '${AppStrings.failedToGeneratePdf}: ${e.toString()}',
                    duration: const Duration(seconds: 4),
                  );
                }
              },
            ),
            
            // Create Shareable Link (Mobile only)
            if (!kIsWeb)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED321).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.link_outlined,
                    color: Color(0xFF7ED321),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Create Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: const Text(
                  'Upload and get shareable link',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
                onTap: () async {
                  if (!context.mounted) return;
                  final currentContext = context;
                  Navigator.pop(currentContext);
                  
                  SnackBarHelper.showInfo(
                    currentContext,
                    message: AppStrings.creatingLink,
                    duration: const Duration(seconds: 2),
                  );
                  
                  try {
                    final pdfData = await cubit.generatePdf(invoice);
                    final userId = invoice.customerId;
                    final url = await cubit.uploadPdf(
                      userId: userId,
                      invoiceId: invoice.id,
                      pdfData: pdfData,
                    );
                    await Clipboard.setData(ClipboardData(text: url));
                    
                    if (!currentContext.mounted) return;
                    
                    SnackBarHelper.showSuccess(
                      currentContext,
                      message: AppStrings.linkCreated,
                      duration: const Duration(seconds: 4),
                    );
                  } catch (e) {
                    if (!currentContext.mounted) return;
                    
                    SnackBarHelper.showError(
                      currentContext,
                      message: '${AppStrings.failedToCreateLink}: ${e.toString()}',
                      duration: const Duration(seconds: 4),
                    );
                  }
                },
              ),
            
            // Send via Email
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kIsWeb 
                      ? const Color(0xFF999999).withValues(alpha: 0.1)
                      : const Color(0xFFF5A623).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: kIsWeb ? const Color(0xFF999999) : const Color(0xFFF5A623),
                  size: 20,
                ),
              ),
              title: Text(
                'Send via Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kIsWeb ? const Color(0xFF999999) : Colors.black,
                ),
              ),
              subtitle: Text(
                kIsWeb ? 'Not available on web' : 'Email with PDF attachment',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              enabled: !kIsWeb,
              onTap: kIsWeb ? null : () async {
                if (!context.mounted) return;
                final sendInvoiceText = AppStrings.sendInvoice;
                final emailText = AppStrings.email;
                final cancelText = AppStrings.invoiceCancel;
                final sendText = AppStrings.send;
                final sendingEmailText = AppStrings.sendingEmail;
                final emailSentText = AppStrings.emailSentSuccessfully;
                final failedToSendText = AppStrings.failedToSendEmail;
                
                final controller = TextEditingController();
                final currentContext = context;
                final email = await showDialog<String>(
                  context: currentContext,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(sendInvoiceText),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: emailText,
                        hintText: 'Enter recipient email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(cancelText),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(sendText),
                      ),
                    ],
                  ),
                );
                
                if (email == null || email.isEmpty) return;
                
                if (currentContext.mounted) {
                  SnackBarHelper.showInfo(
                    currentContext,
                    message: sendingEmailText,
                    duration: const Duration(seconds: 2),
                  );
                }
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await cubit.sendEmail(
                    toEmail: email,
                    subject: 'Invoice #${invoice.id} - Billora',
                    body: 'Dear Customer,\n\nPlease find attached your invoice #${invoice.id}.\n\nThank you for your business!\n\nBest regards,\nBillora Team',
                    pdfData: pdfData,
                    fileName: 'invoice_${invoice.id}.pdf',
                  );
                  
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showSuccess(
                    currentContext,
                    message: '$emailSentText $email',
                    duration: const Duration(seconds: 4),
                  );
                } catch (e) {
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showError(
                    currentContext,
                    message: '$failedToSendText: ${e.toString()}',
                    duration: const Duration(seconds: 4),
                  );
                }
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return AppStrings.invoiceStatusDraft;
      case InvoiceStatus.sent:
        return AppStrings.invoiceStatusSent;
      case InvoiceStatus.paid:
        return AppStrings.invoiceStatusPaid;
      case InvoiceStatus.overdue:
        return AppStrings.invoiceStatusOverdue;
      case InvoiceStatus.cancelled:
        return AppStrings.invoiceStatusCancelled;
    }
  }
}

class _InvoiceHeaderSearch extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onChanged;
  final String? selectedTag;
  final VoidCallback onTagTap;

  const _InvoiceHeaderSearch({
    required this.onChanged,
    this.selectedTag,
    required this.onTagTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search invoices...',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
            suffixIcon: IconButton(
              onPressed: onTagTap,
              icon: Icon(
                Icons.label_outline,
                color: (selectedTag == null) ? Colors.black54 : Colors.black,
                size: 20,
              ),
              tooltip: 'Filter by tags',
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}