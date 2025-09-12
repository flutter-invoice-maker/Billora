import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/enhanced_scanned_bill.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../../customer/presentation/pages/customer_form_page.dart';
import '../../../customer/presentation/cubit/customer_cubit.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../../core/di/injection_container.dart';

class EnhancedAIDataCorrectionPage extends StatefulWidget {
  final EnhancedScannedBill scannedBill;
  final String imagePath;
  
  const EnhancedAIDataCorrectionPage({
    super.key, 
    required this.scannedBill,
    required this.imagePath,
  });
  
  @override
  State<EnhancedAIDataCorrectionPage> createState() => _EnhancedAIDataCorrectionPageState();
}

class _EnhancedAIDataCorrectionPageState extends State<EnhancedAIDataCorrectionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _customerNameController;
  
  bool _isExpanded = false;
  bool _isProcessing = false;
  Map<String, double> _fieldConfidence = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFieldConfidence();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _totalAmountController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _storeNameController = TextEditingController(
      text: _getFieldValue('storeName', widget.scannedBill.storeName),
    );
    _totalAmountController = TextEditingController(
      text: widget.scannedBill.totalAmount.toString(),
    );
    _phoneController = TextEditingController(
      text: _getFieldValue('phone', widget.scannedBill.phone ?? ''),
    );
    _addressController = TextEditingController(
      text: _getFieldValue('address', widget.scannedBill.address ?? ''),
    );
    _emailController = TextEditingController(
      text: _getFieldValue('email', ''),
    );
    _invoiceNumberController = TextEditingController(
      text: _getFieldValue('invoiceNumber', ''),
    );
    _customerNameController = TextEditingController(
      text: _getFieldValue('customerName', ''),
    );
  }

  void _loadFieldConfidence() {
    final scanResult = widget.scannedBill.scanResult;
    _fieldConfidence = Map<String, double>.from(scanResult['fieldConfidence'] ?? {});
  }

  String _getFieldValue(String field, String fallback) {
    final scanResult = widget.scannedBill.scanResult;
    final aiExtractedData = scanResult['aiExtractedData'] as Map<String, dynamic>?;
    return aiExtractedData?[field]?.toString() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Enhanced Data Review'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isProcessing ? null : _saveToLibrary,
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
                _buildAIProcessingHeader(),
                const SizedBox(height: 20),
                _buildFieldConfidenceSection(),
                const SizedBox(height: 20),
                _buildBasicInfoSection(),
                const SizedBox(height: 20),
                _buildContactInfoSection(),
                const SizedBox(height: 20),
                _buildAISuggestionsSection(),
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

  Widget _buildAIProcessingHeader() {
    final scanResult = widget.scannedBill.scanResult;
    final confidence = scanResult['confidence'] as String?;
    final billType = scanResult['detectedBillType'] as String?;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Processing Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Overall Confidence', _getConfidenceText(confidence), _getConfidenceColor(confidence)),
          _buildInfoRow('Bill Type', _getBillTypeText(billType), Colors.white),
          _buildInfoRow('AI Model Version', scanResult['aiModelVersion']?.toString() ?? 'N/A', Colors.white),
          _buildInfoRow('Processing Time', '${scanResult['processingTimeMs']?.toStringAsFixed(0) ?? "N/A"}ms', Colors.white),
          _buildInfoRow('Data Validated', scanResult['isDataValidated'] == true ? 'Yes' : 'No', Colors.white),
        ],
      ),
    );
  }

  Widget _buildFieldConfidenceSection() {
    if (_fieldConfidence.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Field Confidence Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._fieldConfidence.entries.map((entry) => _buildConfidenceBar(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(String field, double confidence) {
    final percentage = (confidence * 100).toInt();
    final color = confidence >= 0.8 ? Colors.green : confidence >= 0.6 ? Colors.orange : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getFieldDisplayName(field),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
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
        _buildTextFieldWithConfidence(
          controller: _storeNameController,
          label: 'Store/Company Name',
          icon: Icons.business,
          field: 'storeName',
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithConfidence(
          controller: _customerNameController,
          label: 'Customer Name',
          icon: Icons.person,
          field: 'customerName',
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithConfidence(
          controller: _totalAmountController,
          label: 'Total Amount',
          icon: Icons.attach_money,
          field: 'totalAmount',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          validator: (value) {
            if (value?.isEmpty == true) return 'Required';
            if (double.tryParse(value!) == null) return 'Invalid amount';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithConfidence(
          controller: _invoiceNumberController,
          label: 'Invoice Number',
          icon: Icons.receipt_long,
          field: 'invoiceNumber',
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildTextFieldWithConfidence(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          field: 'phone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithConfidence(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email,
          field: 'email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithConfidence(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          field: 'address',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAISuggestionsSection() {
    final scanResult = widget.scannedBill.scanResult;
    final suggestions = List<String>.from(scanResult['aiSuggestions'] ?? []);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Suggestions for Improvement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          )),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFieldWithConfidence({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String field,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final confidence = _fieldConfidence[field] ?? 0.0;
    final hasHighConfidence = confidence >= 0.8;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon),
            suffixIcon: hasHighConfidence
                ? Icon(Icons.auto_awesome, color: Colors.green.shade600, size: 20)
                : confidence >= 0.6
                    ? Icon(Icons.warning, color: Colors.orange.shade600, size: 20)
                    : Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            helperText: hasHighConfidence
                ? 'High confidence - AI detected accurately'
                : confidence >= 0.6
                    ? 'Medium confidence - Review recommended'
                    : 'Low confidence - Manual review required',
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
        ),
        if (confidence > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                hasHighConfidence ? Icons.check_circle : Icons.info_outline,
                size: 16,
                color: hasHighConfidence ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Confidence: ${(confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: hasHighConfidence ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _createCustomer,
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
                onPressed: _isProcessing ? null : _createProduct,
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
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
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
                onPressed: _isProcessing ? null : _saveToLibrary,
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

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
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

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'storeName':
        return 'Store Name';
      case 'customerName':
        return 'Customer Name';
      case 'totalAmount':
        return 'Total Amount';
      case 'phone':
        return 'Phone Number';
      case 'email':
        return 'Email Address';
      case 'address':
        return 'Address';
      case 'invoiceNumber':
        return 'Invoice Number';
      default:
        return field.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
    }
  }

  void _createCustomer() {
    final updatedBill = _createUpdatedScannedBill();
    final ai = updatedBill.scanResult['aiExtractedData'] as Map<String, dynamic>?;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<CustomerCubit>.value(
          value: sl<CustomerCubit>(),
          child: CustomerFormPage(
            prefill: {
              'name': (ai?['customerName'] ?? ai?['storeName'] ?? updatedBill.storeName)?.toString() ?? '',
              'email': ai?['email']?.toString() ?? '',
              'phone': ai?['phone']?.toString() ?? (updatedBill.phone ?? ''),
              'address': ai?['address']?.toString() ?? (updatedBill.address ?? ''),
            },
            forceCreate: true,
          ),
        ),
      ),
    );
  }

  void _createProduct() async {
    final updatedBill = _createUpdatedScannedBill();
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
      final correctedBill = _createUpdatedScannedBill();
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

  EnhancedScannedBill _createUpdatedScannedBill() {
    return widget.scannedBill.copyWith(
      storeName: _storeNameController.text,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
    );
  }

  String _getConfidenceText(String? confidence) {
    if (confidence == null) return 'Unknown';
    final double conf = double.tryParse(confidence) ?? 0.0;
    if (conf >= 0.9) return 'High (90%+)';
    if (conf >= 0.7) return 'Medium (70-89%)';
    if (conf >= 0.5) return 'Low (50-69%)';
    return 'Unknown';
  }

  Color _getConfidenceColor(String? confidence) {
    if (confidence == null) return Colors.grey;
    final double conf = double.tryParse(confidence) ?? 0.0;
    if (conf >= 0.9) return Colors.green;
    if (conf >= 0.7) return Colors.orange;
    if (conf >= 0.5) return Colors.red;
    return Colors.grey;
  }

  String _getBillTypeText(String? billType) {
    if (billType == null) return 'Unknown';
    return billType.split('.').last.replaceAll('_', ' ').toUpperCase();
  }
} 