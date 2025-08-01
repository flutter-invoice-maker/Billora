import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/suggestions/presentation/widgets/product_suggestion_widget.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/tags/presentation/widgets/tag_input_widget.dart';

class SuggestionsDemoPage extends StatefulWidget {
  const SuggestionsDemoPage({super.key});

  @override
  State<SuggestionsDemoPage> createState() => _SuggestionsDemoPageState();
}

class _SuggestionsDemoPageState extends State<SuggestionsDemoPage> {
  List<String> selectedTags = [];
  String? selectedProductId;
  String? selectedProductName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Suggestions & Tags Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Suggestions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Suggestions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ProductSuggestionWidget(
                      customerId: 'demo-customer-id',
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          selectedProductId = suggestion.productId;
                          selectedProductName = suggestion.name;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected: ${suggestion.name}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      label: 'Search Products',
                      hint: 'Type to see smart suggestions...',
                    ),
                    if (selectedProductName != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: $selectedProductName',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tags Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags Management',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<TagsCubit, TagsState>(
                      builder: (context, state) {
                        return TagInputWidget(
                          selectedTags: selectedTags,
                          onTagsChanged: (tags) {
                            setState(() {
                              selectedTags = tags;
                            });
                          },
                          label: 'Invoice Tags',
                          hint: 'Add tags to categorize this invoice...',
                        );
                      },
                    ),
                    if (selectedTags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.label, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected Tags (${selectedTags.length}):',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: selectedTags.map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue.shade100,
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Usage Statistics Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Features',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.auto_awesome,
                      title: 'Smart Scoring',
                      description: 'Products are ranked by usage frequency, recency, and relevance to current customer',
                    ),
                    _buildFeatureItem(
                      icon: Icons.search,
                      title: 'Fuzzy Search',
                      description: 'Find products even with typos using Levenshtein distance algorithm',
                    ),
                    _buildFeatureItem(
                      icon: Icons.color_lens,
                      title: 'Colorful Tags',
                      description: 'Create and manage tags with custom colors for better organization',
                    ),
                    _buildFeatureItem(
                      icon: Icons.sync,
                      title: 'Usage Tracking',
                      description: 'Automatically tracks product and customer usage for better suggestions',
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Demo Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simulateInvoiceCreation,
                icon: const Icon(Icons.add),
                label: const Text('Simulate Invoice Creation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulateInvoiceCreation() {
    if (selectedProductName != null) {
      // Record product usage
      context.read<SuggestionsCubit>().recordProductUsage(
        productId: selectedProductId ?? 'demo-product-id',
        productName: selectedProductName!,
        price: 99.99,
        currency: 'USD',
        customerId: 'demo-customer-id',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice created with product: $selectedProductName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
} 