import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
// Removed unused imports: import 'package:billora/src/core/widgets/custom_text_field.dart';
// Removed unused imports: import 'package:billora/src/core/widgets/custom_button.dart';
import 'dart:math' as math;
import 'package:billora/src/core/utils/app_strings.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;
  final Map<String, String>? prefill;
  final bool forceCreate;
  const CustomerFormPage({super.key, this.customer, this.prefill, this.forceCreate = false});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late AnimationController _floatingIconsController;

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString() + 
      math.Random().nextInt(10000).toString();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? widget.prefill?['name'] ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? widget.prefill?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? widget.prefill?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? widget.prefill?['address'] ?? '');
    
    _floatingIconsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _floatingIconsController.dispose();
    super.dispose();
  }


  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final isCreate = widget.forceCreate || widget.customer == null;
      final customer = Customer(
        id: isCreate ? generateId() : (widget.customer!.id),
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      if (isCreate) {
        context.read<CustomerCubit>().addCustomer(customer);
      } else {
        context.read<CustomerCubit>().updateCustomer(customer);
      }

      Navigator.of(context).pop(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()), // Fixed withOpacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color(0xFF2D3748), // Thay đổi từ Colors.white thành màu đậm
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.customer == null 
                            ? AppStrings.customerAddTitle 
                            : AppStrings.customerEditTitle,
                        style: const TextStyle(
                          color: Color(0xFF2D3748), // Thay đổi từ Colors.white thành màu đậm
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form Title
                          Center(
                            child: Container(
                              width: 60,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Customer Icon
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withAlpha((0.3 * 255).round()), // Fixed withOpacity
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Name Field
                          _buildCustomTextField(
                            controller: _nameController,
                            label: AppStrings.customerName,
                            icon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty 
                                ? AppStrings.customerNameRequired 
                                : null,
                          ),
                          const SizedBox(height: 20),
                          
                          // Email Field
                          _buildCustomTextField(
                            controller: _emailController,
                            label: AppStrings.customerEmail,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value != null && 
                                value.isNotEmpty && 
                                !value.contains('@') 
                                ? AppStrings.customerEmailInvalid 
                                : null,
                          ),
                          const SizedBox(height: 20),
                          
                          // Phone Field
                          _buildCustomTextField(
                            controller: _phoneController,
                            label: AppStrings.customerPhone,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          
                          // Address Field
                          _buildCustomTextField(
                            controller: _addressController,
                            label: AppStrings.customerAddress,
                            icon: Icons.location_on_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 40),
                          
                          // Submit Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withAlpha((0.4 * 255).round()), // Fixed withOpacity
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                widget.customer == null 
                                    ? AppStrings.customerAddButton 
                                    : AppStrings.customerUpdateButton,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
