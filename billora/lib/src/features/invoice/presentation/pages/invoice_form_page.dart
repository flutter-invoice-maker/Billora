import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/customer_selection_widget.dart';
import 'package:billora/src/features/invoice/presentation/widgets/product_list_widget.dart';
import 'package:billora/src/features/invoice/presentation/widgets/smart_recommendations_widget.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/invoice/presentation/widgets/ai_floating_button.dart';

class InvoiceFormPage extends StatefulWidget {
  final Invoice? invoice;
  const InvoiceFormPage({super.key, this.invoice});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> with TickerProviderStateMixin {
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

  // Simple animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const List<Map<String, dynamic>> _templates = [
    {
      'id': 'professional_business',
      'name': 'Professional Business',
      'description': 'For Commercial, Tax, Electronic, VAT invoices',
      'icon': Icons.business_center,
      'color': Color(0xFF1E3A8A),
    },
    {
      'id': 'modern_creative',
      'name': 'Modern Creative',
      'description': 'For Sales, Self-billing invoices',
      'icon': Icons.palette,
      'color': Color(0xFF7C3AED),
    },
    {
      'id': 'minimal_clean',
      'name': 'Minimal Clean',
      'description': 'For Proforma, Credit/Debit notes',
      'icon': Icons.style,
      'color': Color(0xFF374151),
    },
    {
      'id': 'corporate_formal',
      'name': 'Corporate Formal',
      'description': 'For Internal transfers, consignment notes',
      'icon': Icons.account_balance,
      'color': Color(0xFF1F2937),
    },
    {
      'id': 'service_based',
      'name': 'Service Based',
      'description': 'For Timesheet, transport receipts',
      'icon': Icons.miscellaneous_services,
      'color': Color(0xFF0F766E),
    },
    {
      'id': 'simple_receipt',
      'name': 'Simple Receipt',
      'description': 'For Bank fees, stamps/tickets/cards',
      'icon': Icons.receipt_long,
      'color': Color(0xFF6B7280),
    },
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
    _templateId = invoice?.templateId ?? 'template_a';
    _tags = invoice?.tags ?? [];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _checkScannerData();
      }
    });
  }

  void _checkScannerData() {
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      final args = route.settings.arguments as Map<String, dynamic>;
      if (args['fromScanner'] == true && args['scannedBill'] != null) {
        _populateFromScannedBill(args['scannedBill']);
      }
      // Thêm xử lý QR scan data
      if (args['fromQRScan'] == true && args['invoiceId'] != null) {
        _populateFromQRScan(args['invoiceId']);
      }
    }
  }

  void _populateFromScannedBill(dynamic scannedBill) {
    try {
      setState(() {
        _customerName = scannedBill.storeName ?? 'Store';
        _total = scannedBill.totalAmount ?? 0.0;
        _subtotal = _total;
        _tax = 0.0;
        
        if (scannedBill.items != null && scannedBill.items.isNotEmpty) {
          _items = scannedBill.items.map<InvoiceItem>((item) => InvoiceItem(
            id: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            productId: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item.description ?? 'Product',
            description: item.description ?? '',
            quantity: item.quantity ?? 1.0,
            unitPrice: item.unitPrice ?? 0.0,
            total: item.totalPrice ?? 0.0,
            tax: 0.0,
            companyOrShopName: scannedBill.storeName,
            companyAddress: scannedBill.address,
            companyPhone: scannedBill.phone,
            companyEmail: scannedBill.email,
          )).toList();
        }
        
        _note = 'Scanned from receipt: \'${scannedBill.scanDate?.toString() ?? DateTime.now().toString()}\'';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-filled data from scanned receipt!'),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      debugPrint('Error populating from scanned bill: $e');
    }
  }

  void _populateFromQRScan(String invoiceId) {
    try {
      // Tìm hóa đơn trong state hiện tại
      final invoiceState = context.read<InvoiceCubit>().state;
      invoiceState.when(
        loaded: (invoices) {
          try {
            final invoice = invoices.firstWhere((inv) => inv.id == invoiceId);
            _populateFromInvoice(invoice);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã tải hóa đơn: ${invoice.customerName}'),
                backgroundColor: Colors.black87,
              ),
            );
          } catch (e) {
            debugPrint('Invoice not found in current state: $e');
            // Thử fetch từ server
            _fetchInvoiceFromServer(invoiceId);
          }
        },
        initial: () => _fetchInvoiceFromServer(invoiceId),
        loading: () => _fetchInvoiceFromServer(invoiceId),
        error: (_) => _fetchInvoiceFromServer(invoiceId),
      );
    } catch (e) {
      debugPrint('Error populating from QR scan: $e');
    }
  }

  void _fetchInvoiceFromServer(String invoiceId) {
    // Fetch hóa đơn từ server
    context.read<InvoiceCubit>().fetchInvoices();
    
    // Đợi một chút để fetch hoàn thành
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final invoiceState = context.read<InvoiceCubit>().state;
        invoiceState.when(
          loaded: (invoices) {
            try {
              final invoice = invoices.firstWhere((inv) => inv.id == invoiceId);
              _populateFromInvoice(invoice);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã tải hóa đơn từ server: ${invoice.customerName}'),
                  backgroundColor: Colors.black87,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không tìm thấy hóa đơn'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          initial: () => null,
          loading: () => null,
          error: (message) => null,
        );
      }
    });
  }

  void _populateFromInvoice(Invoice invoice) {
    setState(() {
      _customerId = invoice.customerId;
      _customerName = invoice.customerName;
      _items = List.from(invoice.items);
      _subtotal = invoice.subtotal;
      _tax = invoice.tax;
      _total = invoice.total;
      _status = invoice.status;
      _createdAt = invoice.createdAt;
      _dueDate = invoice.dueDate;
      _paidAt = invoice.paidAt;
      _note = invoice.note;
      _templateId = invoice.templateId;
      _tags = List.from(invoice.tags);
      
      // Cập nhật selected products
      _selectedProducts.clear();
      for (final item in _items) {
        // Tìm product tương ứng trong ProductCubit
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            try {
              final product = products.firstWhere((p) => p.id == item.productId);
              _selectedProducts.add(product);
            } catch (e) {
              // Product không tồn tại, bỏ qua
            }
          },
          initial: () => null,
          loading: () => null,
          error: (_) => null,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final customerState = context.read<CustomerCubit>().state;
        customerState.when(
          loaded: (_) => null,
          initial: () => context.read<CustomerCubit>().fetchCustomers(),
          loading: () => null,
          error: (_) => context.read<CustomerCubit>().fetchCustomers(),
        );
        
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (_) => null,
          initial: () => context.read<ProductCubit>().fetchProducts(),
          loading: () => null,
          error: (_) => context.read<ProductCubit>().fetchProducts(),
        );
        
        final tagsState = context.read<TagsCubit>().state;
        if (tagsState is! TagsLoaded) {
          context.read<TagsCubit>().getAllTags();
        }
        
        if (_customerId.isNotEmpty) {
          context.read<SuggestionsCubit>().getProductSuggestions(
            customerId: _customerId,
            searchQuery: '',
            limit: 10,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(Customer customer) {
    setState(() {
      _customerId = customer.id;
      _customerName = customer.name;
    });
    
    context.read<SuggestionsCubit>().loadSuggestionsForCustomer(customer.id);
  }

  void _recalculateTotals() {
    _subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
    _tax = _items.fold(0.0, (sum, item) => sum + item.tax);
    _total = _subtotal + _tax;
  }



  void _updateInventoryForItems(List<InvoiceItem> items) {
    debugPrint('Starting inventory update for ${items.length} items');
    for (final item in items) {
      try {
        debugPrint('Processing item: ${item.name} (ID: ${item.productId}) with quantity: ${item.quantity}');
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('Products loaded: ${products.length} products available');
            try {
              final product = products.firstWhere((p) => p.id == item.productId);
              debugPrint('Found product: ${product.name} with current inventory: ${product.inventory}');
              if (!product.isService) {
                final newInventory = product.inventory - item.quantity.toInt();
                debugPrint('Calculating new inventory: ${product.inventory} - ${item.quantity.toInt()} = $newInventory');
                if (newInventory >= 0) {
                  debugPrint('Updating inventory for ${product.name}: ${product.inventory} -> $newInventory');
                  context.read<ProductCubit>().updateProductInventory(
                    item.productId, 
                    newInventory,
                  );
                  debugPrint('Updated inventory for ${product.name}: ${product.inventory} -> $newInventory');
                } else {
                  debugPrint('Warning: Insufficient inventory for ${product.name}');
                }
              } else {
                debugPrint('Product ${product.name} is a service, skipping inventory update');
              }
            } catch (e) {
              debugPrint('Product ${item.name} (ID: ${item.productId}) not found after creation: $e');
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
    debugPrint('Finished inventory update process');
  }

  void _ensureProductsExistAndUpdateInventory(List<InvoiceItem> items) {
    debugPrint('Starting inventory update for ${items.length} items (existing products)');
    for (final item in items) {
      try {
        debugPrint('Processing item: ${item.name} (ID: ${item.productId}) with quantity: ${item.quantity}');
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('Products loaded: ${products.length} products available');
            try {
              final product = products.firstWhere((p) => p.id == item.productId);
              debugPrint('Found product: ${product.name} with current inventory: ${product.inventory}');
              if (!product.isService) {
                final newInventory = product.inventory - item.quantity.toInt();
                debugPrint('Calculating new inventory: ${product.inventory} - ${item.quantity.toInt()} = $newInventory');
                if (newInventory >= 0) {
                  debugPrint('Updating inventory for ${product.name}: ${product.inventory} -> $newInventory');
                  context.read<ProductCubit>().updateProductInventory(
                    item.productId, 
                    newInventory,
                  );
                  debugPrint('Updated inventory for ${product.name}: ${product.inventory} -> $newInventory');
                } else {
                  debugPrint('Warning: Insufficient inventory for ${product.name}');
                }
              } else {
                debugPrint('Product ${product.name} is a service, skipping inventory update');
              }
            } catch (e) {
              debugPrint('Product ${item.name} (ID: ${item.productId}) not found in products collection');
              debugPrint('Skipping inventory update for ${item.name} - product not in products collection');
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
    debugPrint('Finished inventory update process for existing products');
  }

  void _onProductSelected(Product product, {double? quantity}) {
    setState(() {
      debugPrint('_onProductSelected called for: ${product.name} (ID: ${product.id})');
      debugPrint('Current _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      if (_selectedProducts.any((p) => p.id == product.id)) {
        debugPrint('Product ${product.name} is already selected');
        return;
      }
      
      _selectedProducts.add(product);
      debugPrint('Added to _selectedProducts: ${product.name}');
      debugPrint('Updated _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      final finalQuantity = quantity ?? 1.0;
      debugPrint('Adding ${product.name} with quantity: $finalQuantity');
      
      final item = InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        name: product.name,
        description: product.description,
        quantity: finalQuantity,
        unitPrice: product.price,
        tax: product.tax,
        total: (product.price * finalQuantity) + product.tax,
        companyOrShopName: product.companyOrShopName,
        companyAddress: product.companyAddress,
        companyPhone: product.companyPhone,
        companyEmail: product.companyEmail,
        companyWebsite: product.companyWebsite,
      );
      _items.add(item);
      _recalculateTotals();
      
      debugPrint('Final _selectedProducts count: ${_selectedProducts.length}');
      debugPrint('Final _items count: ${_items.length}');
    });
  }

  void _onProductDeselected(Product product) {
    setState(() {
      debugPrint('_onProductDeselected called for: ${product.name} (ID: ${product.id})');
      debugPrint('Current _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      final initialSelectedCount = _selectedProducts.length;
      _selectedProducts.removeWhere((p) => p.id == product.id);
      final removedFromSelected = initialSelectedCount - _selectedProducts.length;
      debugPrint('Removed from _selectedProducts: $removedFromSelected items');
      
      final initialItemsCount = _items.length;
      _items.removeWhere((item) => item.productId == product.id);
      final removedFromItems = initialItemsCount - _items.length;
      debugPrint('Removed from _items: $removedFromItems items');
      
      _recalculateTotals();
      debugPrint('Removed ${product.name} from invoice');
      debugPrint('Final _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      debugPrint('Final _items: ${_items.map((item) => '${item.name}(${item.productId})').join(', ')}');
    });
  }

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TagsCubit>(),
        child: SafeArea(
          top: false,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BlocBuilder<TagsCubit, TagsState>(
              builder: (context, tagsState) {
                List<String> allTagNames = tagsState is TagsLoaded
                    ? tagsState.tags.map((t) => t.name).toList()
                    : <String>[];
                List<String> tempSelected = List<String>.from(_tags);
                String searchQuery = '';
                final TextEditingController addController = TextEditingController();
                return StatefulBuilder(
                  builder: (context, setSheetState) {

                    void applySelection() {
                      setState(() {
                        _tags = List<String>.from(tempSelected);
                      });
                      Navigator.pop(dialogContext);
                    }

                    List<String> filteredTags() {
                      if (searchQuery.isEmpty) return allTagNames;
                      return allTagNames
                          .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
                          .toList();
                    }

                    return Column(
                      children: [
                        Container(
                          width: 36,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Text(
                                'Manage Tags',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: const Icon(Icons.close, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        // Search
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              onChanged: (v) => setSheetState(() => searchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'Search tags...',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),

                        // Selected tags chips
                        if (tempSelected.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: tempSelected.map((name) {
                                  return Chip(
                                    label: Text(name),
                                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                    backgroundColor: const Color(0xFF2563EB),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    onDeleted: () {
                                      setSheetState(() {
                                        tempSelected.remove(name);
                                      });
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                        // List area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                            child: tagsState is! TagsLoaded
                                ? Center(
                                    child: Text(
                                      'Loading tags...',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filteredTags().length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final name = filteredTags()[index];
                                      final isSelected = tempSelected.contains(name);
                                      return ListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                        title: Text(
                                          '#$name',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                                            border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            isSelected ? Icons.check : Icons.add,
                                            size: 16,
                                            color: isSelected ? Colors.white : Colors.black54,
                                          ),
                                        ),
                                        onTap: () {
                                          setSheetState(() {
                                            if (isSelected) {
                                              tempSelected.remove(name);
                                            } else {
                                              tempSelected.add(name);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),

                        // Add new tag + Apply
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: TextField(
                                    controller: addController,
                                    decoration: const InputDecoration(
                                      hintText: 'Add new tag...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onSubmitted: (value) {
                                      final v = value.trim();
                                      if (v.isNotEmpty && !tempSelected.contains(v)) {
                                        setSheetState(() {
                                          tempSelected.add(v);
                                          if (!allTagNames.contains(v)) allTagNames.add(v);
                                        });
                                        addController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final v = addController.text.trim();
                                    if (v.isNotEmpty && !tempSelected.contains(v)) {
                                      setSheetState(() {
                                        tempSelected.add(v);
                                        if (!allTagNames.contains(v)) allTagNames.add(v);
                                      });
                                      addController.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: applySelection,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Apply (${tempSelected.length})',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icon(Icons.edit_note, color: _getStatusColor(status), size: 18);
      case InvoiceStatus.sent:
        return Icon(Icons.send, color: _getStatusColor(status), size: 18);
      case InvoiceStatus.paid:
        return Icon(Icons.check_circle, color: _getStatusColor(status), size: 18);
      case InvoiceStatus.overdue:
        return Icon(Icons.warning, color: _getStatusColor(status), size: 18);
      case InvoiceStatus.cancelled:
        return Icon(Icons.cancel, color: _getStatusColor(status), size: 18);
    }
  }

  String _getStatusDisplayName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.orange.shade600;
      case InvoiceStatus.sent:
        return const Color(0xFF2563EB);
      case InvoiceStatus.paid:
        return Colors.green.shade600;
      case InvoiceStatus.overdue:
        return Colors.red.shade600;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  void _showStatusDropdown() {
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
              width: 36,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Select Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            ...InvoiceStatus.values.map((status) {
              final isSelected = _status == status;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _status = status;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? _getStatusColor(status) : _getStatusColor(status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getStatusIconData(status),
                            color: isSelected ? Colors.white : _getStatusColor(status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusDisplayName(status),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.black : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getStatusDescription(status),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2563EB),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIconData(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_note;
      case InvoiceStatus.sent:
        return Icons.send;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.overdue:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Invoice is being prepared';
      case InvoiceStatus.sent:
        return 'Invoice has been sent to customer';
      case InvoiceStatus.paid:
        return 'Payment has been received';
      case InvoiceStatus.overdue:
        return 'Payment is past due date';
      case InvoiceStatus.cancelled:
        return 'Invoice has been cancelled';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _recalculateTotals();
    
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
    
    debugPrint('Creating invoice with ID: ${invoice.id}');
    debugPrint('Customer ID: ${invoice.customerId}');
    debugPrint('Customer Name: ${invoice.customerName}');
    debugPrint('Items count: ${invoice.items.length}');
    debugPrint('Subtotal: ${invoice.subtotal}');
    debugPrint('Tax: ${invoice.tax}');
    debugPrint('Total: ${invoice.total}');
    debugPrint('Status: ${invoice.status.name}');
    debugPrint('Created At: ${invoice.createdAt}');
    debugPrint('Due Date: ${invoice.dueDate}');
    debugPrint('Paid At: ${invoice.paidAt}');
    debugPrint('Note: ${invoice.note}');
    debugPrint('Template ID: ${invoice.templateId}');
    debugPrint('Tags: ${invoice.tags}');
    debugPrint('Search Keywords: ${invoice.searchKeywords}');
    
    debugPrint('Saving invoice with tags: $_tags');
    debugPrint('Invoice tags count: ${_tags.length}');
    
    try {
      context.read<InvoiceCubit>().addInvoice(invoice);
      
      if (!_isEdit) {
        debugPrint('Starting inventory update for ${_items.length} items');
        
        final productsToCreate = <Product>[];
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('Products loaded: ${products.length} products available');
            
            for (final item in _items) {
              try {
                products.firstWhere((p) => p.id == item.productId);
                debugPrint('Product ${item.name} (ID: ${item.productId}) already exists in products collection');
              } catch (e) {
                debugPrint('Product ${item.name} (ID: ${item.productId}) not found in products collection, will create it...');
                final newProduct = Product(
                  id: item.productId,
                  name: item.name,
                  description: item.description ?? '',
                  price: item.unitPrice,
                  category: 'General',
                  tax: item.tax,
                  inventory: 100,
                  isService: false,
                  companyOrShopName: null,
                  companyAddress: null,
                  companyPhone: null,
                  companyEmail: null,
                  companyWebsite: null,
                );
                productsToCreate.add(newProduct);
              }
            }
            
            for (final product in productsToCreate) {
              debugPrint('Creating product: ${product.name} with inventory: ${product.inventory}');
              context.read<ProductCubit>().addProduct(product);
            }
            
            if (productsToCreate.isNotEmpty) {
              debugPrint('Products created, refreshing and updating inventory...');
              context.read<ProductCubit>().fetchProducts();
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  _updateInventoryForItems(_items);
                }
              });
            } else {
              debugPrint('No new products to create, checking if products exist in Firestore...');
              _ensureProductsExistAndUpdateInventory(_items);
            }
          },
          initial: () => debugPrint('Products not loaded yet'),
          loading: () => debugPrint('Products are loading'),
          error: (message) => debugPrint('Error loading products: $message'),
        );
        
        debugPrint('Finished inventory update process');
      } else {
        debugPrint('Editing existing invoice, skipping inventory update');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? AppStrings.invoiceInvoiceUpdated : AppStrings.invoiceInvoiceCreated),
          backgroundColor: Colors.black87,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.error} saving invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            _isEdit ? 'Edit Invoice' : 'New Invoice',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _save,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        _isEdit ? 'Update' : 'Save',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomerSelectionWidget(
                  selectedCustomerId: _customerId.isNotEmpty ? _customerId : null,
                  selectedCustomerName: _customerName.isNotEmpty ? _customerName : null,
                  onCustomerSelected: _onCustomerSelected,
                  primaryColor: const Color(0xFF2563EB),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTemplateCard(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTagsCard(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_customerId.isNotEmpty) ...[
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSectionCard(
                    title: 'Smart Recommendations',
                    icon: Icons.auto_awesome,
                    child: SmartRecommendationsWidget(
                      customerId: _customerId,
                      onProductSelected: _onProductSelected,
                      primaryColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSectionCard(
                  title: 'Products',
                  icon: Icons.inventory_2_outlined,
                  child: SizedBox(
                    height: 350,
                    child: ProductListWidget(
                      selectedProducts: _selectedProducts,
                      onProductSelected: _onProductSelected,
                      onProductDeselected: _onProductDeselected,
                      primaryColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedProducts.isNotEmpty) ...[
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSelectedItemsCard(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildInvoiceDetailsCard(),
              ),
            ),

            const SizedBox(height: 20),

            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSummaryCard(),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: AIFloatingButton(
        invoiceId: widget.invoice?.id ?? 'new',
        primaryColor: const Color(0xFF2563EB),
        isVisible: true,
      ),
    );
  }

  Widget _buildTemplateCard() {
    final selectedTemplate = _templates.firstWhere(
      (t) => t['id'] == (_templateId ?? _templates.first['id']),
      orElse: () => _templates.first,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final selected = await Navigator.pushNamed(context, '/invoice-template', arguments: {
              'currentTemplateId': _templateId ?? 'template_a',
            });
            if (selected is String) {
              setState(() {
                _templateId = selected;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Template',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selectedTemplate['name'] ?? 'Select template',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showTagSelector,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.label_outline,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (_tags.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_tags.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _tags.isEmpty ? 'Add tags' : _tags.take(3).join(', '),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Selected Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedProducts.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: _selectedProducts.map((product) {
                final item = _items.firstWhere(
                  (item) => item.productId == product.id,
                  orElse: () => InvoiceItem(
                    id: '',
                    name: product.name,
                    description: product.description,
                    quantity: 1,
                    unitPrice: product.price,
                    tax: product.tax,
                    total: product.price + product.tax,
                    productId: product.id,
                  ),
                );
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            if (item.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '\$${item.unitPrice.toStringAsFixed(2)} each',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          initialValue: item.quantity.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) {
                            final quantity = double.tryParse(value) ?? 1.0;
                            setState(() {
                              final index = _items.indexWhere((i) => i.productId == item.productId);
                              if (index != -1) {
                                _items[index] = _items[index].copyWith(
                                  quantity: quantity,
                                  total: quantity * item.unitPrice + item.tax,
                                );
                              }
                              _recalculateTotals();
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _items.removeWhere((i) => i.productId == item.productId);
                            _selectedProducts.removeWhere((p) => p.id == item.productId);
                            _recalculateTotals();
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red.shade600,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Invoice Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _dueDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, color: const Color(0xFF2563EB), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _dueDate != null
                                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: _dueDate != null ? Colors.black87 : Colors.grey.shade500,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showStatusDropdown,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              _getStatusIcon(_status),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getStatusDisplayName(_status),
                                  style: TextStyle(
                                    color: _getStatusColor(_status),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    initialValue: _note,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add a note to your invoice...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _note = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}', false),
            const SizedBox(height: 12),
            _buildSummaryRow('Tax', '\$${_tax.toStringAsFixed(2)}', false),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            _buildSummaryRow('TOTAL', '\$${_total.toStringAsFixed(2)}', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF2563EB) : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: FontWeight.w700,
            color: isTotal ? const Color(0xFF2563EB) : Colors.black,
          ),
        ),
      ],
    );
  }
}