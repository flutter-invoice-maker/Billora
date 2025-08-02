import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  String? _selectedCategory;
  final List<String> _categories = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductCubit>().fetchProducts();
      }
    });
  }

  void _onCategoryChanged(String? value) {
    setState(() => _selectedCategory = value);
  }

  void _openForm([Product? product]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductCubit>(),
          child: ProductFormPage(product: product),
        ),
      ),
    );
    if (!mounted) return;
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.productListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: loc.productSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text(loc.productCategory),
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: _onCategoryChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                return state.when(
                  initial: () =>
                      const Center(child: CircularProgressIndicator()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  loaded: (products) {
                    var filtered = products;

                    if (_selectedCategory != null) {
                      filtered = filtered
                          .where((p) => p.category == _selectedCategory)
                          .toList();
                    }

                    if (_searchTerm.isNotEmpty) {
                      final searchWords = _searchTerm
                          .toLowerCase()
                          .split(' ')
                          .where((s) => s.isNotEmpty);

                      if (searchWords.isNotEmpty) {
                        filtered = filtered.where((p) {
                          final productWords = p.name
                              .toLowerCase()
                              .split(' ')
                              .where((s) => s.isNotEmpty)
                              .toSet();

                          return searchWords.every((searchWord) => productWords
                              .any((productWord) =>
                                  productWord.contains(searchWord)));
                        }).toList();
                      }
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return ProductCard(
                          product: product,
                          onEdit: () => _openForm(product),
                        );
                      },
                    );
                  },
                  error: (msg) => Center(child: Text(msg)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 