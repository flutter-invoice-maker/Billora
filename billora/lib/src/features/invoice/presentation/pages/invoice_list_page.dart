import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:async';
import '../cubit/invoice_cubit.dart';
import '../cubit/invoice_state.dart';
import '../../domain/entities/invoice.dart';
import 'invoice_form_page.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_preview_widget.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
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
  int _currentPage = 0;
  final int _itemsPerPage = 5;
  
  // Animation controllers
  late AnimationController _bannerController;
  late AnimationController _floatingIconsController;
  late PageController _pageController;
  int _currentBannerIndex = 0;

  final List<Map<String, dynamic>> _bannerData = [
    {
      'title': 'Invoice Management',
      'subtitle': 'Create, track and manage all your invoices',
      'icon': Icons.receipt_long_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    {
      'title': 'Payment Tracking',
      'subtitle': 'Monitor payment status and overdue invoices',
      'icon': Icons.payment_rounded,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    },
    {
      'title': 'Financial Reports',
      'subtitle': 'Generate detailed financial reports',
      'icon': Icons.analytics_rounded,
      'gradient': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<InvoiceCubit>().fetchInvoices();
    
    _bannerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pageController = PageController();
    
    // Auto-slide banner
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerData.length;
        });
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _floatingIconsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceCubit>().fetchInvoices();
      }
    });
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingIconsController,
      builder: (context, child) {
        return Stack(
          children: [
            // Invoice-themed floating icons
            ...List.generate(8, (index) {
              final icons = [
                Icons.receipt_long_outlined,
                Icons.attach_money_outlined,
                Icons.trending_up_outlined,
                Icons.credit_card_outlined,
                Icons.calculate_outlined,
                Icons.account_balance_wallet_outlined,
                Icons.payment_outlined,
                Icons.description_outlined,
              ];
              
              final double animationValue = _floatingIconsController.value;
              final double offsetX = 50 + (index * 45) +
                  math.sin((animationValue * 2 * math.pi) + (index * 0.8)) * 30;
              final double offsetY = 50 + (index * 35) +
                  math.cos((animationValue * 2 * math.pi) + (index * 0.6)) * 40;
              
              return Positioned(
                left: offsetX % MediaQuery.of(context).size.width,
                top: offsetY % (MediaQuery.of(context).size.height * 0.7),
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    icons[index],
                    size: 24 + (index % 3) * 8,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 3,
      pageTitle: AppStrings.invoiceListTitle,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFB794F6).withValues(alpha: 0.08),
              Colors.white,
              const Color(0xFF8B5FBF).withValues(alpha: 0.12),
              const Color(0xFF7C3AED).withValues(alpha: 0.06),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingIcons(),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Banner
                    _buildHeroBanner(),
                    // Search Bar
                    _buildSearchBar(),
                    // Invoice List
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: BlocBuilder<InvoiceCubit, InvoiceState>(
                        builder: (context, state) {
                          return state.when(
                            initial: () => SizedBox(
                              height: 200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF667EEA),
                                  ),
                                ),
                              ),
                            ),
                            loading: () => SizedBox(
                              height: 200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF667EEA),
                                  ),
                                ),
                              ),
                            ),
                            loaded: (invoices) {
                              final filteredInvoices = invoices.where((invoice) {
                                final matchesSearch = _searchTerm.isEmpty ||
                                  invoice.customerName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                                  invoice.id.toLowerCase().contains(_searchTerm.toLowerCase());
                                
                                final matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
                              
                                final matchesTag = _selectedTag == null || invoice.tags.contains(_selectedTag);
                                
                                return matchesSearch && matchesStatus && matchesTag;
                              }).toList();

                              if (filteredInvoices.isEmpty) {
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(32),
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha((0.1 * 255).round()),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.inbox_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No invoices found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try adjusting your search or filters',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final startIndex = _currentPage * _itemsPerPage;
                              final endIndex = math.min(startIndex + _itemsPerPage, filteredInvoices.length);
                              final paginatedInvoices = filteredInvoices.sublist(startIndex, endIndex);

                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: 20,
                                      left: 16,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                    child: Column(
                                      children: paginatedInvoices.map((invoice) => _buildInvoiceCard(
                                        invoice,
                                        _expandedInvoiceId == invoice.id,
                                      )).toList(),
                                    ),
                                  ),
                                  _buildPagination(filteredInvoices.length),
                                  // Bottom padding for floating tabbar
                                  const SizedBox(height: 120),
                                ],
                              );
                            },
                            error: (message) => SizedBox(
                              height: 300,
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.all(32),
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha((0.1 * 255).round()),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading invoices',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<InvoiceCubit>().fetchInvoices();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF667EEA),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add floating button
            Positioned(
              bottom: 120, // Move up more above tabbar
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _openForm(),
                backgroundColor: const Color(0xFF667eea),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _bannerData.length,
              itemBuilder: (context, index) {
                final banner = _bannerData[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: banner['gradient'],
                    ),
                  ),
                  child: Stack(
                    children: [
                      _buildFloatingIcons(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    banner['icon'],
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        banner['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['subtitle'],
                                        style: TextStyle(
                                          color: Colors.white.withAlpha((0.9 * 255).round()),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentBannerIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentBannerIndex == index
                          ? Colors.white
                          : Colors.white.withAlpha((0.5 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by customer or invoice ID',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
          GestureDetector(
            onTap: _showFilterPopup,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_filterStatus != null || _selectedTag != null)
                    ? const Color(0xFF667eea).withAlpha((0.2 * 255).round())
                    : Colors.grey.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.filter_list,
                color: (_filterStatus != null || _selectedTag != null)
                    ? const Color(0xFF667eea)
                    : Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep all the existing methods from the original file...
  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Filter Options',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              
              // Modern Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Status'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.label_outline, size: 18),
                          SizedBox(width: 6),
                          Text('Tags'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildModernStatusTab(),
                    _buildModernTagsTab(),
                  ],
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF667eea), width: 2),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _filterStatus = null;
                              _selectedTag = null;
                              _currentPage = 0;
                            });
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: Color(0xFF667eea),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatusTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select invoice status to filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              children: [
                _buildModernStatusChip('All Status', null),
                _buildModernStatusChip('Draft', InvoiceStatus.draft),
                _buildModernStatusChip('Sent', InvoiceStatus.sent),
                _buildModernStatusChip('Paid', InvoiceStatus.paid),
                _buildModernStatusChip('Overdue', InvoiceStatus.overdue),
                _buildModernStatusChip('Cancelled', InvoiceStatus.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(String label, InvoiceStatus? status) {
    final isSelected = _filterStatus == status;
    final statusColor = _getStatusColor(status);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
          _currentPage = 0;
        });
        // Close filter form and apply filter immediately
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? statusColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? statusColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: statusColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              color: isSelected ? Colors.white : statusColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTagsTab() {
    return FutureBuilder<List<String>>(
      future: _getAvailableTags(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }
        
        final allTags = snapshot.data ?? [];
        return StatefulBuilder(
          builder: (context, setState) {
            String searchQuery = '';
            List<String> filteredTags = allTags;
            
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Filter by Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select tags to filter invoices',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
                  const SizedBox(height: 16),
                  
                  // Search bar for tags
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tags...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, color: const Color(0xFF667eea), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filteredTags = allTags.where((tag) => 
                            tag.toLowerCase().contains(value.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags display with better layout
              Expanded(
                child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          // All Tags option
                      _buildModernTagChip('All Tags', null),
                          const SizedBox(height: 12),
                          
                          // Available tags
                          if (filteredTags.isNotEmpty) ...[
                            Text(
                              'Available Tags (${filteredTags.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filteredTags.map((tag) => _buildModernTagChip(tag, tag)).toList(),
                            ),
                          ] else if (searchQuery.isNotEmpty) ...[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No tags found for "$searchQuery"',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                    ],
                  ),
                ),
              ),
            ],
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernTagChip(String label, String? tag) {
    final isSelected = _selectedTag == tag;
    final tagColor = tag != null ? _getTagColor(tag) : const Color(0xFF667eea);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = tag;
          _currentPage = 0;
        });
        // Close filter form and apply filter immediately
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? tagColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? tagColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: tagColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tag != null ? Icons.label : Icons.all_inclusive,
              color: isSelected ? Colors.white : tagColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(InvoiceStatus? status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_outlined;
      case InvoiceStatus.sent:
        return Icons.send_outlined;
      case InvoiceStatus.paid:
        return Icons.check_circle_outlined;
      case InvoiceStatus.overdue:
        return Icons.warning_outlined;
      case InvoiceStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.apps;
    }
  }

  Future<List<String>> _getAvailableTags() async {
    // Get all unique tags from invoices
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

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage > 0
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: _currentPage > 0
                  ? const Color(0xFF667eea)
                  : Colors.grey[500],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Page numbers
          ...List.generate(
            math.min(5, totalPages),
            (index) {
              int pageNumber;
              if (totalPages <= 5) {
                pageNumber = index;
              } else {
                if (_currentPage <= 2) {
                  pageNumber = index;
                } else if (_currentPage >= totalPages - 3) {
                  pageNumber = totalPages - 5 + index;
                } else {
                  pageNumber = _currentPage - 2 + index;
                }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  onPressed: () => setState(() => _currentPage = pageNumber),
                  style: TextButton.styleFrom(
                    backgroundColor: _currentPage == pageNumber
                        ? const Color(0xFF667eea)
                        : Colors.white,
                    foregroundColor: _currentPage == pageNumber
                        ? Colors.white
                        : const Color(0xFF667eea),
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('${pageNumber + 1}'),
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // Next button
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage < totalPages - 1
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: _currentPage < totalPages - 1
                  ? const Color(0xFF667eea)
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? const Color(0xFF667eea).withAlpha((0.2 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: isExpanded ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isExpanded
            ? Border.all(color: const Color(0xFF667eea).withAlpha((0.3 * 255).round()))
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Card Content
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _expandedInvoiceId = isExpanded ? null : invoice.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left side
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(invoice.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusText(invoice.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (invoice.tags.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTagColor(invoice.tags.first),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  invoice.tags.first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${invoice.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          invoice.total.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${invoice.dueDate != null ? _formatDate(invoice.dueDate!) : 'No due date'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF667eea),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Action Buttons
          if (isExpanded)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Preview',
                    color: Colors.blue,
                    onTap: () => _previewInvoice(invoice),
                  ),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: Colors.green,
                    onTap: () => _showShareOptions(context, invoice, context.read<InvoiceCubit>()),
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    color: Colors.orange,
                    onTap: () => _openForm(invoice),
                  ),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () => _deleteInvoice(context, invoice),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods (keeping existing implementations)
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

  void _deleteInvoice(BuildContext parentContext, Invoice invoice) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => DeleteDialog(
        title: 'Delete Invoice',
        message: 'Are you sure you want to delete this invoice? This action cannot be undone.',
        itemName: 'Invoice #${invoice.id}',
        onDelete: () {
              parentContext.read<InvoiceCubit>().deleteInvoice(invoice.id);
            },
      ),
    );
  }

  void _previewInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6, // Giảm từ 70% xuống 60%
          height: MediaQuery.of(context).size.height * 0.7, // Giảm từ 95% xuống 70%
          padding: const EdgeInsets.all(12), // Giảm padding
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.preview, color: Colors.grey.shade600, size: 16), // Giảm size
                  const SizedBox(width: 6), // Giảm spacing
                  Text(
                    'Invoice Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Giảm font size
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18), // Giảm size
                    padding: EdgeInsets.zero, // Giảm padding
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Giảm kích thước
                  ),
                ],
              ),
              // Preview content - hiển thị template thu nhỏ trực tiếp
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Transform.scale(
                      scale: 0.8, // Scale 80% để hóa đơn lấp đầy container
                      child: SizedBox(
                        width: 595,
                        height: 842,
                        child: InvoicePreviewWidget(invoice: invoice),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            const Text(
              'Share Invoice PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Option 1: Generate & Download
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.blue),
              title: Text(AppStrings.downloadPdf),
              subtitle: Text(AppStrings.saveToDevice),
              onTap: () async {
                Navigator.pop(context);
                final scaffold = ScaffoldMessenger.of(context);
                final pdfReadyText = AppStrings.pdfReady;
                final failedToGenerateText = AppStrings.failedToGeneratePdf;
                
                scaffold.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 16),
                        Text(AppStrings.generatingPdf),
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await Printing.layoutPdf(onLayout: (format) async => pdfData);
                  
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(pdfReadyText),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('$failedToGenerateText: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            
            // Option 2: Upload & Share Link (Mobile only)
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.link_outlined, color: Colors.green),
                title: Text(AppStrings.createShareableLink),
                subtitle: Text(AppStrings.uploadAndGetLink),
                onTap: () async {
                  Navigator.pop(context);
                  final scaffold = ScaffoldMessenger.of(context);
                  final creatingLinkText = AppStrings.creatingLink;
                  final linkCreatedText = AppStrings.linkCreated;
                  final failedToCreateText = AppStrings.failedToCreateLink;
                  
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(creatingLinkText),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  try {
                    final pdfData = await cubit.generatePdf(invoice);
                    final userId = invoice.customerId;
                    final url = await cubit.uploadPdf(
                      userId: userId,
                      invoiceId: invoice.id,
                      pdfData: pdfData,
                    );
                    if (!mounted) return;
                    await Clipboard.setData(ClipboardData(text: url));
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text(linkCreatedText)),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('$failedToCreateText: ${e.toString()}')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            
            // Option 3: Send via Email (Mobile only due to CORS)
            ListTile(
              leading: Icon(Icons.email_outlined, color: kIsWeb ? Colors.grey : Colors.orange),
              title: Text(AppStrings.sendViaEmail),
              subtitle: Text(kIsWeb ? 'Not available on web due to CORS restrictions' : 'Email with PDF attachment'),
              enabled: !kIsWeb,
              
              onTap: kIsWeb ? null : () async {
                final scaffold = ScaffoldMessenger.of(context);
                final sendInvoiceText = AppStrings.sendInvoice;
                final emailText = AppStrings.email;
                final cancelText = AppStrings.invoiceCancel;
                final sendText = AppStrings.send;
                final sendingEmailText = AppStrings.sendingEmail;
                final emailSentText = AppStrings.emailSentSuccessfully;
                final failedToSendText = AppStrings.failedToSendEmail;
                
                final controller = TextEditingController();
                final email = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(sendInvoiceText),
                    content: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: emailText,
                        hintText: 'Enter recipient email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(cancelText),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(controller.text),
                        child: Text(sendText),
                      ),
                    ],
                  ),
                );
                
                if (email == null || email.isEmpty) return;
                
                scaffold.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(sendingEmailText),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await cubit.sendEmail(
                    toEmail: email,
                    subject: 'Invoice #${invoice.id} - Billora',
                    body: 'Dear Customer,\n\nPlease find attached your invoice #${invoice.id}.\n\nThank you for your business!\n\nBest regards,\nBillora Team',
                    pdfData: pdfData,
                    fileName: 'invoice_${invoice.id}.pdf',
                  );
                  
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('$emailSentText $email')),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('$failedToSendText: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus? status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.black45;
      default:
        return const Color(0xFF667eea);
    }
  }

  Color _getTagColor(String tag) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = tag.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

// Custom painter for animated invoice pattern
class InvoicePatternPainter extends CustomPainter {
  final double animationValue;

  InvoicePatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((0.1 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw animated receipt lines
    for (int i = 0; i < 8; i++) {
      final y = (size.height / 8) * i + (animationValue * 20);
      final startX = size.width * 0.6 + (math.sin(animationValue * 2 * math.pi + i) * 10);
      final endX = size.width * 0.9 + (math.sin(animationValue * 2 * math.pi + i) * 5);
      
      canvas.drawLine(
        Offset(startX, y % size.height),
        Offset(endX, y % size.height),
        paint,
      );
    }

    // Draw receipt perforations
    for (int i = 0; i < 20; i++) {
      final x = size.width * 0.55;
      final y = (size.height / 20) * i + (animationValue * 30);
      canvas.drawCircle(
        Offset(x, y % size.height),
        2,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
