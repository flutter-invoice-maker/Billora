import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'dart:math' as math;

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
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Focus nodes for better UX
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString() + 
      math.Random().nextInt(10000).toString();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? widget.prefill?['name'] ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? widget.prefill?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? widget.prefill?['phone'] ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? widget.prefill?['address'] ?? '');
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
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
    final isEdit = widget.customer != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Profile' : 'New Contact',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              isEdit ? 'Update' : 'Save',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            // Handle photo change
                          },
                          child: const Text(
                            'Change Photo',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form Fields
                  _buildMinimalTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: 'Name',
                    validator: (value) => value == null || value.isEmpty 
                        ? 'Name is required' 
                        : null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null && 
                        value.isNotEmpty && 
                        !value.contains('@') 
                        ? 'Invalid email address' 
                        : null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_addressFocus),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMinimalTextField(
                    controller: _addressController,
                    focusNode: _addressFocus,
                    label: 'Address',
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Update Contact' : 'Add Contact',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        
        // Text Field
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            final isFocused = focusNode.hasFocus;
            
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isFocused ? Colors.black : Colors.grey[300]!,
                  width: isFocused ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                validator: validator,
                maxLines: maxLines,
                textInputAction: textInputAction,
                onFieldSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Enter ${label.toLowerCase()}',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}