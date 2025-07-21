import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/core/widgets/custom_text_field.dart';
import 'package:billora/src/core/widgets/custom_button.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;
  const CustomerFormPage({super.key, this.customer});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(10000).toString();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final customer = Customer(
        id: widget.customer?.id ?? generateId(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );
      if (widget.customer == null) {
        context.read<CustomerCubit>().addCustomer(customer);
      } else {
        context.read<CustomerCubit>().updateCustomer(customer);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? loc.customerAddTitle : loc.customerEditTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: loc.customerName,
                validator: (value) => value == null || value.isEmpty ? loc.customerNameRequired : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                label: loc.customerEmail,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value != null && value.isNotEmpty && !value.contains('@') ? loc.customerEmailInvalid : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: loc.customerPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: loc.customerAddress,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.customer == null ? loc.customerAddButton : loc.customerUpdateButton,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
