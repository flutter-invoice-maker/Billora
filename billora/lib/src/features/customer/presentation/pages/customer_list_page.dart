import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:async';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import '../../domain/entities/customer.dart';
import 'customer_form_page.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
import 'package:billora/src/core/widgets/delete_dialog.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage>
    with TickerProviderStateMixin {
  String _searchTerm = '';
  int _currentPage = 0;
  final int _itemsPerPage = 5;
  late AnimationController _bannerController;
  late AnimationController _floatingIconsController;
  late PageController _pageController;
  int _currentBannerIndex = 0;

  final List<Map<String, dynamic>> _bannerData = [
    {
      'title': 'Manage Your Customers',
      'subtitle': 'Keep track of all your valuable customers',
      'icon': Icons.people_alt_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    {
      'title': 'Customer Insights',
      'subtitle': 'Analyze customer data and relationships',
      'icon': Icons.analytics_rounded,
      'gradient': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    },
    {
      'title': 'Build Relationships',
      'subtitle': 'Strengthen connections with your clients',
      'icon': Icons.handshake_rounded,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
    
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
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 1, // Customer tab index
      pageTitle: 'Customer Management',
      body: Stack(
        children: [
          _buildFloatingIcons(),
          SafeArea(
            child: Column(
              children: [
                // Hero Banner
                _buildHeroBanner(),
                // Search Bar
                _buildSearchBar(),
                // Customer List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {
                        return state.when(
                          initial: () => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF667EEA),
                              ),
                            ),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF667EEA),
                              ),
                            ),
                          ),
                          loaded: (customers) {
                            final filteredCustomers = customers.where((customer) {
                              final searchLower = _searchTerm.toLowerCase();
                              return searchLower.isEmpty ||
                                  customer.name.toLowerCase().contains(searchLower) ||
                                  (customer.email?.toLowerCase().contains(searchLower) ?? false) ||
                                  (customer.phone?.toLowerCase().contains(searchLower) ?? false);
                            }).toList();

                            if (filteredCustomers.isEmpty) {
                              return Center(
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
                                        Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No customers found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final startIndex = _currentPage * _itemsPerPage;
                            final endIndex = math.min(startIndex + _itemsPerPage, filteredCustomers.length);
                            final paginatedCustomers = filteredCustomers.sublist(startIndex, endIndex);

                            return Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: paginatedCustomers.length,
                                    itemBuilder: (context, index) {
                                      final customer = paginatedCustomers[index];
                                      return _buildCustomerCard(customer);
                                    },
                                  ),
                                ),
                                _buildPagination(filteredCustomers.length),
                              ],
                            );
                          },
                          error: (message) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading customers',
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            // Page indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerData.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == index
                          ? Colors.white
                          : Colors.white.withAlpha((0.5 * 255).round()),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
            _currentPage = 0;
          });
        },
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF667eea),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      customer.email!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (customer.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      customer.phone!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _showOptionsMenu(customer),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.more_vert,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        onTap: () => _openForm(customer),
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingIconsController,
      builder: (context, child) {
        return Stack(
          children: [
            // Customer-themed floating icons
            ...List.generate(8, (index) {
              final icons = [
                Icons.person_outline,
                Icons.email_outlined,
                Icons.phone_outlined,
                Icons.location_on_outlined,
                Icons.business_outlined,
                Icons.contact_page_outlined,
                Icons.group_outlined,
                Icons.account_circle_outlined,
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

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Customer',
        message: 'Are you sure you want to delete this customer? This action cannot be undone.',
        itemName: customer.name,
        onDelete: () {
          context.read<CustomerCubit>().deleteCustomer(customer.id);
        },
      ),
    );
  }

  void _showOptionsMenu(Customer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              title: const Text('Edit Customer'),
              subtitle: const Text('Modify customer details'),
              onTap: () {
                Navigator.pop(context);
                _openForm(customer);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: const Text('Delete Customer'),
              subtitle: const Text('Remove from database'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(customer);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openForm([Customer? customer]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(customer: customer),
      ),
    );
  }
}
