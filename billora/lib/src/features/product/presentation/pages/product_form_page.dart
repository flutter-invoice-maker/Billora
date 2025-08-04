import 'package:billora/src/features/product/data/default_invoice_categories.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'dart:math';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _description;
  late double _price;
  late String _category;
  late double _tax;
  late int _inventory;
  late bool _isService;
  late bool _isEdit;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    _name = widget.product?.name ?? '';
    _description = widget.product?.description;
    _price = widget.product?.price ?? 0.0;
    _tax = widget.product?.tax ?? 0.0;
    _inventory = widget.product?.inventory ?? 0;
    _isService = widget.product?.isService ?? false;

    final lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _categories =
        defaultInvoiceCategories.map((c) => c[lang] ?? c['en']!).toSet().toList();

    if (widget.product != null) {
      _category = widget.product!.category;
      if (!_categories.contains(_category)) {
        _categories.insert(0, _category);
      }
    } else {
      _category = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? AppStrings.productEditTitle : AppStrings.productAddTitle,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: AppStrings.productName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.productNameRequired;
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: AppStrings.productDescription),
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _price.toString(),
                  decoration: InputDecoration(labelText: AppStrings.productPrice),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null) {
                      return AppStrings.productPriceRequired;
                    }
                    return null;
                  },
                  onSaved: (value) => _price = double.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: AppStrings.productCategory),
                  validator: (value) =>
                      value == null ? AppStrings.productCategoryRequired : null,
                  onSaved: (value) => _category = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _tax.toString(),
                  decoration: InputDecoration(labelText: AppStrings.productTax),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _tax = double.tryParse(value ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _inventory.toString(),
                  decoration: InputDecoration(labelText: AppStrings.productInventory),
                  keyboardType: TextInputType.number,
                  enabled: !_isService,
                  onSaved: (value) =>
                      _inventory = int.tryParse(value ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppStrings.productIsService),
                  value: _isService,
                  onChanged: (value) => setState(() => _isService = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child:
                      Text(_isEdit ? AppStrings.productEditButton : AppStrings.productAddButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Generate unique ID for new products
      String generateUniqueId() {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = Random().nextInt(9999);
        return '${timestamp}_$random';
      }
      
      final product = Product(
        id: widget.product?.id ?? generateUniqueId(),
        name: _name,
        description: _description,
        price: _price,
        category: _category,
        tax: _tax,
        inventory: _inventory,
        isService: _isService,
      );
      if (_isEdit) {
        context.read<ProductCubit>().updateProduct(product);
      } else {
        context.read<ProductCubit>().addProduct(product);
      }
      Navigator.of(context).pop();
    }
  }
} 