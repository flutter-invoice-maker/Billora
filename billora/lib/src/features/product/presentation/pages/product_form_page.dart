import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:billora/src/core/services/image_upload_service.dart';
import 'package:billora/src/core/di/injection_container.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final Map<String, dynamic>? prefill;
  final bool forceCreate;

  const ProductFormPage({super.key, this.product, this.prefill, this.forceCreate = false});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _description;
  late double _price;
  late double _tax;
  late int _inventory;
  late bool _isService;
  late bool _isEdit;
  late String? _companyOrShopName;
  late String? _companyAddress;
  late String? _companyPhone;
  late String? _companyEmail;
  late String? _companyWebsite;
  late String? _imageUrl;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic> _extraFields = {};
  String _selectedTemplate = 'professional_business';

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null && !widget.forceCreate;
    _name = widget.product?.name ?? (widget.prefill?['name']?.toString() ?? '');
    _description = widget.product?.description ?? widget.prefill?['description']?.toString();
    _price = widget.product?.price ?? (double.tryParse(widget.prefill?['price']?.toString() ?? '') ?? 0.0);
    _tax = widget.product?.tax ?? (double.tryParse(widget.prefill?['tax']?.toString() ?? '') ?? 0.0);
    _inventory = widget.product?.inventory ?? (int.tryParse(widget.prefill?['inventory']?.toString() ?? '') ?? 0);
    _isService = widget.product?.isService ?? (widget.prefill?['isService'] == true);
    _companyOrShopName = widget.product?.companyOrShopName ?? widget.prefill?['companyOrShopName']?.toString();
    _companyAddress = widget.product?.companyAddress ?? widget.prefill?['companyAddress']?.toString();
    _companyPhone = widget.product?.companyPhone ?? widget.prefill?['companyPhone']?.toString();
    _companyEmail = widget.product?.companyEmail ?? widget.prefill?['companyEmail']?.toString();
    _companyWebsite = widget.product?.companyWebsite ?? widget.prefill?['companyWebsite']?.toString();
    _imageUrl = widget.product?.imageUrl ?? widget.prefill?['imageUrl']?.toString();
    _extraFields = Map<String, dynamic>.from(widget.product?.extraFields ?? {});
    _selectedTemplate = widget.product?.category ?? (widget.prefill?['category']?.toString() ?? 'professional_business');
    // Normalize invalid values to avoid dropdown assertion
    const validTemplates = {
      'professional_business',
      'modern_creative',
      'minimal_clean',
      'corporate_formal',
      'service_based',
      'simple_receipt',
    };
    if (!validTemplates.contains(_selectedTemplate)) {
      _selectedTemplate = 'professional_business';
    }
    
    if (_selectedTemplate == 'service_based') {
      _isService = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        
                        // Basic Information Section
                        _buildSectionHeader('Basic Information'),
                        const SizedBox(height: 16),
                        
                        // Product Image Section
                        _buildImageUploadSection(),
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          label: 'Product/Service Name',
                          value: _name,
                          onChanged: (value) => _name = value,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Description',
                          value: _description ?? '',
                          onChanged: (value) => _description = value.isEmpty ? null : value,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Company/Shop Name',
                          value: _companyOrShopName ?? '',
                          onChanged: (value) => _companyOrShopName = value,
                          isRequired: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Company Information Section
                        _buildSectionHeader('Company Information'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Company Address',
                          value: _companyAddress ?? '',
                          onChanged: (value) => _companyAddress = value.isEmpty ? null : value,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Company Phone',
                                value: _companyPhone ?? '',
                                onChanged: (value) => _companyPhone = value.isEmpty ? null : value,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'Company Email',
                                value: _companyEmail ?? '',
                                onChanged: (value) => _companyEmail = value.isEmpty ? null : value,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Company Website',
                          value: _companyWebsite ?? '',
                          onChanged: (value) => _companyWebsite = value.isEmpty ? null : value,
                          keyboardType: TextInputType.url,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Template & Pricing Section
                        _buildSectionHeader('Template & Pricing'),
                        const SizedBox(height: 16),
                        _buildTemplateSelector(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                label: _selectedTemplate == 'service_based' ? 'Hourly Rate' : 'Price',
                                value: _price.toString(),
                                onChanged: (value) => _price = double.tryParse(value) ?? 0.0,
                                keyboardType: TextInputType.number,
                                isRequired: true,
                                prefix: '\$',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'Tax (%)',
                                value: _tax.toString(),
                                onChanged: (value) => _tax = double.tryParse(value) ?? 0.0,
                                keyboardType: TextInputType.number,
                                isRequired: true,
                                suffix: '%',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Inventory',
                                value: _inventory.toString(),
                                onChanged: (value) => _inventory = int.tryParse(value) ?? 0,
                                keyboardType: TextInputType.number,
                                isRequired: !_isService,
                                enabled: !_isService,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildServiceToggle(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Additional Fields Section
                        _buildExtraFieldsSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        _buildSubmitButton(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF2F2F7),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isEdit ? 'Edit Product' : 'New Product',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _isEdit ? 'Update' : 'Save',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
    String? suffix,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: isRequired ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE3F2FD),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE3F2FD),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFF2F2F7),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF2F2F7),
            contentPadding: const EdgeInsets.all(16),
            prefixText: prefix,
            suffixText: suffix,
            prefixStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64B5F6),
              fontWeight: FontWeight.w500,
            ),
            suffixStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64B5F6),
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector() {
    final templates = [
      {'value': 'professional_business', 'label': 'Commercial Invoice', 'icon': Icons.business_outlined},
      {'value': 'modern_creative', 'label': 'Sales Invoice', 'icon': Icons.receipt_outlined},
      {'value': 'minimal_clean', 'label': 'Proforma Invoice', 'icon': Icons.description_outlined},
      {'value': 'corporate_formal', 'label': 'Internal Transfer', 'icon': Icons.swap_horiz_outlined},
      {'value': 'service_based', 'label': 'Timesheet Invoice', 'icon': Icons.schedule_outlined},
      {'value': 'simple_receipt', 'label': 'Payment Receipt', 'icon': Icons.payment_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Template *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE3F2FD),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField2<String>(
            value: _selectedTemplate,
            items: templates.map((template) => DropdownMenuItem<String>(
              value: template['value'] as String,
              child: Row(
                children: [
                  Icon(
                    template['icon'] as IconData,
                    size: 20,
                    color: const Color(0xFF1976D2),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      template['label'] as String,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTemplate = newValue!;
                if (_selectedTemplate == 'service_based') {
                  _isService = true;
                }
              });
            },
            validator: (value) => value == null ? 'Required' : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE3F2FD),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE3F2FD),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            isExpanded: true,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: _selectedTemplate == 'service_based' ? const Color(0xFFF2F2F7) : Colors.white,
            border: Border.all(
              color: const Color(0xFFE3F2FD),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Is Service',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedTemplate == 'service_based' ? const Color(0xFF8E8E93) : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _isService,
                onChanged: _selectedTemplate == 'service_based' ? null : (value) => setState(() => _isService = value),
                activeColor: const Color(0xFF1976D2),
                inactiveThumbColor: const Color(0xFF8E8E93),
                inactiveTrackColor: const Color(0xFFE5E5EA),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtraFieldsSection() {
    List<Widget> fields = [];
    
    switch (_selectedTemplate) {
      case 'professional_business':
        fields = [
          _buildTextField(
            label: 'VAT Registration Number',
            value: _extraFields['vatRegistrationNumber'] ?? '',
            onChanged: (v) => _extraFields['vatRegistrationNumber'] = v.isEmpty ? null : v,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Payment Terms',
            value: _extraFields['paymentTerms'],
            items: [
              {'value': 'Net 15', 'label': 'Net 15', 'icon': Icons.payment_outlined},
              {'value': 'Net 30', 'label': 'Net 30', 'icon': Icons.payment_outlined},
              {'value': 'Net 60', 'label': 'Net 60', 'icon': Icons.payment_outlined},
              {'value': 'Due on Receipt', 'label': 'Due on Receipt', 'icon': Icons.payment_outlined},
            ],
            onChanged: (v) => setState(() => _extraFields['paymentTerms'] = v),
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Purchase Order Number',
            value: _extraFields['purchaseOrderNumber'] ?? '',
            onChanged: (v) => _extraFields['purchaseOrderNumber'] = v.isEmpty ? null : v,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Delivery Terms',
            value: _extraFields['deliveryTerms'],
            items: [
              {'value': 'FOB', 'label': 'FOB', 'icon': Icons.local_shipping_outlined},
              {'value': 'CIF', 'label': 'CIF', 'icon': Icons.local_shipping_outlined},
              {'value': 'EXW', 'label': 'EXW', 'icon': Icons.local_shipping_outlined},
              {'value': 'DDP', 'label': 'DDP', 'icon': Icons.local_shipping_outlined},
            ],
            onChanged: (v) => setState(() => _extraFields['deliveryTerms'] = v),
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'SKU/Code',
                  value: _extraFields['sku'] ?? '',
                  onChanged: (v) => _extraFields['sku'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Unit of Measure',
                  value: _extraFields['unitOfMeasure'],
                  items: [
                    {'value': 'pcs', 'label': 'Pieces', 'icon': Icons.inventory_outlined},
                    {'value': 'kg', 'label': 'Kilograms', 'icon': Icons.scale_outlined},
                    {'value': 'lbs', 'label': 'Pounds', 'icon': Icons.scale_outlined},
                    {'value': 'hours', 'label': 'Hours', 'icon': Icons.access_time_outlined},
                    {'value': 'days', 'label': 'Days', 'icon': Icons.calendar_today_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['unitOfMeasure'] = v),
                  isRequired: true,
                ),
              ),
            ],
          ),
        ];
        break;
        
      case 'modern_creative':
        fields = [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Sales Representative',
                  value: _extraFields['salesRepresentative'] ?? '',
                  onChanged: (v) => _extraFields['salesRepresentative'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Territory/Region',
                  value: _extraFields['territory'] ?? '',
                  onChanged: (v) => _extraFields['territory'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Commission Rate (%)',
                  value: _extraFields['commissionRate'] ?? '',
                  onChanged: (v) => _extraFields['commissionRate'] = v.isEmpty ? null : v,
                  keyboardType: TextInputType.number,
                  suffix: '%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Marketing Campaign Code',
                  value: _extraFields['marketingCampaignCode'] ?? '',
                  onChanged: (v) => _extraFields['marketingCampaignCode'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Customer Segment',
                  value: _extraFields['customerSegment'],
                  items: [
                    {'value': 'Premium', 'label': 'Premium', 'icon': Icons.star_outlined},
                    {'value': 'Standard', 'label': 'Standard', 'icon': Icons.person_outlined},
                    {'value': 'Budget', 'label': 'Budget', 'icon': Icons.savings_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['customerSegment'] = v),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Warranty Period',
                  value: _extraFields['warrantyPeriod'],
                  items: [
                    {'value': '30 days', 'label': '30 days', 'icon': Icons.security_outlined},
                    {'value': '90 days', 'label': '90 days', 'icon': Icons.security_outlined},
                    {'value': '1 year', 'label': '1 year', 'icon': Icons.security_outlined},
                    {'value': '2 years', 'label': '2 years', 'icon': Icons.security_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['warrantyPeriod'] = v),
                  isRequired: true,
                ),
              ),
            ],
          ),
        ];
        break;
        
      case 'minimal_clean':
        fields = [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Validity Period (days)',
                  value: _extraFields['validityPeriod'] ?? '',
                  onChanged: (v) => _extraFields['validityPeriod'] = v.isEmpty ? null : v,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Shipping Method',
                  value: _extraFields['shippingMethod'],
                  items: [
                    {'value': 'Standard', 'label': 'Standard', 'icon': Icons.local_shipping_outlined},
                    {'value': 'Express', 'label': 'Express', 'icon': Icons.flash_on_outlined},
                    {'value': 'Overnight', 'label': 'Overnight', 'icon': Icons.nightlight_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['shippingMethod'] = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Terms & Conditions',
            value: _extraFields['termsAndConditions'] ?? '',
            onChanged: (v) => _extraFields['termsAndConditions'] = v.isEmpty ? null : v,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Currency',
                  value: _extraFields['currency'] ?? 'USD',
                  items: [
                    {'value': 'USD', 'label': 'USD', 'icon': Icons.attach_money_outlined},
                    {'value': 'EUR', 'label': 'EUR', 'icon': Icons.euro_outlined},
                    {'value': 'GBP', 'label': 'GBP', 'icon': Icons.currency_pound_outlined},
                    {'value': 'CAD', 'label': 'CAD', 'icon': Icons.attach_money_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['currency'] = v),
                ),
              ),
              const SizedBox(width: 16),
              if (_extraFields['currency'] != null && _extraFields['currency'] != 'USD')
                Expanded(
                  child: _buildTextField(
                    label: 'Exchange Rate',
                    value: _extraFields['exchangeRate'] ?? '',
                    onChanged: (v) => _extraFields['exchangeRate'] = v.isEmpty ? null : v,
                    keyboardType: TextInputType.number,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ];
        break;
        
      case 'corporate_formal':
        fields = [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Department From',
                  value: _extraFields['departmentFrom'] ?? '',
                  onChanged: (v) => _extraFields['departmentFrom'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Department To',
                  value: _extraFields['departmentTo'] ?? '',
                  onChanged: (v) => _extraFields['departmentTo'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Cost Center',
                  value: _extraFields['costCenter'] ?? '',
                  onChanged: (v) => _extraFields['costCenter'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Project Code',
                  value: _extraFields['projectCode'] ?? '',
                  onChanged: (v) => _extraFields['projectCode'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Authorization Manager',
                  value: _extraFields['authorizationManager'] ?? '',
                  onChanged: (v) => _extraFields['authorizationManager'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Internal Reference Number',
                  value: _extraFields['internalReferenceNumber'] ?? '',
                  onChanged: (v) => _extraFields['internalReferenceNumber'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Asset Tag Number',
            value: _extraFields['assetTagNumber'] ?? '',
            onChanged: (v) => _extraFields['assetTagNumber'] = v.isEmpty ? null : v,
          ),
        ];
        break;
        
      case 'service_based':
        fields = [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Service Category',
                  value: _extraFields['serviceCategory'],
                  items: [
                    {'value': 'Consulting', 'label': 'Consulting', 'icon': Icons.business_outlined},
                    {'value': 'Development', 'label': 'Development', 'icon': Icons.code_outlined},
                    {'value': 'Support', 'label': 'Support', 'icon': Icons.support_agent_outlined},
                    {'value': 'Training', 'label': 'Training', 'icon': Icons.school_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['serviceCategory'] = v),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Skill Level',
                  value: _extraFields['skillLevel'],
                  items: [
                    {'value': 'Junior', 'label': 'Junior', 'icon': Icons.person_outlined},
                    {'value': 'Senior', 'label': 'Senior', 'icon': Icons.person_outlined},
                    {'value': 'Expert', 'label': 'Expert', 'icon': Icons.person_outlined},
                    {'value': 'Lead', 'label': 'Lead', 'icon': Icons.person_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['skillLevel'] = v),
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Hourly Rate',
                  value: _extraFields['hourlyRate'] ?? '',
                  onChanged: (v) => _extraFields['hourlyRate'] = v.isEmpty ? null : v,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  prefix: '\$',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Project Phase',
                  value: _extraFields['projectPhase'] ?? '',
                  onChanged: (v) => _extraFields['projectPhase'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchRow('Billable Hours Only', _extraFields['billableHoursOnly'] ?? false, (v) => setState(() => _extraFields['billableHoursOnly'] = v)),
          const SizedBox(height: 8),
          _buildSwitchRow('Travel Time Included', _extraFields['travelTimeIncluded'] ?? false, (v) => setState(() => _extraFields['travelTimeIncluded'] = v)),
          const SizedBox(height: 8),
          _buildSwitchRow('Emergency Service', _extraFields['emergencyService'] ?? false, (v) => setState(() => _extraFields['emergencyService'] = v)),
        ];
        break;
        
      case 'simple_receipt':
        fields = [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Payment Method',
                  value: _extraFields['paymentMethod'],
                  items: [
                    {'value': 'Cash', 'label': 'Cash', 'icon': Icons.money_outlined},
                    {'value': 'Credit Card', 'label': 'Credit Card', 'icon': Icons.credit_card_outlined},
                    {'value': 'Bank Transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance_outlined},
                    {'value': 'Check', 'label': 'Check', 'icon': Icons.receipt_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['paymentMethod'] = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Receipt Type',
                  value: _extraFields['receiptType'],
                  items: [
                    {'value': 'Final Payment', 'label': 'Final Payment', 'icon': Icons.check_circle_outlined},
                    {'value': 'Partial Payment', 'label': 'Partial Payment', 'icon': Icons.pending_outlined},
                    {'value': 'Deposit', 'label': 'Deposit', 'icon': Icons.account_balance_wallet_outlined},
                  ],
                  onChanged: (v) => setState(() => _extraFields['receiptType'] = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Reference Number',
                  value: _extraFields['referenceNumber'] ?? '',
                  onChanged: (v) => _extraFields['referenceNumber'] = v.isEmpty ? null : v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Original Invoice Number',
                  value: _extraFields['originalInvoiceNumber'] ?? '',
                  onChanged: (v) => _extraFields['originalInvoiceNumber'] = v.isEmpty ? null : v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_extraFields['paymentMethod'] == 'Cash')
            _buildTextField(
              label: 'Change Given',
              value: _extraFields['changeGiven'] ?? '',
              onChanged: (v) => _extraFields['changeGiven'] = v.isEmpty ? null : v,
              keyboardType: TextInputType.number,
              prefix: '\$',
            ),
        ];
        break;
    }

    if (fields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Additional Fields'),
        const SizedBox(height: 16),
        ...fields,
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    String? validatedValue = value;
    if (value != null) {
      bool valueExists = items.any((item) => item['value'] == value);
      if (!valueExists) {
        validatedValue = items.isNotEmpty ? items.first['value'] : null;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE3F2FD),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField2<String>(
            value: validatedValue,
            items: items.map((item) => DropdownMenuItem<String>(
              value: item['value'],
              child: Row(
                children: [
                  Icon(
                    item['icon'],
                    size: 20,
                    color: const Color(0xFF1976D2),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      item['label'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
            onChanged: onChanged,
            validator: isRequired ? (v) => v == null ? 'Required' : null : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE3F2FD),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE3F2FD),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            isExpanded: true,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE3F2FD),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1976D2),
            inactiveThumbColor: const Color(0xFF8E8E93),
            inactiveTrackColor: const Color(0xFFE5E5EA),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submit,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              _isEdit ? AppStrings.productEditButton : AppStrings.productAddButton,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final isCreate = widget.forceCreate || !_isEdit;
      final productId = isCreate ? _genId() : (widget.product!.id);
      
      String? finalImageUrl = _imageUrl;
      
      // Upload image if a new image is selected
      if (_selectedImage != null) {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          
          final imageUploadService = sl<ImageUploadService>();
          finalImageUrl = await imageUploadService.uploadProductImage(_selectedImage!, productId);
          
          // Hide loading indicator
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          // Hide loading indicator
          if (mounted) {
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      
      final product = Product(
        id: productId,
        name: _name.trim(),
        description: _description?.trim().isEmpty == true ? null : _description?.trim(),
        price: _price,
        category: _selectedTemplate,
        tax: _tax,
        inventory: _inventory,
        isService: _isService,
        companyOrShopName: _companyOrShopName,
        companyAddress: _companyAddress?.trim().isEmpty == true ? null : _companyAddress?.trim(),
        companyPhone: _companyPhone?.trim().isEmpty == true ? null : _companyPhone?.trim(),
        companyEmail: _companyEmail?.trim().isEmpty == true ? null : _companyEmail?.trim(),
        companyWebsite: _companyWebsite?.trim().isEmpty == true ? null : _companyWebsite?.trim(),
        imageUrl: finalImageUrl,
        extraFields: _extraFields,
      );

      if (mounted) {
        if (isCreate) {
          context.read<ProductCubit>().addProduct(product);
        } else {
          context.read<ProductCubit>().updateProduct(product);
        }

        Navigator.of(context).pop(product);
      }
    }
  }

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(10000).toString();

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: _selectedImage != null || _imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : _imageUrl != null
                            ? Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              )
                            : _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        if (_selectedImage != null || _imageUrl != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Change Image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add product image',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrl = null; // Clear existing URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }
}