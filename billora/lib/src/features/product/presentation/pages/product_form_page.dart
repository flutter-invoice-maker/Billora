import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';

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
  Map<String, dynamic> _extraFields = {};

  // Template keys for dropdown

  String _selectedTemplate = 'professional_business';
  
  late AnimationController _floatingIconsController;

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
    _extraFields = Map<String, dynamic>.from(widget.product?.extraFields ?? {});
    _selectedTemplate = widget.product?.category ?? (widget.prefill?['category']?.toString() ?? 'professional_business');
    // If Timesheet Invoice, force isService true and disable
    if (_selectedTemplate == 'service_based') {
      _isService = true;
    }
    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingIconsController.dispose();
    super.dispose();
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _floatingIconsController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            final progress = (_floatingIconsController.value + index * 0.167) % 1.0;
            final angle = progress * 2 * pi;
            final radius = 80 + sin(progress * 4 * pi) * 15;
            final x = cos(angle) * radius;
            final y = sin(angle) * radius;
            final opacity = (sin(progress * pi) * 0.2 + 0.1).clamp(0.0, 0.3);
            
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - 12,
              top: 150 + y,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  _getFloatingIcon(index),
                  size: 24,
                  color: _getFloatingIconColor(index),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  IconData _getFloatingIcon(int index) {
    final icons = [
      Icons.inventory_2_outlined,
      Icons.category_outlined,
      Icons.local_offer_outlined,
      Icons.trending_up_outlined,
      Icons.analytics_outlined,
      Icons.star_outline,
    ];
    return icons[index % icons.length];
  }

  Color _getFloatingIconColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFB794F6).withValues(alpha: 0.08),
              Colors.white,
              const Color(0xFF8B5FBF).withValues(alpha: 0.12),
              const Color(0xFF7C3AED).withValues(alpha: 0.06),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingIcons(),
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF2D3748), // Thay đổi từ Colors.white thành màu đậm
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _isEdit ? 'Edit Product/Service' : 'Add Product/Service',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748), // Thay đổi từ Colors.white thành màu đậm
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),
                                _buildFormField(
                                  label: 'Product/Service Name',
                                  initialValue: _name,
                                  onSaved: (value) => _name = value!,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Description',
                                  initialValue: _description,
                                  onSaved: (value) => _description = value,
                                  isRequired: false,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Company/Shop Name',
                                  initialValue: _companyOrShopName,
                                  onSaved: (value) => _companyOrShopName = value,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTemplateDropdown(),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: _selectedTemplate == 'service_based' ? 'Hourly Rate' : 'Price',
                                  initialValue: _price.toString(),
                                  onSaved: (value) => _price = double.parse(value!),
                                  isRequired: true,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Tax (%)',
                                  initialValue: _tax.toString(),
                                  onSaved: (value) => _tax = double.tryParse(value ?? '0') ?? 0,
                                  isRequired: true,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Inventory',
                                  initialValue: _inventory.toString(),
                                  onSaved: (value) => _inventory = int.tryParse(value ?? '0') ?? 0,
                                  isRequired: !_isService,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20),
                                _buildServiceSwitch(),
                                const SizedBox(height: 32),
                                _buildExtraFieldsSection(),
                                const SizedBox(height: 32),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    String? initialValue,
    required FormFieldSetter<String?> onSaved,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: isRequired ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }


  Widget _buildTemplateDropdown() {
    return simpleDropdownField(
      label: 'Template',
      value: _selectedTemplate,
      items: [
        {'value': 'professional_business', 'label': 'Commercial Invoice', 'icon': Icons.business},
        {'value': 'modern_creative', 'label': 'Sales Invoice', 'icon': Icons.receipt},
        {'value': 'minimal_clean', 'label': 'Proforma Invoice', 'icon': Icons.description},
        {'value': 'corporate_formal', 'label': 'Internal Transfer', 'icon': Icons.swap_horiz},
        {'value': 'service_based', 'label': 'Timesheet Invoice', 'icon': Icons.schedule},
        {'value': 'simple_receipt', 'label': 'Payment Receipt', 'icon': Icons.payment},
      ],
      onChanged: (String? newValue) {
        setState(() {
          _selectedTemplate = newValue!;
          // If Timesheet Invoice, force isService true and disable
          if (_selectedTemplate == 'service_based') {
            _isService = true;
          }
        });
      },
      onSaved: (value) => _selectedTemplate = value!,
      isRequired: true,
    );
  }

  Widget _buildExtraFieldsSection() {
    List<Widget> fields = [];
    
    switch (_selectedTemplate) {
      case 'professional_business':
        fields = [
          _buildFormField(
            label: 'VAT Registration Number',
            initialValue: _extraFields['vatRegistrationNumber'],
            onSaved: (v) => _extraFields['vatRegistrationNumber'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Payment Terms',
            value: _extraFields['paymentTerms'],
            items: [
              {'value': 'Net 15', 'label': 'Net 15', 'icon': Icons.payment},
              {'value': 'Net 30', 'label': 'Net 30', 'icon': Icons.payment},
              {'value': 'Net 60', 'label': 'Net 60', 'icon': Icons.payment},
              {'value': 'Due on Receipt', 'label': 'Due on Receipt', 'icon': Icons.payment},
            ],
            onChanged: (v) => setState(() => _extraFields['paymentTerms'] = v),
            onSaved: (v) => _extraFields['paymentTerms'] = v,
            isRequired: true,
          ),
          _buildFormField(
            label: 'Purchase Order Number',
            initialValue: _extraFields['purchaseOrderNumber'],
            onSaved: (v) => _extraFields['purchaseOrderNumber'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Delivery Terms',
            value: _extraFields['deliveryTerms'],
            items: [
              {'value': 'FOB', 'label': 'FOB', 'icon': Icons.local_shipping},
              {'value': 'CIF', 'label': 'CIF', 'icon': Icons.local_shipping},
              {'value': 'EXW', 'label': 'EXW', 'icon': Icons.local_shipping},
              {'value': 'DDP', 'label': 'DDP', 'icon': Icons.local_shipping},
            ],
            onChanged: (v) => setState(() => _extraFields['deliveryTerms'] = v),
            onSaved: (v) => _extraFields['deliveryTerms'] = v,
            isRequired: true,
          ),
          _buildFormField(
            label: 'SKU/Code',
            initialValue: _extraFields['sku'],
            onSaved: (v) => _extraFields['sku'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Unit of Measure',
            value: _extraFields['unitOfMeasure'],
            items: [
              {'value': 'pcs', 'label': 'Pieces', 'icon': Icons.inventory},
              {'value': 'kg', 'label': 'Kilograms', 'icon': Icons.scale},
              {'value': 'lbs', 'label': 'Pounds', 'icon': Icons.scale},
              {'value': 'hours', 'label': 'Hours', 'icon': Icons.access_time},
              {'value': 'days', 'label': 'Days', 'icon': Icons.calendar_today},
            ],
            onChanged: (v) => setState(() => _extraFields['unitOfMeasure'] = v),
            onSaved: (v) => _extraFields['unitOfMeasure'] = v,
            isRequired: true,
          ),
        ];
        break;
        
      case 'modern_creative':
        fields = [
          _buildFormField(
            label: 'Sales Representative',
            initialValue: _extraFields['salesRepresentative'],
            onSaved: (v) => _extraFields['salesRepresentative'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Territory/Region',
            initialValue: _extraFields['territory'],
            onSaved: (v) => _extraFields['territory'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Commission Rate (%)',
            initialValue: _extraFields['commissionRate'],
            onSaved: (v) => _extraFields['commissionRate'] = v,
            isRequired: false,
            keyboardType: TextInputType.number,
          ),
          _buildFormField(
            label: 'Marketing Campaign Code',
            initialValue: _extraFields['marketingCampaignCode'],
            onSaved: (v) => _extraFields['marketingCampaignCode'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Customer Segment',
            value: _extraFields['customerSegment'],
            items: [
              {'value': 'Premium', 'label': 'Premium', 'icon': Icons.star},
              {'value': 'Standard', 'label': 'Standard', 'icon': Icons.person},
              {'value': 'Budget', 'label': 'Budget', 'icon': Icons.savings},
            ],
            onChanged: (v) => setState(() => _extraFields['customerSegment'] = v),
            onSaved: (v) => _extraFields['customerSegment'] = v,
            isRequired: true,
          ),
          simpleDropdownField(
            label: 'Warranty Period',
            value: _extraFields['warrantyPeriod'],
            items: [
              {'value': '30 days', 'label': '30 days', 'icon': Icons.security},
              {'value': '90 days', 'label': '90 days', 'icon': Icons.security},
              {'value': '1 year', 'label': '1 year', 'icon': Icons.security},
              {'value': '2 years', 'label': '2 years', 'icon': Icons.security},
            ],
            onChanged: (v) => setState(() => _extraFields['warrantyPeriod'] = v),
            onSaved: (v) => _extraFields['warrantyPeriod'] = v,
            isRequired: true,
          ),
        ];
        break;
        
      case 'minimal_clean':
        fields = [
          _buildFormField(
            label: 'Validity Period (days)',
            initialValue: _extraFields['validityPeriod'],
            onSaved: (v) => _extraFields['validityPeriod'] = v,
            isRequired: false,
            keyboardType: TextInputType.number,
          ),
          _buildDatePickerField(
            label: 'Estimated Delivery Date',
            value: _extraFields['estimatedDeliveryDate'],
            onChanged: (v) => setState(() => _extraFields['estimatedDeliveryDate'] = v),
            onSaved: (v) => _extraFields['estimatedDeliveryDate'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Shipping Method',
            value: _extraFields['shippingMethod'],
            items: [
              {'value': 'Standard', 'label': 'Standard', 'icon': Icons.local_shipping},
              {'value': 'Express', 'label': 'Express', 'icon': Icons.flash_on},
              {'value': 'Overnight', 'label': 'Overnight', 'icon': Icons.nightlight},
            ],
            onChanged: (v) => setState(() => _extraFields['shippingMethod'] = v),
            onSaved: (v) => _extraFields['shippingMethod'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Terms & Conditions',
            initialValue: _extraFields['termsAndConditions'],
            onSaved: (v) => _extraFields['termsAndConditions'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Currency',
            value: _extraFields['currency'] ?? 'USD',
            items: [
              {'value': 'USD', 'label': 'USD', 'icon': Icons.attach_money},
              {'value': 'EUR', 'label': 'EUR', 'icon': Icons.euro},
              {'value': 'GBP', 'label': 'GBP', 'icon': Icons.currency_pound},
              {'value': 'CAD', 'label': 'CAD', 'icon': Icons.attach_money},
            ],
            onChanged: (v) => setState(() => _extraFields['currency'] = v),
            onSaved: (v) => _extraFields['currency'] = v,
            isRequired: false,
          ),
          if (_extraFields['currency'] != null && _extraFields['currency'] != 'USD')
            _buildFormField(
              label: 'Exchange Rate',
              initialValue: _extraFields['exchangeRate'],
              onSaved: (v) => _extraFields['exchangeRate'] = v,
              isRequired: false,
              keyboardType: TextInputType.number,
            ),
        ];
        break;
        
      case 'corporate_formal':
        fields = [
          _buildFormField(
            label: 'Department From',
            initialValue: _extraFields['departmentFrom'],
            onSaved: (v) => _extraFields['departmentFrom'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Department To',
            initialValue: _extraFields['departmentTo'],
            onSaved: (v) => _extraFields['departmentTo'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Cost Center',
            initialValue: _extraFields['costCenter'],
            onSaved: (v) => _extraFields['costCenter'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Project Code',
            initialValue: _extraFields['projectCode'],
            onSaved: (v) => _extraFields['projectCode'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Authorization Manager',
            initialValue: _extraFields['authorizationManager'],
            onSaved: (v) => _extraFields['authorizationManager'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Internal Reference Number',
            initialValue: _extraFields['internalReferenceNumber'],
            onSaved: (v) => _extraFields['internalReferenceNumber'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Asset Tag Number',
            initialValue: _extraFields['assetTagNumber'],
            onSaved: (v) => _extraFields['assetTagNumber'] = v,
            isRequired: false,
          ),
        ];
        break;
        
      case 'service_based':
        fields = [
          simpleDropdownField(
            label: 'Service Category',
            value: _extraFields['serviceCategory'],
            items: [
              {'value': 'Consulting', 'label': 'Consulting', 'icon': Icons.business},
              {'value': 'Development', 'label': 'Development', 'icon': Icons.code},
              {'value': 'Support', 'label': 'Support', 'icon': Icons.support_agent},
              {'value': 'Training', 'label': 'Training', 'icon': Icons.school},
            ],
            onChanged: (v) => setState(() => _extraFields['serviceCategory'] = v),
            onSaved: (v) => _extraFields['serviceCategory'] = v,
            isRequired: true,
          ),
          _buildFormField(
            label: 'Hourly Rate',
            initialValue: _extraFields['hourlyRate'],
            onSaved: (v) => _extraFields['hourlyRate'] = v,
            isRequired: true,
            keyboardType: TextInputType.number,
          ),
          simpleDropdownField(
            label: 'Skill Level',
            value: _extraFields['skillLevel'],
            items: [
              {'value': 'Junior', 'label': 'Junior', 'icon': Icons.person},
              {'value': 'Senior', 'label': 'Senior', 'icon': Icons.person},
              {'value': 'Expert', 'label': 'Expert', 'icon': Icons.person},
              {'value': 'Lead', 'label': 'Lead', 'icon': Icons.person},
            ],
            onChanged: (v) => setState(() => _extraFields['skillLevel'] = v),
            onSaved: (v) => _extraFields['skillLevel'] = v,
            isRequired: true,
          ),
          _buildFormField(
            label: 'Project Phase',
            initialValue: _extraFields['projectPhase'],
            onSaved: (v) => _extraFields['projectPhase'] = v,
            isRequired: false,
          ),
          _buildSwitchField(
            label: 'Billable Hours Only',
            value: _extraFields['billableHoursOnly'] ?? false,
            onChanged: (v) => setState(() => _extraFields['billableHoursOnly'] = v),
            onSaved: (v) => _extraFields['billableHoursOnly'] = v,
            isRequired: false,
          ),
          _buildSwitchField(
            label: 'Travel Time Included',
            value: _extraFields['travelTimeIncluded'] ?? false,
            onChanged: (v) => setState(() => _extraFields['travelTimeIncluded'] = v),
            onSaved: (v) => _extraFields['travelTimeIncluded'] = v,
            isRequired: false,
          ),
          _buildSwitchField(
            label: 'Emergency Service',
            value: _extraFields['emergencyService'] ?? false,
            onChanged: (v) => setState(() => _extraFields['emergencyService'] = v),
            onSaved: (v) => _extraFields['emergencyService'] = v,
            isRequired: false,
          ),
        ];
        break;
        
      case 'simple_receipt':
        fields = [
          simpleDropdownField(
            label: 'Payment Method',
            value: _extraFields['paymentMethod'],
            items: [
              {'value': 'Cash', 'label': 'Cash', 'icon': Icons.money},
              {'value': 'Credit Card', 'label': 'Credit Card', 'icon': Icons.credit_card},
              {'value': 'Bank Transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
              {'value': 'Check', 'label': 'Check', 'icon': Icons.receipt},
            ],
            onChanged: (v) => setState(() => _extraFields['paymentMethod'] = v),
            onSaved: (v) => _extraFields['paymentMethod'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Reference Number',
            initialValue: _extraFields['referenceNumber'],
            onSaved: (v) => _extraFields['referenceNumber'] = v,
            isRequired: false,
          ),
          simpleDropdownField(
            label: 'Receipt Type',
            value: _extraFields['receiptType'],
            items: [
              {'value': 'Final Payment', 'label': 'Final Payment', 'icon': Icons.check_circle},
              {'value': 'Partial Payment', 'label': 'Partial Payment', 'icon': Icons.pending},
              {'value': 'Deposit', 'label': 'Deposit', 'icon': Icons.account_balance_wallet},
            ],
            onChanged: (v) => setState(() => _extraFields['receiptType'] = v),
            onSaved: (v) => _extraFields['receiptType'] = v,
            isRequired: false,
          ),
          _buildFormField(
            label: 'Original Invoice Number',
            initialValue: _extraFields['originalInvoiceNumber'],
            onSaved: (v) => _extraFields['originalInvoiceNumber'] = v,
            isRequired: false,
          ),
          if (_extraFields['paymentMethod'] == 'Cash')
            _buildFormField(
              label: 'Change Given',
              initialValue: _extraFields['changeGiven'],
              onSaved: (v) => _extraFields['changeGiven'] = v,
              isRequired: false,
              keyboardType: TextInputType.number,
            ),
        ];
        break;
    }

    if (fields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Fields',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...fields.map((field) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: field,
        )),
      ],
    );
  }

  Widget simpleDropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items, // Changed to support icon + text
    required ValueChanged<String?> onChanged,
    required FormFieldSetter<String?> onSaved,
    bool isRequired = false,
  }) {
    // Validate that the value exists in items, if not, set to null or first item
    String? validatedValue = value;
    if (value != null) {
      bool valueExists = items.any((item) => item['value'] == value);
      if (!valueExists) {
        validatedValue = items.isNotEmpty ? items.first['value'] : null;
      }
    }
    
    return DropdownButtonFormField2<String>(
      value: validatedValue,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item['value'],
        child: Row(
          children: [
            if (item['icon'] != null) ...[
              Icon(item['icon'], size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(item['label']),
          ],
        ),
      )).toList(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: isRequired ? (v) => v == null ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      isExpanded: true,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required FormFieldSetter<bool> onSaved,
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label + (isRequired ? ' *' : ''),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required FormFieldSetter<String?> onSaved,
    bool isRequired = false,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: value != null ? DateTime.parse(value).toString().split(' ')[0] : '',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value != null ? DateTime.parse(value) : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked.toIso8601String());
        }
      },
      validator: isRequired ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildServiceSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Is service (no inventory tracking)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Toggle if this is a service instead of a physical product',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isService,
            onChanged: _selectedTemplate == 'service_based' ? null : (value) => setState(() => _isService = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isEdit ? AppStrings.productEditButton : AppStrings.productAddButton,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final isCreate = widget.forceCreate || !_isEdit;
      final product = Product(
        id: isCreate ? _genId() : (widget.product!.id),
        name: _name.trim(),
        description: _description?.trim().isEmpty == true ? null : _description?.trim(),
        price: _price,
        category: _selectedTemplate,
        tax: _tax,
        inventory: _inventory,
        isService: _isService,
        companyOrShopName: _companyOrShopName,
        extraFields: _extraFields,
      );

      if (isCreate) {
        context.read<ProductCubit>().addProduct(product);
      } else {
        context.read<ProductCubit>().updateProduct(product);
      }

      Navigator.of(context).pop(product);
    }
  }

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(10000).toString();
}
