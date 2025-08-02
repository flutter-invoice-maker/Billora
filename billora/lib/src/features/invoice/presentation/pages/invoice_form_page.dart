import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/product_selection_widget.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/tags/presentation/widgets/tag_input_widget.dart';
import 'package:billora/src/core/utils/localization_helper.dart';
import 'dart:math';

class InvoiceFormPage extends StatefulWidget {
  final Invoice? invoice;
  const InvoiceFormPage({super.key, this.invoice});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _customerId;
  late String _customerName;
  late List<InvoiceItem> _items;
  late double _subtotal;
  late double _tax;
  late double _total;
  late InvoiceStatus _status;
  late DateTime _createdAt;
  DateTime? _dueDate;
  DateTime? _paidAt;
  String? _note;
  String? _templateId;
  List<String> _tags = [];
  final List<Product> _selectedProducts = [];
  bool _isEdit = false;

  static const List<Map<String, String>> _templates = [
    {'id': 'template_a', 'name': 'Template A'},
    {'id': 'template_b', 'name': 'Template B'},
    {'id': 'template_c', 'name': 'Template C'},
  ];

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _isEdit = invoice != null;
    _customerId = invoice?.customerId ?? '';
    _customerName = invoice?.customerName ?? '';
    _items = invoice?.items ?? [];
    _subtotal = _items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
    _tax = _items.fold(0, (sum, item) => sum + item.tax);
    _total = _subtotal + _tax;
    _status = invoice?.status ?? InvoiceStatus.draft;
    _createdAt = invoice?.createdAt ?? DateTime.now();
    _dueDate = invoice?.dueDate;
    _paidAt = invoice?.paidAt;
    _note = invoice?.note;
    _templateId = invoice?.templateId;
    _tags = invoice?.tags ?? [];
    
