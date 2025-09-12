import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/enhanced_scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../../customer/presentation/pages/customer_form_page.dart';
import '../../../customer/presentation/cubit/customer_cubit.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../../core/di/injection_container.dart';

class EnhancedDataCorrectionPage extends StatefulWidget {
  final EnhancedScannedBill scannedBill;
  final String imagePath;
  
  const EnhancedDataCorrectionPage({
    super.key, 
    required this.scannedBill,
    required this.imagePath,
  });
  
  @override
  State<EnhancedDataCorrectionPage> createState() => _EnhancedDataCorrectionPageState();
}

class _EnhancedDataCorrectionPageState extends State<EnhancedDataCorrectionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _invoiceNumberController;
  late List<BillLineItem> _items;
  
  bool _isExpanded = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _storeNameController = TextEditingController(text: widget.scannedBill.storeName);
    _totalAmountController = TextEditingController(text: widget.scannedBill.totalAmount.toString());
    _phoneController = TextEditingController(text: widget.scannedBill.phone ?? '');
    _addressController = TextEditingController(text: widget.scannedBill.address ?? '');
    
    // Extract additional data from scan result
    final scanResult = widget.scannedBill.scanResult;
    final extractedFields = scanResult['extractedFields'] as Map<String, dynamic>?;
    if (extractedFields != null) {
      _emailController = TextEditingController(text: extractedFields['email']?.toString() ?? '');
      _invoiceNumberController = TextEditingController(text: extractedFields['invoiceNumber']?.toString() ?? '');
    } else {
      _emailController = TextEditingController(text: '');
      _invoiceNumberController = TextEditingController(text: '');
    }
    
    _items = List.from(widget.scannedBill.items ?? []);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _totalAmountController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Correct Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _createCustomer,
            tooltip: 'Create Customer',
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: _createProduct,
            tooltip: 'Create Product',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveToLibrary,
            tooltip: 'Save to Library',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScanResultHeader(),
                const SizedBox(height: 20),
                _buildBasicInfoSection(),
                const SizedBox(height: 20),
                _buildContactInfoSection(),
                const SizedBox(height: 20),
                _buildItemsSection(),
                const SizedBox(height: 20),
                _buildRawTextSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanResultHeader() {
    final scanResult = widget.scannedBill.scanResult;
    final confidence = scanResult['confidence'] as String?;
    final billType = scanResult['detectedBillType'] as String?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI Scan Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Confidence', _getConfidenceText(confidence), _getConfidenceColor(confidence)),
          _buildInfoRow('Bill Type', _getBillTypeText(billType), Colors.grey.shade700),
          _buildInfoRow('OCR Provider', scanResult['ocrProvider']?.toString() ?? 'N/A', Colors.grey.shade700),
          _buildInfoRow('Processed At', _formatDateTime(DateTime.parse(scanResult['processedAt']?.toString() ?? DateTime.now().toIso8601String())), Colors.grey.shade700),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.store,
      children: [
        _buildTextField(
          controller: _storeNameController,
          label: 'Store/Company Name',
          icon: Icons.business,
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _totalAmountController,
          label: 'Total Amount',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          validator: (value) {
            if (value?.isEmpty == true) return 'Required';
            if (double.tryParse(value!) == null) return 'Invalid amount';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _invoiceNumberController,
          label: 'Invoice Number',
          icon: Icons.receipt_long,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return _buildSection(
      title: 'Line Items (${_items.length})',
      icon: Icons.list_alt,
      children: [
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'No line items detected',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ..._items.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildItemCard(entry.key, entry.value),
              )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addNewItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index, BillLineItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: item.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            onChanged: (value) => _updateItem(index, item.copyWith(description: value)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  onChanged: (value) {
                    final quantity = double.tryParse(value) ?? 1.0;
                    _updateItem(index, item.copyWith(quantity: quantity));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: item.unitPrice.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  onChanged: (value) {
                    final unitPrice = double.tryParse(value) ?? 0.0;
                    _updateItem(index, item.copyWith(unitPrice: unitPrice));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawTextSection() {
    final scanResult = widget.scannedBill.scanResult;
    return _buildSection(
      title: 'Raw OCR Text',
      icon: Icons.text_fields,
      children: [
        ExpansionTile(
          title: const Text('View Original Text'),
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                scanResult['rawText']?.toString() ?? 'No text available',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _createCustomer,
                icon: const Icon(Icons.person_add),
                label: const Text('Create Customer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _createProduct,
                icon: const Icon(Icons.inventory),
                label: const Text('Create Product'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveToLibrary,
                icon: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isProcessing ? 'Processing...' : 'Save to Library'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add(BillLineItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: '',
        quantity: 1.0,
        unitPrice: 0.0,
        totalPrice: 0.0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, BillLineItem updatedItem) {
    setState(() {
      _items[index] = updatedItem.copyWith(
        totalPrice: updatedItem.quantity * updatedItem.unitPrice,
      );
    });
  }

  void _createCustomer() async {
    final updatedBill = _getCorrectedBill();
    final ai = updatedBill.scanResult['aiExtractedData'] as Map<String, dynamic>?;
    final customerName = (ai?['customerName'] ?? ai?['storeName'] ?? updatedBill.storeName)?.toString() ?? '';
    
    try {
      final customerCubit = sl<CustomerCubit>();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<CustomerCubit>.value(
            value: customerCubit,
            child: CustomerFormPage(
              prefill: {
                'name': customerName,
                'email': ai?['email']?.toString() ?? '',
                'phone': ai?['phone']?.toString() ?? (updatedBill.phone ?? ''),
                'address': ai?['address']?.toString() ?? (updatedBill.address ?? ''),
              },
              forceCreate: true,
            ),
          ),
        ),
      );

      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${result.name}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createProduct() async {
    final updatedBill = _getCorrectedBill();
    final ai = updatedBill.scanResult['aiExtractedData'] as Map<String, dynamic>?;
    
    try {
      final productCubit = sl<ProductCubit>();
      
      // Prepare products data from scan results
      List<Map<String, dynamic>> productsToAdd = [];
      
      // Check if we have line items from AI extraction
      final items = ai?['lineItems'];
      if (items is List && items.isNotEmpty) {
        // Add each line item as a separate product
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            final productData = {
              'name': item['description']?.toString() ?? 'Unknown Product',
              'description': item['description']?.toString(),
              'price': item['unitPrice']?.toString() ?? item['totalPrice']?.toString() ?? '0',
              'category': item['category']?.toString() ?? ai?['category']?.toString() ?? 'professional_business',
              'tax': item['tax']?.toString() ?? ai?['tax']?.toString() ?? '0',
              'inventory': item['quantity']?.toString() ?? '1',
              'isService': false,
              'companyOrShopName': updatedBill.storeName,
            };
            productsToAdd.add(productData);
          }
        }
      } else {
        // Fallback: create a single product from bill data
        final productData = {
          'name': ai?['productName']?.toString() ?? updatedBill.storeName,
          'description': 'Product from ${updatedBill.storeName}',
          'price': ai?['unitPrice']?.toString() ?? ai?['totalPrice']?.toString() ?? updatedBill.totalAmount.toString(),
          'category': ai?['category']?.toString() ?? 'professional_business',
          'tax': ai?['tax']?.toString() ?? '0',
          'inventory': '1',
          'isService': false,
          'companyOrShopName': updatedBill.storeName,
        };
        productsToAdd.add(productData);
      }
      
      if (productsToAdd.isNotEmpty) {
        // Add all products directly to product list
        await productCubit.addProductsFromScan(productsToAdd);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${productsToAdd.length} product(s) added to product list successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No products found to add'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToLibrary() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isProcessing = true);

    try {
      final correctedBill = _getCorrectedBill();
      final item = ScanLibraryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: '${correctedBill.storeName}_${correctedBill.scanDate.toIso8601String()}',
        imagePath: widget.imagePath,
        scannedBill: correctedBill,
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
        isProcessed: true,
      );
      
      if (!mounted) return;
      
      // Use named route instead of direct instantiation
      // Pass the item as arguments to be handled by the route
      Navigator.pushNamed(
        context,
        '/scan-library',
        arguments: {'initialItems': [item]},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  EnhancedScannedBill _getCorrectedBill() {
    return widget.scannedBill.copyWith(
      storeName: _storeNameController.text,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      items: _items,
    );
  }

  String _getConfidenceText(String? confidence) {
    if (confidence == null) return 'Unknown';
    final conf = double.tryParse(confidence);
    if (conf == null) return 'Invalid';
    if (conf >= 90) return 'High (90%+)';
    if (conf >= 70) return 'Medium (70-89%)';
    if (conf >= 50) return 'Low (50-69%)';
    return 'Unknown';
  }

  Color _getConfidenceColor(String? confidence) {
    if (confidence == null) return Colors.grey;
    final conf = double.tryParse(confidence);
    if (conf == null) return Colors.grey;
    if (conf >= 90) return Colors.green;
    if (conf >= 70) return Colors.orange;
    if (conf >= 50) return Colors.red;
    return Colors.grey;
  }

  String _getBillTypeText(String? billType) {
    if (billType == null) return 'Unknown';
    return billType.split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 