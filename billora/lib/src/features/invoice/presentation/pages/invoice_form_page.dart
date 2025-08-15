import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/customer_selection_widget.dart';
import 'package:billora/src/features/invoice/presentation/widgets/product_list_widget.dart';
import 'package:billora/src/features/invoice/presentation/widgets/smart_recommendations_widget.dart';
import 'package:billora/src/features/invoice/presentation/widgets/ai_suggestions_widget.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/invoice/presentation/widgets/template_selector_dialog.dart';
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
  
  // AI and QR Code state
  String? _aiClassification;
  String? _aiSummary;
  List<String> _aiSuggestedTags = [];
  String? _qrCodeData;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _fadeController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _fadeAnimation;

  // Theme colors matching login/register
  final Color _primaryColor = const Color(0xFF8B5FBF);
  final Color _secondaryColor = const Color(0xFFB794F6);
  final Color _accentColor = const Color(0xFF7C3AED);

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

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 30000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _backgroundController.repeat();
        
        // Check if data comes from scanner
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
    }
  }

  void _populateFromScannedBill(dynamic scannedBill) {
    try {
      // Convert scanned bill data to invoice form
      setState(() {
        _customerName = scannedBill.storeName ?? 'Cửa hàng';
        _total = scannedBill.totalAmount ?? 0.0;
        _subtotal = _total;
        _tax = 0.0;
        
        // Convert scanned items to invoice items
        if (scannedBill.items != null && scannedBill.items.isNotEmpty) {
          _items = scannedBill.items.map<InvoiceItem>((item) => InvoiceItem(
            id: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            productId: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: item.description ?? 'Sản phẩm',
            description: item.description ?? '',
            quantity: item.quantity ?? 1.0,
            unitPrice: item.unitPrice ?? 0.0,
            total: item.totalPrice ?? 0.0,
            tax: 0.0,
          )).toList();
        }
        
        // Add note with scan information
        _note = 'Quét từ hóa đơn: ${scannedBill.scanDate?.toString() ?? DateTime.now().toString()}';
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tự động điền dữ liệu từ hóa đơn đã quét!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error populating from scanned bill: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once when dependencies change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if data is already loaded to avoid unnecessary calls
        final customerState = context.read<CustomerCubit>().state;
        customerState.when(
          loaded: (_) => null, // Already loaded
          initial: () => context.read<CustomerCubit>().fetchCustomers(),
          loading: () => null, // Already loading
          error: (_) => context.read<CustomerCubit>().fetchCustomers(),
        );
        
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (_) => null, // Already loaded
          initial: () => context.read<ProductCubit>().fetchProducts(),
          loading: () => null, // Already loading
          error: (_) => context.read<ProductCubit>().fetchProducts(),
        );
        
        final tagsState = context.read<TagsCubit>().state;
        if (tagsState is! TagsLoaded) {
          context.read<TagsCubit>().getAllTags();
        }
        
        // Only load suggestions if customer is selected
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
    _backgroundController.dispose();
    _fadeController.dispose();
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

  Invoice _buildCurrentInvoice() {
    return Invoice(
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
      searchKeywords: [],
      aiClassification: _aiClassification,
      aiSummary: _aiSummary,
      aiSuggestedTags: _aiSuggestedTags,
      qrCodeData: _qrCodeData,
    );
  }

  void _updateInventoryForItems(List<InvoiceItem> items) {
    debugPrint('🔄 Starting inventory update for ${items.length} items');
    for (final item in items) {
      try {
        debugPrint('🔄 Processing item: ${item.name} (ID: ${item.productId}) with quantity: ${item.quantity}');
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('🔄 Products loaded: ${products.length} products available');
            try {
              final product = products.firstWhere((p) => p.id == item.productId);
              debugPrint('🔄 Found product: ${product.name} with current inventory: ${product.inventory}');
              if (!product.isService) {
                final newInventory = product.inventory - item.quantity.toInt();
                debugPrint('🔄 Calculating new inventory: ${product.inventory} - ${item.quantity.toInt()} = $newInventory');
                if (newInventory >= 0) {
                  debugPrint('🔄 Updating inventory for ${product.name}: ${product.inventory} -> $newInventory');
                  context.read<ProductCubit>().updateProductInventory(
                    item.productId, 
                    newInventory,
                  );
                  debugPrint('📦 Updated inventory for ${product.name}: ${product.inventory} -> $newInventory');
                } else {
                  debugPrint('⚠️ Warning: Insufficient inventory for ${product.name}');
                }
              } else {
                debugPrint('🔄 Product ${product.name} is a service, skipping inventory update');
              }
            } catch (e) {
              debugPrint('❌ Product ${item.name} (ID: ${item.productId}) not found after creation: $e');
            }
          },
          initial: () => debugPrint('❌ Products not loaded yet'),
          loading: () => debugPrint('⏳ Products are loading'),
          error: (message) => debugPrint('❌ Error loading products: $message'),
        );
      } catch (e) {
        debugPrint('❌ Error updating inventory for ${item.name}: $e');
      }
    }
    debugPrint('✅ Finished inventory update process');
  }

  void _ensureProductsExistAndUpdateInventory(List<InvoiceItem> items) {
    debugPrint('🔄 Starting inventory update for ${items.length} items (existing products)');
    for (final item in items) {
      try {
        debugPrint('🔄 Processing item: ${item.name} (ID: ${item.productId}) with quantity: ${item.quantity}');
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('🔄 Products loaded: ${products.length} products available');
            try {
              final product = products.firstWhere((p) => p.id == item.productId);
              debugPrint('🔄 Found product: ${product.name} with current inventory: ${product.inventory}');
              if (!product.isService) {
                final newInventory = product.inventory - item.quantity.toInt();
                debugPrint('🔄 Calculating new inventory: ${product.inventory} - ${item.quantity.toInt()} = $newInventory');
                if (newInventory >= 0) {
                  debugPrint('🔄 Updating inventory for ${product.name}: ${product.inventory} -> $newInventory');
                  context.read<ProductCubit>().updateProductInventory(
                    item.productId, 
                    newInventory,
                  );
                  debugPrint('📦 Updated inventory for ${product.name}: ${product.inventory} -> $newInventory');
                } else {
                  debugPrint('⚠️ Warning: Insufficient inventory for ${product.name}');
                }
              } else {
                debugPrint('🔄 Product ${product.name} is a service, skipping inventory update');
              }
            } catch (e) {
              debugPrint('❌ Product ${item.name} (ID: ${item.productId}) not found in products collection');
              debugPrint('⚠️ Skipping inventory update for ${item.name} - product not in products collection');
            }
          },
          initial: () => debugPrint('❌ Products not loaded yet'),
          loading: () => debugPrint('⏳ Products are loading'),
          error: (message) => debugPrint('❌ Error loading products: $message'),
        );
      } catch (e) {
        debugPrint('❌ Error updating inventory for ${item.name}: $e');
      }
    }
    debugPrint('✅ Finished inventory update process for existing products');
  }

  void _onProductSelected(Product product, {double? quantity}) {
    setState(() {
      debugPrint('🎯 _onProductSelected called for: ${product.name} (ID: ${product.id})');
      debugPrint('🎯 Current _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      if (_selectedProducts.any((p) => p.id == product.id)) {
        debugPrint('🎯 Product ${product.name} is already selected');
        return;
      }
      
      _selectedProducts.add(product);
      debugPrint('🎯 Added to _selectedProducts: ${product.name}');
      debugPrint('🎯 Updated _selectedProducts: ${_selectedProducts.map((p) => '${p.name}(${p.id})').join(', ')}');
      
      final finalQuantity = quantity ?? 1.0;
      debugPrint('🎯 Adding ${product.name} with quantity: $finalQuantity');
      
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
      
      final initialSelectedCount = _selectedProducts.length;
      _selectedProducts.removeWhere((p) => p.id == product.id);
      final removedFromSelected = initialSelectedCount - _selectedProducts.length;
      debugPrint('🎯 Removed from _selectedProducts: $removedFromSelected items');
      
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

  Widget _buildAIInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  void _showTemplateSelector() {
    showDialog(
      context: context,
      builder: (context) => TemplateSelectorDialog(
        currentTemplateId: _templateId ?? 'template_a',
        onTemplateSelected: (templateId) {
          setState(() {
            _templateId = templateId;
          });
        },
        primaryColor: _primaryColor,
      ),
    );
  }

  void _showTagSelector() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TagsCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: BlocBuilder<TagsCubit, TagsState>(
              builder: (context, tagsState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Icon(
                            Icons.label_important,
                            color: _primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Manage Invoice Tags',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search tags...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(
                            Icons.search,
                            color: _primaryColor,
                            size: 20,
                          ),
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
                            borderSide: BorderSide(color: _primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Available tags section
                    if (tagsState is TagsLoaded) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available tags',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: tagsState.tags.take(8).map((tag) {
                                final isSelected = _tags.contains(tag.name);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _tags.remove(tag.name);
                                      } else {
                                        _tags.add(tag.name);
                                      }
                                    });
                                  },
                                  child: Text(
                                    '#${tag.name}',
                                    style: TextStyle(
                                      color: isSelected ? _primaryColor : Colors.grey.shade600,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Add new tag section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Add new tag...',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: _primaryColor, width: 1),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty && !_tags.contains(value)) {
                                  setState(() {
                                    _tags.add(value);
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for status dropdown
  Widget _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icon(Icons.edit_note, color: _getStatusColor(status), size: 20);
      case InvoiceStatus.sent:
        return Icon(Icons.send, color: _getStatusColor(status), size: 20);
      case InvoiceStatus.paid:
        return Icon(Icons.check_circle, color: _getStatusColor(status), size: 20);
      case InvoiceStatus.overdue:
        return Icon(Icons.warning, color: _getStatusColor(status), size: 20);
      case InvoiceStatus.cancelled:
        return Icon(Icons.cancel, color: _getStatusColor(status), size: 20);
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
        return Colors.blue.shade600;
      case InvoiceStatus.paid:
        return Colors.green.shade600;
      case InvoiceStatus.overdue:
        return Colors.red.shade600;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  void _showStatusDropdown() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(Icons.label_important, color: _primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status options
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
                    borderRadius: BorderRadius.circular(0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? _getStatusColor(status).withValues(alpha: 0.1) : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? _getStatusColor(status) : _getStatusColor(status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
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
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getStatusDescription(status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: _getStatusColor(status),
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
      aiClassification: _aiClassification,
      aiSummary: _aiSummary,
      aiSuggestedTags: _aiSuggestedTags,
      qrCodeData: _qrCodeData,
    );
    
    debugPrint('📝 Creating invoice with ID: ${invoice.id}');
    debugPrint('📝 Customer ID: ${invoice.customerId}');
    debugPrint('📝 Customer Name: ${invoice.customerName}');
    debugPrint('📝 Items count: ${invoice.items.length}');
    debugPrint('📝 Subtotal: ${invoice.subtotal}');
    debugPrint('📝 Tax: ${invoice.tax}');
    debugPrint('📝 Total: ${invoice.total}');
    debugPrint('📝 Status: ${invoice.status.name}');
    debugPrint('📝 Created At: ${invoice.createdAt}');
    debugPrint('📝 Due Date: ${invoice.dueDate}');
    debugPrint('📝 Paid At: ${invoice.paidAt}');
    debugPrint('📝 Note: ${invoice.note}');
    debugPrint('📝 Template ID: ${invoice.templateId}');
    debugPrint('📝 Tags: ${invoice.tags}');
    debugPrint('📝 Search Keywords: ${invoice.searchKeywords}');
    
    debugPrint('📝 Saving invoice with tags: $_tags');
    debugPrint('📝 Invoice tags count: ${_tags.length}');
    
    try {
      context.read<InvoiceCubit>().addInvoice(invoice);
      
      if (!_isEdit) {
        debugPrint('🔄 Starting inventory update for ${_items.length} items');
        
        final productsToCreate = <Product>[];
        final productState = context.read<ProductCubit>().state;
        productState.when(
          loaded: (products) {
            debugPrint('🔄 Products loaded: ${products.length} products available');
            
            for (final item in _items) {
              try {
                products.firstWhere((p) => p.id == item.productId);
                debugPrint('🔄 Product ${item.name} (ID: ${item.productId}) already exists in products collection');
              } catch (e) {
                debugPrint('🔄 Product ${item.name} (ID: ${item.productId}) not found in products collection, will create it...');
                final newProduct = Product(
                  id: item.productId,
                  name: item.name,
                  description: item.description ?? '',
                  price: item.unitPrice,
                  category: 'General',
                  tax: item.tax,
                  inventory: 100,
                  isService: false,
                );
                productsToCreate.add(newProduct);
              }
            }
            
            for (final product in productsToCreate) {
              debugPrint('🔄 Creating product: ${product.name} with inventory: ${product.inventory}');
              context.read<ProductCubit>().addProduct(product);
            }
            
            if (productsToCreate.isNotEmpty) {
              debugPrint('🔄 Products created, refreshing and updating inventory...');
              context.read<ProductCubit>().fetchProducts();
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  _updateInventoryForItems(_items);
                }
              });
            } else {
              debugPrint('🔄 No new products to create, checking if products exist in Firestore...');
              _ensureProductsExistAndUpdateInventory(_items);
            }
          },
          initial: () => debugPrint('❌ Products not loaded yet'),
          loading: () => debugPrint('⏳ Products are loading'),
          error: (message) => debugPrint('❌ Error loading products: $message'),
        );
        
        debugPrint('✅ Finished inventory update process');
      } else {
        debugPrint('📝 Editing existing invoice, skipping inventory update');
      }
      
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
        SnackBar(content: Text(_isEdit ? AppStrings.invoiceInvoiceUpdated : AppStrings.invoiceInvoiceCreated)),
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



  Widget _buildFloatingIcons(double screenHeight, double screenWidth) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Invoice icon (receipt) - moves from top-left to bottom-right
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.7 % 1.0),
                left: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.6 % 1.0),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.5,
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: _primaryColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              
              // Dollar icon (money) - moves from bottom-right to top-left
              Positioned(
                bottom: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.8 % 1.0),
                right: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.7 % 1.0),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.3,
                  child: Icon(
                    Icons.attach_money_outlined,
                    size: 34,
                    color: _secondaryColor.withValues(alpha: 0.10),
                  ),
                ),
              ),
              
              // Chart icon (trending up) - moves from top-right to bottom-left
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.6 % 1.0),
                right: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.5 % 1.0),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.4,
                  child: Icon(
                    Icons.trending_up_outlined,
                    size: 32,
                    color: _accentColor.withValues(alpha: 0.09),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _secondaryColor.withValues(alpha: 0.08),
                  Colors.white,
                  _primaryColor.withValues(alpha: 0.12),
                  _accentColor.withValues(alpha: 0.06),
                ],
                stops: [
                  0.0,
                  0.25 + (_backgroundAnimation.value * 0.15),
                  0.5,
                  0.75 + (_backgroundAnimation.value * 0.1),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating icons background
                _buildFloatingIcons(screenHeight, screenWidth),
                
                // Main content
                Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: _primaryColor, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _isEdit ? AppStrings.invoiceEditTitle : AppStrings.invoiceAddTitle,
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, color: Colors.white, size: 18),
                            label: Text(
                              _isEdit ? AppStrings.invoiceUpdate : AppStrings.invoiceSave,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _save,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Customer Selection
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: CustomerSelectionWidget(
                            selectedCustomerId: _customerId.isNotEmpty ? _customerId : null,
                            selectedCustomerName: _customerName.isNotEmpty ? _customerName : null,
                            onCustomerSelected: _onCustomerSelected,
                            primaryColor: _primaryColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Template and Tags Row
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              // Template Selection
                              Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF8B5FBF).withValues(alpha: 0.1),
                                        const Color(0xFFB794F6).withValues(alpha: 0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                      borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: _showTemplateSelector,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                      children: [
                                        Icon(
                                                Icons.description,
                                                color: const Color(0xFF8B5FBF),
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                        Text(
                                          'Template',
                                          style: TextStyle(
                                                  fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF8B5FBF),
                                          ),
                                        ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _templates.firstWhere(
                                              (t) => t['id'] == (_templateId ?? _templates.first['id']),
                                              orElse: () => _templates.first,
                                            )['name'] ?? 'Select template',
                                            style: TextStyle(
                                              color: const Color(0xFF8B5FBF).withValues(alpha: 0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Tags Selection
                              Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                        const Color(0xFFA855F7).withValues(alpha: 0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                      borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: _showTagSelector,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                      children: [
                                        Icon(
                                                Icons.label,
                                                color: const Color(0xFF7C3AED),
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                        Text(
                                          'Tags',
                                          style: TextStyle(
                                                  fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF7C3AED),
                                          ),
                                        ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        Text(
                                            _tags.isEmpty ? 'Add tags' : '${_tags.length} tag${_tags.length == 1 ? '' : 's'} selected',
                                          style: TextStyle(
                                              color: const Color(0xFF7C3AED).withValues(alpha: 0.8),
                                              fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Main Invoice Form Card
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Smart Recommendations (only show when customer is selected)
                                  if (_customerId.isNotEmpty) ...[
                                  Text(
                                      'Smart Recommendations',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                    SmartRecommendationsWidget(
                                      customerId: _customerId,
                                      onProductSelected: _onProductSelected,
                                      primaryColor: _primaryColor,
                                    ),
                        const SizedBox(height: 24),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // AI Suggestions (only show when items are added)
                                  if (_items.isNotEmpty) ...[
                                    AISuggestionsWidget(
                                      invoice: _buildCurrentInvoice(),
                                      onTagsSuggested: (tags) {
                                        setState(() {
                                          _aiSuggestedTags = tags;
                                          // Auto-add suggested tags if not already present
                                          for (final tag in tags) {
                                            if (!_tags.contains(tag)) {
                                              _tags.add(tag);
                                            }
                                          }
                                        });
                                      },
                                      onClassificationSuggested: (classification) {
                                        setState(() {
                                          _aiClassification = classification;
                                        });
                                      },
                                      onSummarySuggested: (summary) {
                                        setState(() {
                                          _aiSummary = summary;
                                        });
                                      },
                                      primaryColor: _primaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Invoice Items Section
                                  Text(
                                    'Invoice Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Product List with more height
                                  SizedBox(
                                    height: 400, // Increased height to show 4-5 items
                                    child: ProductListWidget(
                                      selectedProducts: _selectedProducts,
                                      onProductSelected: _onProductSelected,
                                      onProductDeselected: _onProductDeselected,
                                      primaryColor: _primaryColor,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  const Divider(),
                          const SizedBox(height: 16),
                                  
                                  // Selected Items Section
                                  if (_selectedProducts.isNotEmpty) ...[
                                    Text(
                                      'Selected Items',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ..._selectedProducts.map((product) {
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
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
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
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (item.description?.isNotEmpty == true)
                                                    Text(
                                                      item.description!,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Quantity input
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                initialValue: item.quantity.toString(),
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Qty',
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                            const SizedBox(width: 8),
                                            // Remove button
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _items.removeWhere((i) => i.productId == item.productId);
                                                  _selectedProducts.removeWhere((p) => p.id == item.productId);
                                                  _recalculateTotals();
                                                });
                                              },
                                              icon: Icon(Icons.remove_circle, color: Colors.red.shade400),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 24),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Invoice Details Section
                                  Text(
                                    'Invoice Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Due Date and Status Row
                                  Row(
                                    children: [
                                      // Due Date
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Due Date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: _primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
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
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.calendar_today, color: _primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _dueDate != null
                                                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                                          : 'Select due date',
                                                      style: TextStyle(
                                                        color: _dueDate != null ? Colors.black87 : Colors.grey.shade600,
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
                                      
                                      // Status
                                      Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                              'Status',
                                    style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                      color: _primaryColor,
                                    ),
                                  ),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: _showStatusDropdown,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _primaryColor.withValues(alpha: 0.3),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _primaryColor.withValues(alpha: 0.1),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    _getStatusIcon(_status),
                                                    const SizedBox(width: 12),
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
                                                      color: _primaryColor,
                                                      size: 24,
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
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Note with bottom border only
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Note',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Add a note to your invoice...',
                                          border: const UnderlineInputBorder(),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: _primaryColor, width: 2),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _note = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Summary Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                                child: Container(
                                  decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryColor.withValues(alpha: 0.1), _secondaryColor.withValues(alpha: 0.1)],
                              ),
                                    borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Padding(
                              padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                    'Invoice Summary',
                                          style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                  const SizedBox(height: 20),
                                  
                                  // Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                      Text(
                                        'Subtotal:',
                                                    style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '\$${_subtotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  
                                  // Tax
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tax:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '\$${_tax.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Divider
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Total - Bigger and Bolder
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                        'TOTAL:',
                                          style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      Text(
                                        '\$${_total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: _primaryColor,
                                        ),
                                      ),
                                    ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        // AI Summary Section (only show when AI data is available)
                        if (_aiClassification != null || _aiSummary != null || _aiSuggestedTags.isNotEmpty) ...[
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_secondaryColor.withValues(alpha: 0.1), _accentColor.withValues(alpha: 0.1)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _secondaryColor.withValues(alpha: 0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: _secondaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AI Analysis',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // AI Classification
                                    if (_aiClassification != null) ...[
                                      _buildAIInfoRow('Classification:', _aiClassification!),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // AI Summary
                                    if (_aiSummary != null) ...[
                                      _buildAIInfoRow('Summary:', _aiSummary!),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // AI Suggested Tags
                                    if (_aiSuggestedTags.isNotEmpty) ...[
                                      _buildAIInfoRow('Suggested Tags:', _aiSuggestedTags.join(', ')),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      
      // AI Floating Button
      floatingActionButton: AIFloatingButton(
        invoiceId: widget.invoice?.id ?? 'new',
        primaryColor: _primaryColor,
        isVisible: true,
      ),
    );
  }
}