    // Load suggestions and tags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SuggestionsCubit>().getProductSuggestions(
          customerId: _customerId,
          searchQuery: '',
          limit: 10,
        );
        context.read<TagsCubit>().getAllTags();
      }
    });
  }

  void _recalculateTotals() {
    _subtotal = _items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
    _tax = _items.fold(0, (sum, item) => sum + item.tax);
    _total = _subtotal + _tax;
  }

  void _onProductSelected(Product product, {double? quantity}) {
    setState(() {
      debugPrint('🎯 _onProductSelected called for: ${product.name} (ID: ${product.id})');
      debugPrint('🎯 Current _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      // Check if product is already selected
      if (_selectedProducts.any((p) => p.id == product.id)) {
        debugPrint('🎯 Product ${product.name} is already selected');
        return;
      }
      
      _selectedProducts.add(product);
      debugPrint('🎯 Added to _selectedProducts: ${product.name}');
      debugPrint('🎯 Updated _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      // Use provided quantity or default to 1
      final finalQuantity = quantity ?? 1.0;
      debugPrint('🎯 Adding ${product.name} with quantity: $finalQuantity');
      
      // Add to items list
      final item = InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        name: product.name,
        description: product.description,
        quantity: finalQuantity,
        unitPrice: product.price,
        tax: product.tax,
        total: (product.price * finalQuantity) + product.tax,
      );
      _items.add(item);
      _recalculateTotals();
      
      debugPrint('🎯 Final _selectedProducts count: ${_selectedProducts.length}');
      debugPrint('🎯 Final _items count: ${_items.length}');
    });
  }

  void _onProductDeselected(Product product) {
    setState(() {
      debugPrint('🎯 _onProductDeselected called for: ${product.name} (ID: ${product.id})');
      debugPrint('🎯 Current _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      // Remove from selected products
      final initialSelectedCount = _selectedProducts.length;
      _selectedProducts.removeWhere((p) => p.id == product.id);
      final removedFromSelected = initialSelectedCount - _selectedProducts.length;
      debugPrint('🎯 Removed from _selectedProducts: $removedFromSelected items');
      
      // Remove from items list
      final initialItemsCount = _items.length;
      _items.removeWhere((item) => item.productId == product.id);
      final removedFromItems = initialItemsCount - _items.length;
      debugPrint('🎯 Removed from _items: $removedFromItems items');
      
      _recalculateTotals();
      debugPrint('🎯 Removed ${product.name} from invoice');
      debugPrint('🎯 Final _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      debugPrint('🎯 Final _items: ${_items.map((item) => '${item.name}(${item.productId})').join(', ')}');
    });
  }

  void _updateItemQuantity(int index, double quantity) {
    setState(() {
      final item = _items[index];
      final total = (item.unitPrice * quantity) + item.tax;
      _items[index] = item.copyWith(quantity: quantity, total: total);
      _recalculateTotals();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _recalculateTotals();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _recalculateTotals();
    
    // Generate search keywords from invoice data
    final keywords = <String>[
      _customerName.toLowerCase(),
      ..._items.map((item) => item.name.toLowerCase()),
      ..._tags,
      if (_note != null && _note!.isNotEmpty) _note!.toLowerCase(),
    ];
    
    final invoice = Invoice(
      id: widget.invoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: _customerId.isNotEmpty ? _customerId : 'unknown',
      customerName: _customerName.isNotEmpty ? _customerName : 'Unknown Customer',
      items: _items,
      subtotal: _subtotal,
      tax: _tax,
      total: _total,
      status: _status,
      createdAt: _createdAt,
      dueDate: _dueDate,
      paidAt: _paidAt,
      note: _note,
      templateId: _templateId ?? 'template_a',
      tags: _tags,
      searchKeywords: keywords,
    );
    
    debugPrint('📝 Saving invoice with tags: $_tags');
    debugPrint('📝 Invoice tags count: ${_tags.length}');
    
    try {
      context.read<InvoiceCubit>().addInvoice(invoice);
      
      // Update product inventory for each item in the invoice
      for (final item in _items) {
        try {
          // Get current product to check inventory
          final productState = context.read<ProductCubit>().state;
          productState.when(
            loaded: (products) {
              final product = products.firstWhere((p) => p.id == item.productId);
              if (!product.isService) {
                final newInventory = product.inventory - item.quantity.toInt();
                if (newInventory >= 0) {
                  context.read<ProductCubit>().updateProductInventory(
                    item.productId, 
                    newInventory,
                  );
                  debugPrint('📦 Updated inventory for ${product.name}: ${product.inventory} -> $newInventory');
                } else {
                  debugPrint('⚠️ Warning: Insufficient inventory for ${product.name}');
                }
              }
            },
            initial: () => debugPrint('Products not loaded yet'),
            loading: () => debugPrint('Products are loading'),
            error: (message) => debugPrint('Error loading products: $message'),
          );
        } catch (e) {
          debugPrint('Error updating inventory for ${item.name}: $e');
        }
      }
      
      // Record product usage for smart suggestions after successful save
      for (final item in _items) {
        try {
          context.read<SuggestionsCubit>().recordProductUsage(
            productId: item.productId,
            productName: item.name,
            price: item.unitPrice,
            currency: 'USD',
            customerId: _customerId.isNotEmpty ? _customerId : null,
          );
        } catch (e) {
          debugPrint('Error recording product usage for ${item.name}: $e');
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? LocalizationHelper.getLocalizedString(context, 'invoiceInvoiceUpdated') : LocalizationHelper.getLocalizedString(context, 'invoiceInvoiceCreated'))),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${LocalizationHelper.getLocalizedString(context, 'error')} saving invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _createSampleProducts() {
    final random = Random();
    final sampleProducts = [
      Product(
        id: 'ps5_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
        name: 'PS5',
        description: 'PlayStation 5 Console',
        price: 25000000,
        category: 'Gaming',
        tax: 0.0,
        inventory: 10,
      ),
      Product(
        id: 'xbox_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
        name: 'Xbox Series X',
        description: 'Xbox Series X Console',
        price: 22000000,
        category: 'Gaming',
        tax: 0.0,
        inventory: 5,
      ),
      Product(
        id: 'nintendo_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
        name: 'Nintendo Switch',
        description: 'Nintendo Switch Console',
        price: 8000000,
        category: 'Gaming',
        tax: 0.0,
        inventory: 15,
      ),
      Product(
        id: 'gucci_tshirt_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
        name: 'Áo Thun GUCCI',
        description: 'Màu Vàng, Size XXL',
        price: 5000000,
        category: 'Fashion',
        tax: 0.0,
        inventory: 20,
      ),
    ];
    
    for (final product in sampleProducts) {
      try {
        context.read<ProductCubit>().addProduct(product);
        debugPrint('✅ Added sample product: ${product.name} (ID: ${product.id})');
      } catch (e) {
        debugPrint('Error adding sample product: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? LocalizationHelper.getLocalizedString(context, 'invoiceEditTitle') : LocalizationHelper.getLocalizedString(context, 'invoiceAddTitle')),
        actions: [
          // Debug button to create sample products
          if (!_isEdit)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: LocalizationHelper.getLocalizedString(context, 'invoiceCreateSampleProducts'),
              onPressed: _createSampleProducts,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? LocalizationHelper.getLocalizedString(context, 'invoiceUpdate') : LocalizationHelper.getLocalizedString(context, 'invoiceSave')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _save,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Dropdown chọn khách hàng
            BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (customers) => DropdownButtonFormField<String>(
                    value: _customerId.isNotEmpty ? _customerId : null,
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.getLocalizedString(context, 'customerName'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: customers.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )).toList(),
                    onChanged: (id) {
                      final customer = customers.firstWhere((c) => c.id == id);
                      setState(() {
                        _customerId = customer.id;
                        _customerName = customer.name;
                      });
                      
                      // Load suggestions for this customer
                      context.read<SuggestionsCubit>().loadSuggestionsForCustomer(customer.id);
                    },
                    validator: (v) => v == null || v.isEmpty ? LocalizationHelper.getLocalizedString(context, 'customerNameRequired') : null,
                  ),
                  orElse: () => const LinearProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 24),
            // Dropdown chọn template
            DropdownButtonFormField<String>(
              value: _templateId,
              decoration: InputDecoration(
                labelText: LocalizationHelper.getLocalizedString(context, 'template'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _templates.map((tpl) => DropdownMenuItem(
                value: tpl['id'],
                child: Text(tpl['name'] ?? 'Unknown Template'),
              )).toList(),
              onChanged: (id) => setState(() => _templateId = id),
              validator: (v) => v == null || v.isEmpty ? LocalizationHelper.getLocalizedString(context, 'pleaseSelectTemplate') : null,
            ),
            const SizedBox(height: 24),
            // Tags Section
            BlocBuilder<TagsCubit, TagsState>(
              builder: (context, tagsState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Tags', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TagInputWidget(
                      selectedTags: _tags,
                      onTagsChanged: (tags) {
                        setState(() {
                          _tags = tags;
                        });
                      },
                      label: LocalizationHelper.getLocalizedString(context, 'invoiceTags'),
                      hint: LocalizationHelper.getLocalizedString(context, 'addTagsPlaceholder'),
                      ),
                      const SizedBox(height: 16),
                  ],
                );
              },
            ),
            
            // Product Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ProductSelectionWidget(
                  selectedProducts: _selectedProducts,
                  onProductSelected: _onProductSelected,
                  onProductDeselected: _onProductDeselected,
                  searchHint: LocalizationHelper.getLocalizedString(context, 'searchProductsToAdd'),
                  customerId: _customerId.isNotEmpty ? _customerId : null,
                ),
              ],
            ),
            
            // Selected Items Display
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Selected Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(item.description ?? '', style: const TextStyle(color: Colors.grey)),
                                      Row(
                                        children: [
                                          Text('${LocalizationHelper.getLocalizedString(context, 'productPrice')}: '),
                                          Text(LocalizationHelper.formatCurrency(item.unitPrice, context)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('${LocalizationHelper.getLocalizedString(context, 'productTax')}: '),
                                          Text(LocalizationHelper.formatCurrency(item.tax, context)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: item.quantity.toStringAsFixed(0),
                                        decoration: InputDecoration(
                                          labelText: LocalizationHelper.getLocalizedString(context, 'productInventory'),
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) {
                                          final qty = double.tryParse(v) ?? 1;
                                          _updateItemQuantity(idx, qty);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: LocalizationHelper.getLocalizedString(context, 'invoiceRemoveItem'),
                                        onPressed: () => _removeItem(idx),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
            const SizedBox(height: 24),
            // Due date picker
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.getLocalizedString(context, 'invoiceDueDate'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_dueDate != null ? '${_dueDate!.toLocal()}'.split(' ')[0] : LocalizationHelper.getLocalizedString(context, 'invoiceSelectDate')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InvoiceStatus>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.getLocalizedString(context, 'invoiceStatus'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: InvoiceStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    )).toList(),
                    onChanged: (s) => setState(() => _status = s ?? InvoiceStatus.draft),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tổng tiền
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${LocalizationHelper.getLocalizedString(context, 'invoiceSubtotal')}: ${LocalizationHelper.formatCurrency(_subtotal, context)}'),
                    Text('${LocalizationHelper.getLocalizedString(context, 'invoiceTax')}: ${LocalizationHelper.formatCurrency(_tax, context)}'),
                    Text('${LocalizationHelper.getLocalizedString(context, 'invoiceTotal')}: ${LocalizationHelper.formatCurrency(_total, context)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Note
            TextFormField(
              initialValue: _note,
              decoration: InputDecoration(
                labelText: LocalizationHelper.getLocalizedString(context, 'invoiceNote'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSaved: (v) => _note = v,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
} 