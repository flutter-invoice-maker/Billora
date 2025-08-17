import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
import 'package:billora/src/core/utils/snackbar_helper.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  final List<String> _categories = [
    'All Categories',
    'General',
    'Sales Invoice',
    'Electronics',
    'Clothing',
    'Food & Beverage',
    'Services',
    'Software',
    'Hardware'
  ];
  String _searchTerm = '';
  int _currentPage = 0;
  final int _itemsPerPage = 5;
  late AnimationController _bannerController;
  late AnimationController _floatingIconsController;

  @override
  void initState() {
    super.initState();
    // Only fetch products if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (_) => null, // Already loaded
          initial: () => context.read<ProductCubit>().fetchProducts(),
          loading: () => null, // Already loading
          error: (_) => context.read<ProductCubit>().fetchProducts(),
        );
      }
    });
    
    _bannerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _floatingIconsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove duplicate data fetching to prevent infinite loading
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingIconsController,
      builder: (context, child) {
        return Stack(
          children: [
            // Product-themed floating icons
            ...List.generate(8, (index) {
              final icons = [
                Icons.inventory_2_outlined,
                Icons.category_outlined,
                Icons.shopping_cart_outlined,
                Icons.local_offer_outlined,
                Icons.trending_up_outlined,
                Icons.analytics_outlined,
                Icons.star_outline,
                Icons.favorite_outline,
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
      currentTabIndex: 2,
      pageTitle: AppStrings.productListTitle,
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
                    // Search and Filter
                    _buildSearchAndFilter(),
                    // Product List
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: BlocBuilder<ProductCubit, ProductState>(
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
                            loaded: (products) {
                              final filteredProducts = products.where((product) {
                                final searchLower = _searchTerm.toLowerCase();
                                final categoryMatch = _selectedCategory == null ||
                                    product.category == _selectedCategory;
                                final searchMatch = searchLower.isEmpty ||
                                    product.name.toLowerCase().contains(searchLower) ||
                                    (product.description?.toLowerCase().contains(searchLower) ?? false);
                                return categoryMatch && searchMatch;
                              }).toList();

                              if (filteredProducts.isEmpty) {
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
                                            Icons.inventory_2_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No products found',
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
                              final endIndex = math.min(startIndex + _itemsPerPage, filteredProducts.length);
                              final paginatedProducts = filteredProducts.sublist(startIndex, endIndex);

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
                                      children: paginatedProducts.map((product) => ProductCard(
                                        product: product,
                                        onEdit: () => _openForm(product),
                                      )).toList(),
                                    ),
                                  ),
                                  _buildPagination(filteredProducts.length),
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
                                        'Error loading products',
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
                                          context.read<ProductCubit>().fetchProducts();
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 140,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFF667eea),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated grid pattern background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bannerController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ProductGridPainter(_bannerController.value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Product Catalog',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your inventory with smart categorization',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
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
                hintText: 'Search products...',
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
            onTap: _showCategoryFilter,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ),
          ),
        ],
      ),
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

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category ||
                      (category == 'All Categories' && _selectedCategory == null);
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF667eea) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF667eea) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF667eea))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category == 'All Categories' ? null : category;
                        _currentPage = 0;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All Categories':
        return Icons.apps;
      case 'General':
        return Icons.category;
      case 'Sales Invoice':
        return Icons.receipt;
      case 'Electronics':
        return Icons.devices;
      case 'Clothing':
        return Icons.checkroom;
      case 'Food & Beverage':
        return Icons.restaurant;
      case 'Services':
        return Icons.build;
      case 'Software':
        return Icons.computer;
      case 'Hardware':
        return Icons.hardware;
      default:
        return Icons.category;
    }
  }

  void _openForm([Product? product]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductCubit>(),
          child: ProductFormPage(product: product),
        ),
      ),
    );
    
    // If a product was created/updated, show success message
    if (result != null && result is Product && mounted) {
      SnackBarHelper.showSuccess(
        context,
        message: 'Product "${result.name}" ${product != null ? 'updated' : 'created'} successfully!',
      );
    }
  }
}

// Custom painter for product grid pattern
class ProductGridPainter extends CustomPainter {
  final double animationValue;

  ProductGridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((0.1 * 255).round())
      ..strokeWidth = 1;

    final spacing = 20.0;
    final offset = animationValue * spacing;

    // Vertical lines
    for (double x = offset; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = offset; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
