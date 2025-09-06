import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../domain/entities/product.dart';
import 'product_form_page.dart';

import 'package:billora/src/features/home/presentation/widgets/app_scaffold.dart';
import 'package:billora/src/core/utils/snackbar_helper.dart';
import 'package:billora/src/core/widgets/delete_dialog.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  final List<Map<String, dynamic>> _categories = [
    {'value': null, 'label': 'All', 'image': 'assets/images/all.png'},
    {'value': 'professional_business', 'label': 'Commercial', 'image': 'assets/images/commercial.png'},
    {'value': 'modern_creative', 'label': 'Sales', 'image': 'assets/images/sales.png'},
    {'value': 'minimal_clean', 'label': 'Proforma', 'image': 'assets/images/proforma.png'},
    {'value': 'corporate_formal', 'label': 'Transfer', 'image': 'assets/images/transfer.png'},
    {'value': 'service_based', 'label': 'Timesheet', 'image': 'assets/images/timesheet.png'},
    {'value': 'simple_receipt', 'label': 'Receipt', 'image': 'assets/images/receipt.png'},
  ];
  String _searchTerm = '';
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  late AnimationController _fadeController;
  late AnimationController _listAnimationController;
  late AnimationController _categoryAnimationController;
  bool _isSelectionMode = false;
  Set<String> _selectedProducts = {};
  bool _showCategories = false;
  bool _categoriesAnimationCompleted = false;

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
        _selectedProducts.clear();
      }
    });
  }

  void _selectAll(List<Product> products) {
    setState(() {
      if (_selectedProducts.length == products.length) {
        _selectedProducts.clear();
      } else {
        _selectedProducts = products.map((p) => p.id).toSet();
      }
    });
  }

  void _deleteSelectedProducts() {
    if (_selectedProducts.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => DeleteDialog(
          title: 'Delete Products',
          message: 'Are you sure you want to delete ${_selectedProducts.length} product(s)? This action cannot be undone.',
          itemName: '${_selectedProducts.length} products',
          onDelete: () {
            for (String id in _selectedProducts) {
              context.read<ProductCubit>().deleteProduct(id);
            }
            _selectedProducts.clear();
            _toggleSelectionMode();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTabIndex: 3, // Products tab
      pageTitle: 'Products',
      headerBottom: _ProductHeaderSearch(
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
            _currentPage = 0;
          });
        },
        onFilterTap: _toggleCategories,
        isFilterActive: _selectedCategory != null,
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
                          final filteredProducts = context.read<ProductCubit>().state.maybeWhen(
                            loaded: (products) => products.where((product) {
                              final searchLower = _searchTerm.toLowerCase();
                              final categoryMatch = _selectedCategory == null ||
                                  product.category == _selectedCategory;
                              final searchMatch = searchLower.isEmpty ||
                                  product.name.toLowerCase().contains(searchLower) ||
                                  (product.description?.toLowerCase().contains(searchLower) ?? false);
                              return categoryMatch && searchMatch;
                            }).toList(),
                            orElse: () => <Product>[],
                          );
                          _selectAll(filteredProducts);
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
                        '${_selectedProducts.length} selected',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_selectedProducts.isNotEmpty)
                        GestureDetector(
                          onTap: _deleteSelectedProducts,
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

            // Product List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductCubit>().fetchProducts();
                },
                color: const Color(0xFF2196F3),
                backgroundColor: Colors.white,
                child: BlocBuilder<ProductCubit, ProductState>(
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
                          return _buildEmptyState();
                        }

                        final startIndex = _currentPage * _itemsPerPage;
                        final endIndex = math.min(startIndex + _itemsPerPage, filteredProducts.length);
                        final paginatedProducts = filteredProducts.sublist(startIndex, endIndex);

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildProductGrid(paginatedProducts),
                            ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                children: [
                                  const Spacer(),
                                  _buildPagination(filteredProducts.length),
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
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['value'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['value'];
                _currentPage = 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base circle with image
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
                    child: ClipOval(
                      child: Image.asset(
                        category['image'],
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image not found
                          return Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(category['value']),
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 24,
                            ),
                          );
                        },
                      ),
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

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case null:
        return Icons.apps;
      case 'professional_business':
        return Icons.business;
      case 'modern_creative':
        return Icons.receipt;
      case 'minimal_clean':
        return Icons.description;
      case 'corporate_formal':
        return Icons.swap_horiz;
      case 'service_based':
        return Icons.schedule;
      case 'simple_receipt':
        return Icons.payment;
      default:
        return Icons.category;
    }
  }

  Widget _buildProductGrid(List<Product> products) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive grid based on screen width
          int crossAxisCount;
          double cardWidth;
          
          final screenWidth = constraints.maxWidth;
          const double desiredCardWidth = 160.0; // Desired card width
          const double spacing = 12.0;
          
          // Calculate how many cards can fit
          crossAxisCount = ((screenWidth - 32 + spacing) / (desiredCardWidth + spacing)).floor();
          crossAxisCount = math.max(2, crossAxisCount); // Minimum 2 columns
          crossAxisCount = math.min(4, crossAxisCount); // Maximum 4 columns
          
          // Calculate actual card width
          cardWidth = (screenWidth - 32 - (spacing * (crossAxisCount - 1))) / crossAxisCount;
          
          // Calculate aspect ratio to maintain consistent card height - Increased height
          const double cardHeight = 220.0; // Increased from 200 to 220
          final double aspectRatio = cardWidth / cardHeight;
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: products.length,
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
                  child: _buildModernProductCard(products[index], index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModernProductCard(Product product, int index) {
    final isSelected = _selectedProducts.contains(product.id);
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedProducts.remove(product.id);
            } else {
              _selectedProducts.add(product.id);
            }
          });
        } else {
          _openForm(product);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleSelectionMode();
          setState(() {
            _selectedProducts.add(product.id);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF2196F3), width: 1)
              : Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon/Image Area
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        product.isService ? Icons.build : Icons.inventory_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Selection checkbox - positioned at top right
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: _isSelectionMode ? 1.0 : 0.0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE5E5EA),
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
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (product.description != null) ...[
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Spacer(),
                    
                    // Price
                    Text(
                      product.price.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Category and Inventory
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getCategoryDisplayName(product.category),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (!product.isService)
                          Flexible(
                            child: Text(
                              'Stock: ${product.inventory}',
                              style: TextStyle(
                                fontSize: 9,
                                color: product.inventory > 0 ? Colors.green[600] : Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
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

  String _getCategoryDisplayName(String category) {
    final categoryData = _categories.firstWhere(
      (cat) => cat['value'] == category,
      orElse: () => {'label': 'Other'},
    );
    return categoryData['label'];
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
              Icons.inventory_2_outlined,
              size: 40,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search\nor add new products',
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
            'Error loading products',
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
            onTap: () => context.read<ProductCubit>().fetchProducts(),
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

class _ProductHeaderSearch extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isFilterActive;

  const _ProductHeaderSearch({
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
                  hintText: 'Search products...',
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