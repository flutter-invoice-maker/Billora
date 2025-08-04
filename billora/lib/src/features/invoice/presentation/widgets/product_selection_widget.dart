import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';
import 'package:billora/src/features/suggestions/domain/entities/suggestion.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';

class ProductSelectionWidget extends StatefulWidget {
  final List<Product> selectedProducts;
  final Function(Product, {double? quantity}) onProductSelected;
  final Function(Product) onProductDeselected;
  final String? customerId;
  final String? searchHint;

  const ProductSelectionWidget({
    super.key,
    required this.selectedProducts,
    required this.onProductSelected,
    required this.onProductDeselected,
    this.customerId,
    this.searchHint,
  });

  @override
  State<ProductSelectionWidget> createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Map<String, int> _lastInvoiceQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadLastInvoiceQuantities();
    // Load smart suggestions when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('🎯 ProductSelectionWidget: Loading initial suggestions for customer: ${widget.customerId}');
        context.read<SuggestionsCubit>().loadInitialSuggestions(
          customerId: widget.customerId,
        );
      }
    });
  }

  @override
  void didUpdateWidget(ProductSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload quantities when customer changes
    if (oldWidget.customerId != widget.customerId) {
      debugPrint('🎯 Customer changed from ${oldWidget.customerId} to ${widget.customerId}');
      _loadLastInvoiceQuantities();
    }
  }

  Future<void> _loadLastInvoiceQuantities() async {
    if (widget.customerId != null && widget.customerId!.isNotEmpty) {
      try {
        debugPrint('🎯 Loading last invoice quantities for customer: ${widget.customerId}');
        
        // Get invoices from InvoiceCubit state
        final invoiceState = context.read<InvoiceCubit>().state;
        invoiceState.when(
          loaded: (invoices) {
            // Filter invoices for this customer
            final customerInvoices = invoices.where((invoice) => 
              invoice.customerId == widget.customerId
            ).toList();
            
            if (customerInvoices.isNotEmpty) {
              // Sort by creation date descending and get the most recent
              customerInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final lastInvoice = customerInvoices.first;
              
              // Extract product quantities from the last invoice
              final quantities = <String, int>{};
              for (final item in lastInvoice.items) {
                quantities[item.productId] = item.quantity.toInt();
              }
              
              setState(() {
                _lastInvoiceQuantities.clear();
                _lastInvoiceQuantities.addAll(quantities);
              });
              
              debugPrint('🎯 Loaded quantities from last invoice: $quantities');
            } else {
              debugPrint('🎯 No previous invoices found for customer: ${widget.customerId}');
            }
          },
          initial: () => debugPrint('🎯 Invoices not loaded yet'),
          loading: () => debugPrint('🎯 Invoices are loading'),
          error: (message) => debugPrint('🎯 Error loading invoices: $message'),
        );
      } catch (e) {
        debugPrint('Error loading last invoice quantities: $e');
      }
    }
  }

  void _onSuggestionTap(Suggestion suggestion) {
    debugPrint('🎯 Suggestion tapped: ${suggestion.name}');
    debugPrint('🎯 Suggestion productId: ${suggestion.productId}');
    
    // Find the corresponding product from the product list
    final productState = context.read<ProductCubit>().state;
    productState.when(
      loaded: (products) {
        debugPrint('🎯 Available products: ${products.map((p) => '${p.name}(${p.id})').join(', ')}');
        debugPrint('🎯 Looking for product with ID: ${suggestion.productId}');
        
        Product? product;
        try {
          // First try to find by exact productId match
          product = products.firstWhere((p) => p.id == suggestion.productId);
          debugPrint('🎯 Found product by exact ID match: ${product.name}');
        } catch (e) {
          debugPrint('🎯 No exact ID match found, trying name match...');
          // If not found, try to find by name (fallback)
          try {
            product = products.firstWhere((p) => p.name.toLowerCase() == suggestion.name.toLowerCase());
            debugPrint('🎯 Found product by name match: ${product.name}');
          } catch (e2) {
            debugPrint('❌ Product not found in list for suggestion: ${suggestion.name}');
            debugPrint('❌ Available product names: ${products.map((p) => p.name).join(', ')}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.invoiceProductNotFound.replaceAll('{productName}', suggestion.name)),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        
        // Get quantity from last invoice, default to 1
        final quantity = _lastInvoiceQuantities[product.id] ?? 1;
        
        debugPrint('🎯 Using quantity from last invoice: $quantity for ${product.name}');
        
        // Auto-select the product with the quantity from last invoice
        widget.onProductSelected(product, quantity: quantity.toDouble());
        
        // Show success message with quantity info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.invoiceAddedWithQuantity
                .replaceAll('{productName}', suggestion.name)
                .replaceAll('{quantity}', quantity.toString())),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        debugPrint('🎯 Auto-selected ${product.name} with quantity: $quantity');
      },
      initial: () => debugPrint('Products not loaded yet'),
      loading: () => debugPrint('Products are loading'),
      error: (message) => debugPrint('Error loading products: $message'),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _getCategories(List<Product> products) {
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchHint ?? AppStrings.searchProducts,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            // Trigger smart suggestions when searching
            if (value.isNotEmpty) {
              context.read<SuggestionsCubit>().getProductSuggestions(
                customerId: widget.customerId,
                searchQuery: value,
                limit: 20,
              );
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Smart Suggestions Section
        BlocBuilder<SuggestionsCubit, SuggestionsState>(
          builder: (context, suggestionsState) {
            debugPrint('🎯 SuggestionsState: $suggestionsState');
            
            if (suggestionsState is SuggestionsLoaded) {
              final suggestions = suggestionsState.suggestions;
              debugPrint('🎯 Loaded ${suggestions.length} suggestions');
              
              // Only show suggestions if customer is selected
              if (widget.customerId == null || widget.customerId!.isEmpty) {
                return const SizedBox.shrink();
              }
              
              if (suggestions.isEmpty) {
                debugPrint('🎯 No suggestions available');
                return const SizedBox.shrink();
              }
              
              // Get products from suggestions filtered by customer
              final suggestedProducts = suggestions
                  .map((scored) => scored.suggestion)
                  .where((suggestion) => suggestion.customerId == widget.customerId)
                  .where((suggestion) => _searchQuery.isEmpty || 
                      suggestion.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .take(5)
                  .toList();
              
              debugPrint('🎯 Filtered to ${suggestedProducts.length} products matching "$_searchQuery" for customer ${widget.customerId}');
              
              if (suggestedProducts.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade50, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.invoiceSmartRecommendations,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              Text(
                                AppStrings.invoiceBasedOnHistory,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${suggestedProducts.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Suggestions Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: suggestedProducts.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestedProducts[index];
                      
                      return _ProfessionalSuggestionCard(
                        suggestion: suggestion,
                        isSelected: false, // Suggestions không hiển thị trạng thái selected
                        onTap: () => _onSuggestionTap(suggestion),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            } else if (suggestionsState is SuggestionsLoading) {
              // Only show loading if customer is selected
              if (widget.customerId == null || widget.customerId!.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.invoiceLoadingRecommendations,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Category Filter
        BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (products) {
                final categories = _getCategories(products);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          selectedColor: Colors.deepPurple.shade100,
                          checkmarkColor: Colors.deepPurple,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Products Grid
        BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (products) {
                final filteredProducts = _getFilteredProducts(products);
                
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? AppStrings.noProductsAvailable : AppStrings.noProductsFound,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isSelected = widget.selectedProducts.any((p) => p.id == product.id);
                    
                    // Debug: Log selection state with more detail
                    debugPrint('🎯 Product: ${product.name} (ID: ${product.id}) - Selected: $isSelected');
                    debugPrint('🎯 Selected products count: ${widget.selectedProducts.length}');
                    if (widget.selectedProducts.isNotEmpty) {
                      debugPrint('🎯 Selected products: ${widget.selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
                      // Check if any selected product has the same ID
                      final matchingSelected = widget.selectedProducts.where((p) => p.id == product.id).toList();
                      if (matchingSelected.isNotEmpty) {
                        debugPrint('🎯 Found ${matchingSelected.length} selected products with same ID: ${matchingSelected.map((p) => '${p.name}(${p.id})').join(', ')}');
                      }
                    }
                    
                    return _ProductCard(
                      product: product,
                      isSelected: isSelected,
                      onTap: () {
                        debugPrint('🎯 Tapped product: ${product.name} (ID: ${product.id})');
                        debugPrint('🎯 Current isSelected: $isSelected');
                        
                        if (isSelected) {
                          debugPrint('🎯 Deselecting product: ${product.name}');
                          widget.onProductDeselected(product);
                        } else {
                          debugPrint('🎯 Selecting product: ${product.name}');
                          // Validate product ID before selecting
                          if (product.id.isEmpty) {
                            debugPrint('❌ Product ID is empty for product: ${product.name}');
                            return;
                          }
                          
                          // Check inventory for non-service products
                          if (!product.isService && product.inventory <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} hiện không có trong kho'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          widget.onProductSelected(product);
                        }
                      },
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  'Error: $message',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and selection indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Description
              if (product.description != null && product.description!.isNotEmpty)
                Text(
                  product.description!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const Spacer(),
              
              // Price
              Text(
                product.price.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Inventory (only for non-service products)
              if (!product.isService)
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 12,
                      color: product.inventory > 0 ? Colors.blue.shade600 : Colors.red.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product.inventory}',
                      style: TextStyle(
                        fontSize: 11,
                        color: product.inventory > 0 ? Colors.blue.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 4),
              
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

class _ProfessionalSuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfessionalSuggestionCard({
    required this.suggestion,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and selection indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Remove selection indicator for suggestions
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Price
              if (suggestion.price != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    suggestion.price.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Usage count
              if (suggestion.usageCount > 0)
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${suggestion.usageCount}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 