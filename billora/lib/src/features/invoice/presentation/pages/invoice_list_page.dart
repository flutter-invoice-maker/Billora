import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:billora/src/core/widgets/delete_dialog.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> with TickerProviderStateMixin {
  String _searchTerm = '';
  InvoiceStatus? _selectedStatus;
  String? _selectedTag;
  
  // Pagination
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _listAnimationController;
  late AnimationController _categoryAnimationController;
  
  // Selection mode
  bool _isSelectionMode = false;
  Set<String> _selectedInvoices = {};
  
  // Categories filter
  bool _showCategories = false;
  bool _categoriesAnimationCompleted = false;
  
  final List<Map<String, dynamic>> _statusCategories = [
    {'value': null, 'label': 'All'},
    {'value': InvoiceStatus.draft, 'label': 'Draft'},
    {'value': InvoiceStatus.sent, 'label': 'Sent'},
    {'value': InvoiceStatus.paid, 'label': 'Paid'},
    {'value': InvoiceStatus.overdue, 'label': 'Overdue'},
    {'value': InvoiceStatus.cancelled, 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    // Only fetch invoices if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final invoiceState = context.read<InvoiceCubit>().state;
        invoiceState.when(
          loaded: (_) => null, // Already loaded
          initial: () => context.read<InvoiceCubit>().fetchInvoices(),
          loading: () => null, // Already loading
          error: (_) => context.read<InvoiceCubit>().fetchInvoices(),
        );
      }
    });
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _categoryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Listen to animation status
    _categoryAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _categoriesAnimationCompleted = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _categoriesAnimationCompleted = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listAnimationController.dispose();
    _categoryAnimationController.dispose();
    super.dispose();
  }

  void _toggleCategories() {
    setState(() {
      _showCategories = !_showCategories;
      if (_showCategories) {
        _categoryAnimationController.forward();
      } else {
        _categoriesAnimationCompleted = false;
        _categoryAnimationController.reverse();
      }
    });
  }

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

  void _showInvoiceOptions(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        ),
                        Text(
                          '#${invoice.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF8E8E93),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Options
            _buildOptionTile(
              icon: Icons.visibility_outlined,
              title: 'Preview',
              subtitle: 'View invoice details',
              color: const Color(0xFF2196F3),
              onTap: () {
                Navigator.pop(context);
                _previewInvoice(invoice);
              },
            ),
            
            _buildOptionTile(
              icon: Icons.edit_outlined,
              title: 'Edit',
              subtitle: 'Modify invoice',
              color: const Color(0xFF34C759),
              onTap: () {
                Navigator.pop(context);
                _openForm(invoice);
              },
            ),
            
            _buildOptionTile(
              icon: Icons.share_outlined,
              title: 'Share',
              subtitle: 'Send or export',
              color: const Color(0xFFF5A623),
              onTap: () {
                Navigator.pop(context);
                _showShareOptions(context, invoice, context.read<InvoiceCubit>());
              },
              isLast: true,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 0.5,
            color: const Color(0xFFE5E5EA),
          ),
      ],
    );
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
            _currentPage = 0;
          });
        },
        onFilterTap: _toggleCategories,
        isFilterActive: _selectedStatus != null,
      ),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: Column(
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
                            loaded: (invoices) => invoices.where((invoice) {
                              final searchLower = _searchTerm.toLowerCase();
                              final statusMatch = _selectedStatus == null ||
                                  invoice.status == _selectedStatus;
                              final searchMatch = searchLower.isEmpty ||
                                  invoice.customerName.toLowerCase().contains(searchLower) ||
                                  invoice.id.toLowerCase().contains(searchLower);
                              final tagMatch = _selectedTag == null || invoice.tags.contains(_selectedTag);
                              return statusMatch && searchMatch && tagMatch;
                            }).toList(),
                            orElse: () => <Invoice>[],
                          );
                          _selectAll(filteredInvoices);
                        },
                        child: const Text(
                          'Select All',
                          style: TextStyle(
                            color: Color(0xFF2196F3),
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

            // Categories with improved animation
            AnimatedBuilder(
              animation: _categoryAnimationController,
              builder: (context, child) {
                return ClipRect(
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: _categoryAnimationController,
                      curve: Curves.easeInOut,
                    ),
                    child: SizedBox(
                      height: 86,
                      child: _categoriesAnimationCompleted || _categoryAnimationController.value > 0.8
                          ? _buildCategories()
                          : Container(
                              height: 86,
                              color: Colors.white,
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Invoice List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<InvoiceCubit>().fetchInvoices();
                },
                color: const Color(0xFF2196F3),
                backgroundColor: Colors.white,
                child: BlocBuilder<InvoiceCubit, InvoiceState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                      ),
                      loaded: (invoices) {
                        final filteredInvoices = invoices.where((invoice) {
                          final searchLower = _searchTerm.toLowerCase();
                          final statusMatch = _selectedStatus == null ||
                              invoice.status == _selectedStatus;
                          final searchMatch = searchLower.isEmpty ||
                              invoice.customerName.toLowerCase().contains(searchLower) ||
                              invoice.id.toLowerCase().contains(searchLower);
                          final tagMatch = _selectedTag == null || invoice.tags.contains(_selectedTag);
                          return statusMatch && searchMatch && tagMatch;
                        }).toList();

                        if (filteredInvoices.isEmpty) {
                          return _buildEmptyState();
                        }

                        final startIndex = _currentPage * _itemsPerPage;
                        final endIndex = math.min(startIndex + _itemsPerPage, filteredInvoices.length);
                        final paginatedInvoices = filteredInvoices.sublist(startIndex, endIndex);

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildInvoiceGrid(paginatedInvoices),
                            ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                children: [
                                  const Spacer(),
                                  _buildPagination(filteredInvoices.length),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      error: (message) => _buildErrorState(message),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusCategories.length,
        itemBuilder: (context, index) {
          final category = _statusCategories[index];
          final isSelected = _selectedStatus == category['value'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = category['value'];
                _currentPage = 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base circle with icon only
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(category['value']),
                      color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
                      size: 28,
                    ),
                  ),
                  // Animated overlay with label
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    bottom: isSelected ? 0 : -54,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            category['label'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(InvoiceStatus? status) {
    switch (status) {
      case null:
        return Icons.apps;
      case InvoiceStatus.draft:
        return Icons.edit_outlined;
      case InvoiceStatus.sent:
        return Icons.send_outlined;
      case InvoiceStatus.paid:
        return Icons.check_circle_outline;
      case InvoiceStatus.overdue:
        return Icons.warning_outlined;
      case InvoiceStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  // Fixed responsive grid layout
  Widget _buildInvoiceGrid(List<Invoice> invoices) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate number of columns based on screen width
          int crossAxisCount;
          double cardWidth;
          bool isSmallScreen = constraints.maxWidth < 600;
          
          if (isSmallScreen) {
            // Small screens (mobile): 2 columns
            crossAxisCount = 2;
            cardWidth = (constraints.maxWidth - 16 * 2 - 12) / 2;
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 3;
            cardWidth = (constraints.maxWidth - 16 * 2 - 12 * 2) / 3;
          } else if (constraints.maxWidth < 1200) {
            crossAxisCount = 4;
            cardWidth = (constraints.maxWidth - 16 * 2 - 12 * 3) / 4;
          } else {
            crossAxisCount = 5;
            cardWidth = (constraints.maxWidth - 16 * 2 - 12 * 4) / 5;
          }

          // Tăng lại chiều cao card
          const double cardHeight = 183;
          final childAspectRatio = cardWidth / cardHeight;
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _listAnimationController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.easeOutQuart,
                  ),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: _listAnimationController,
                    curve: Interval(
                      index * 0.1,
                      1.0,
                      curve: Curves.easeOutQuart,
                    ),
                  )),
                  child: _buildInvoiceCard(invoices[index], isSmallScreen),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Thêm tham số isSmallScreen
  Widget _buildInvoiceCard(Invoice invoice, [bool isSmallScreen = false]) {
    final isSelected = _selectedInvoices.contains(invoice.id);
    
    return GestureDetector(
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
          _showInvoiceOptions(invoice);
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
      child: Container(
        height: 165, // Tăng lại chiều cao
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
              // Header with avatar, customer name, ID, and selection checkbox
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Customer name and ID - placed next to avatar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${invoice.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection checkbox
                  if (_isSelectionMode)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE5E5EA),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Amount Due label
              const Text(
                'Amount Due',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Amount
              Text(
                _formatAmount(invoice.total, isSmallScreen),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer with status icons and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Sửa từ end -> center
                children: [
                  // Status and tag icons
                  Row(
                    children: [
                      // Status icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getStatusColor(invoice.status),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(invoice.status),
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      // Additional tag icon if available
                      if (invoice.tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getTagColor(invoice.tags.first),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getTagIcon(invoice.tags.first),
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Đảm bảo luôn có widget ở bên phải để căn đều
                  invoice.dueDate != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateDDMMYYYY(invoice.dueDate!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1C1C1E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 70,
                          height: 24,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm format số tiền
  String _formatAmount(num amount, bool isSmallScreen) {
    if (!isSmallScreen || amount < 1000000) {
      return '${amount.toStringAsFixed(0)}.00';
    }
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '${amount.toStringAsFixed(0)}.00';
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

  Color _getTagColor(String tag) {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFE91E63),
    ];
    return colors[tag.hashCode % colors.length];
  }

  IconData _getTagIcon(String tag) {
    // Map common tags to icons
    final tagLower = tag.toLowerCase();
    if (tagLower.contains('gaming') || tagLower.contains('game')) return Icons.sports_esports;
    if (tagLower.contains('gucci') || tagLower.contains('fashion')) return Icons.checkroom;
    if (tagLower.contains('urgent') || tagLower.contains('priority')) return Icons.priority_high;
    if (tagLower.contains('sale') || tagLower.contains('discount')) return Icons.local_offer;
    if (tagLower.contains('premium') || tagLower.contains('vip')) return Icons.star;
    if (tagLower.contains('recurring') || tagLower.contains('monthly')) return Icons.refresh;
    if (tagLower.contains('new') || tagLower.contains('first')) return Icons.fiber_new;
    return Icons.tag; // Default tag icon
  }

  String _formatDateDDMMYYYY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox(height: 16);

    // Calculate page range for display
    List<int> pageNumbers = [];
    const int maxVisiblePages = 5;
    
    if (totalPages <= maxVisiblePages) {
      pageNumbers = List.generate(totalPages, (index) => index);
    } else {
      int start = math.max(0, _currentPage - 2);
      int end = math.min(totalPages - 1, start + maxVisiblePages - 1);
      
      if (end - start < maxVisiblePages - 1) {
        start = math.max(0, end - maxVisiblePages + 1);
      }
      
      pageNumbers = List.generate(end - start + 1, (index) => start + index);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          GestureDetector(
            onTap: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            child: Icon(
              Icons.chevron_left,
              color: _currentPage > 0 ? Colors.blue : Colors.grey[400],
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Page numbers
          ...pageNumbers.map((pageIndex) {
            final isCurrentPage = pageIndex == _currentPage;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = pageIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isCurrentPage ? 1.2 : 1.0,
                  child: Text(
                    '${pageIndex + 1}',
                    style: TextStyle(
                      fontSize: isCurrentPage ? 16 : 14,
                      fontWeight: isCurrentPage ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrentPage ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Show ellipsis if there are more pages
          if (totalPages > maxVisiblePages && pageNumbers.last < totalPages - 1) ...[
            const SizedBox(width: 8),
            Text(
              '...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _currentPage = totalPages - 1),
              child: Text(
                '$totalPages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
          
          const SizedBox(width: 16),
          
          // Next button
          GestureDetector(
            onTap: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            child: Icon(
              Icons.chevron_right,
              color: _currentPage < totalPages - 1 ? Colors.blue : Colors.grey[400],
              size: 24,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No invoices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search\nor create new invoices',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error loading invoices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.read<InvoiceCubit>().fetchInvoices(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  
                  await cubit.sendEmail(
                    toEmail: 'customer@example.com',
                    subject: 'Invoice #${invoice.id} - Billora',
                    body: 'Dear Customer,\n\nPlease find attached your invoice #${invoice.id}.\n\nThank you for your business!\n\nBest regards,\nBillora Team',
                    pdfData: pdfData,
                    fileName: 'invoice_${invoice.id}.pdf',
                  );
                  
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showSuccess(
                    currentContext,
                    message: 'Email sent to customer@example.com',
                    duration: const Duration(seconds: 4),
                  );
                } catch (e) {
                  if (!currentContext.mounted) return;
                  
                  SnackBarHelper.showError(
                    currentContext,
                    message: 'Failed to send email: ${e.toString()}',
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

}

class _InvoiceHeaderSearch extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isFilterActive;

  const _InvoiceHeaderSearch({
    required this.onChanged,
    required this.onFilterTap,
    required this.isFilterActive,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: Colors.black54, size: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search invoices...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,          
                  enabledBorder: InputBorder.none,   
                  focusedBorder: InputBorder.none,   
                  filled: false,                     
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onFilterTap,
              child: Icon(
                Icons.filter_list,
                color: isFilterActive ? const Color(0xFF2196F3) : Colors.black54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}