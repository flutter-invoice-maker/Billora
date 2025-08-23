import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_state.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';

class SmartRecommendationsWidget extends StatefulWidget {
  final String? customerId;
  final Function(Product product) onProductSelected;
  final Color primaryColor;

  const SmartRecommendationsWidget({
    super.key,
    this.customerId,
    required this.onProductSelected,
    required this.primaryColor,
  });

  @override
  State<SmartRecommendationsWidget> createState() => _SmartRecommendationsWidgetState();
}

class _SmartRecommendationsWidgetState extends State<SmartRecommendationsWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.customerId != null && widget.customerId!.isNotEmpty) {
      _loadRecentInvoices();
    }
  }

  @override
  void didUpdateWidget(SmartRecommendationsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerId != oldWidget.customerId && 
        widget.customerId != null && 
        widget.customerId!.isNotEmpty) {
      _loadRecentInvoices();
    }
  }

  void _loadRecentInvoices() {
    // Load recent invoices for the customer
    // This will be handled by the parent widget through InvoiceCubit
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.customerId == null || widget.customerId!.isEmpty)
          Text(
            'Select a customer to see recommendations',
            style: TextStyle(color: Colors.grey.shade600),
          )
        else
          BlocBuilder<InvoiceCubit, InvoiceState>(
            builder: (context, state) {
              return state.when(
                loaded: (invoices) {
                  // Filter invoices for this customer and get recent items
                  final customerInvoices = invoices
                      .where((invoice) => invoice.customerId == widget.customerId)
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  
                  if (customerInvoices.isEmpty) {
                    return Text(
                      'No previous orders found for this customer',
                      style: TextStyle(color: Colors.grey.shade600),
                    );
                  }

                  // Get items from the 2 most recent invoices
                  final recentItems = <InvoiceItem>[];
                  for (final invoice in customerInvoices.take(2)) {
                    recentItems.addAll(invoice.items);
                  }

                  // Group items by product and sum quantities
                  final Map<String, InvoiceItem> groupedItems = {};
                  for (final item in recentItems) {
                    if (groupedItems.containsKey(item.productId)) {
                      final existing = groupedItems[item.productId]!;
                      groupedItems[item.productId] = existing.copyWith(
                        quantity: existing.quantity + item.quantity,
                        total: existing.total + item.total,
                      );
                    } else {
                      groupedItems[item.productId] = item;
                    }
                  }

                  final topItems = groupedItems.values.toList()
                    ..sort((a, b) => b.quantity.compareTo(a.quantity));

                  if (topItems.isEmpty) {
                    return Text(
                      'No items found in recent orders',
                      style: TextStyle(color: Colors.grey.shade600),
                    );
                  }

                  return Row(
                    children: topItems.take(2).map((item) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              // Create a Product from the InvoiceItem
                              final product = Product(
                                id: item.productId,
                                name: item.name,
                                description: item.description ?? '',
                                price: item.unitPrice,
                                category: 'General',
                                tax: item.tax,
                                inventory: 100,
                                companyOrShopName: null,
                                companyAddress: null,
                                companyPhone: null,
                                companyEmail: null,
                                companyWebsite: null,
                              );
                              widget.onProductSelected(product);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity.toInt()}',
                                    style: TextStyle(
                                      color: widget.primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Last: ${item.unitPrice.toString()}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (message) => Text(
                  'Error loading recommendations',
                  style: TextStyle(color: Colors.red.shade600),
                ),
                initial: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
      ],
    );
  }
} 