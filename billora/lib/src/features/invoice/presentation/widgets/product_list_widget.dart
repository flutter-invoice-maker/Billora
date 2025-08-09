import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';

class ProductListWidget extends StatefulWidget {
  final List<Product> selectedProducts;
  final Function(Product product) onProductSelected;
  final Function(Product product) onProductDeselected;
  final Color primaryColor;

  const ProductListWidget({
    super.key,
    required this.selectedProducts,
    required this.onProductSelected,
    required this.onProductDeselected,
    required this.primaryColor,
  });

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  String _searchTerm = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
        ),
        const SizedBox(height: 12),
        
        // Category filter
        BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (products) {
                final categories = products
                    .map((p) => p.category)
                    .toSet()
                    .toList()
                  ..sort();
                
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                            selectedColor: widget.primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: widget.primaryColor,
                          ),
                        );
                      }
                      
                      final category = categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: widget.primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: widget.primaryColor,
                        ),
                      );
                    },
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // Product list
        Expanded(
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (products) {
                  final filteredProducts = products.where((product) {
                    // Filter by search term
                    final matchesSearch = _searchTerm.isEmpty ||
                        product.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                        (product.description?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);
                    
                    // Filter by category
                    final matchesCategory = _selectedCategory == null || 
                        product.category == _selectedCategory;
                    
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchTerm.isEmpty && _selectedCategory == null
                                ? 'No products available'
                                : 'No products match your criteria',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isSelected = widget.selectedProducts.any((p) => p.id == product.id);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected 
                            ? widget.primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected 
                                ? widget.primaryColor 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: widget.primaryColor.withValues(alpha: 0.2),
                            child: Icon(
                              product.isService ? Icons.miscellaneous_services : Icons.inventory,
                              color: widget.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? widget.primaryColor : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.description?.isNotEmpty == true)
                                Text(
                                  product.description!,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? widget.primaryColor.withValues(alpha: 0.8)
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              Text(
                                'Stock: ${product.inventory}',
                                style: TextStyle(
                                  color: isSelected 
                                      ? widget.primaryColor.withValues(alpha: 0.8)
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected 
                              ? IconButton(
                                  icon: Icon(Icons.remove_circle, color: widget.primaryColor),
                                  onPressed: () => widget.onProductDeselected(product),
                                )
                              : IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: widget.primaryColor),
                                  onPressed: () => widget.onProductSelected(product),
                                ),
                          onTap: () {
                            if (isSelected) {
                              widget.onProductDeselected(product);
                            } else {
                              widget.onProductSelected(product);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading products',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
                orElse: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ],
    );
  }
} 