import 'package:flutter/material.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/invoice_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_state.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_state.dart';

class InvoiceFormPage extends StatefulWidget {
  final Invoice? invoice;
  const InvoiceFormPage({super.key, this.invoice});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
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
  bool _isEdit = false;

  static const List<Map<String, String>> _templates = [
    {'id': 'template_a', 'name': 'Template A'},
    {'id': 'template_b', 'name': 'Template B'},
    {'id': 'template_c', 'name': 'Template C'},
  ];

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _isEdit = invoice != null;
    _customerId = invoice?.customerId ?? '';
    _customerName = invoice?.customerName ?? '';
    _items = invoice?.items ?? [];
    _subtotal = _items.fold(0, (sum, item) => sum + item.total);
    _tax = _items.fold(0, (sum, item) => sum + item.tax);
    _total = _subtotal + _tax;
    _status = invoice?.status ?? InvoiceStatus.draft;
    _createdAt = invoice?.createdAt ?? DateTime.now();
    _dueDate = invoice?.dueDate;
    _paidAt = invoice?.paidAt;
    _note = invoice?.note;
    _templateId = invoice?.templateId;
  }

  void _recalculateTotals() {
    _subtotal = _items.fold(0, (sum, item) => sum + item.total);
    _tax = _items.fold(0, (sum, item) => sum + item.tax);
    _total = _subtotal + _tax;
  }

  void _addItem(Product product) async {
    setState(() {
      _items.add(InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: product.name,
        description: product.description,
        quantity: 1,
        unitPrice: product.price,
        tax: product.tax,
        total: product.price + product.tax,
        productId: product.id,
      ));
      _recalculateTotals();
    });
  }

  void _updateItemQuantity(int index, double quantity) {
    setState(() {
      final item = _items[index];
      final total = (item.unitPrice * quantity) + item.tax;
      _items[index] = item.copyWith(quantity: quantity, total: total);
      _recalculateTotals();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _recalculateTotals();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _recalculateTotals();
    final invoice = Invoice(
      id: widget.invoice?.id ?? '',
      customerId: _customerId,
      customerName: _customerName,
      items: _items,
      subtotal: _subtotal,
      tax: _tax,
      total: _total,
      status: _status,
      createdAt: _createdAt,
      dueDate: _dueDate,
      paidAt: _paidAt,
      note: _note,
      templateId: _templateId,
    );
    context.read<InvoiceCubit>().addInvoice(invoice);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Invoice updated!' : 'Invoice created!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? loc.invoiceEditTitle : loc.invoiceAddTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? loc.invoiceEditTitle : loc.invoiceAddTitle),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _save,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Dropdown chọn khách hàng
            BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (customers) => DropdownButtonFormField<String>(
                    value: _customerId.isNotEmpty ? _customerId : null,
                    decoration: InputDecoration(
                      labelText: loc.customerName,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: customers.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )).toList(),
                    onChanged: (id) {
                      final customer = customers.firstWhere((c) => c.id == id);
                      setState(() {
                        _customerId = customer.id;
                        _customerName = customer.name;
                      });
                    },
                    validator: (v) => v == null || v.isEmpty ? loc.customerNameRequired : null,
                  ),
                  orElse: () => const LinearProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 24),
            // Dropdown chọn template
            DropdownButtonFormField<String>(
              value: _templateId,
              decoration: InputDecoration(
                labelText: 'Template',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _templates.map((tpl) => DropdownMenuItem(
                value: tpl['id'],
                child: Text(tpl['name']!),
              )).toList(),
              onChanged: (id) => setState(() => _templateId = id),
              validator: (v) => v == null || v.isEmpty ? 'Please select a template' : null,
            ),
            const SizedBox(height: 24),
            // Multi-select sản phẩm
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (products) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.invoiceItems, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: products.map((product) {
                          final isSelected = _items.any((item) => item.productId == product.id);
                          return FilterChip(
                            label: Text(product.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected && !isSelected) {
                                _addItem(product);
                              } else if (!selected && isSelected) {
                                final idx = _items.indexWhere((item) => item.productId == product.id);
                                if (idx != -1) _removeItem(idx);
                              }
                            },
                            selectedColor: Colors.deepPurple.shade100,
                            checkmarkColor: Colors.deepPurple,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(item.description ?? '', style: const TextStyle(color: Colors.grey)),
                                      Row(
                                        children: [
                                          Text('${loc.productPrice}: '),
                                          Text(item.unitPrice.toStringAsFixed(2)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('${loc.productTax}: '),
                                          Text(item.tax.toStringAsFixed(2)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: item.quantity.toStringAsFixed(0),
                                        decoration: InputDecoration(
                                          labelText: loc.productInventory,
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) {
                                          final qty = double.tryParse(v) ?? 1;
                                          _updateItemQuantity(idx, qty);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: 'Remove',
                                        onPressed: () => _removeItem(idx),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  orElse: () => const LinearProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 24),
            // Due date picker
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_dueDate != null ? '${_dueDate!.toLocal()}'.split(' ')[0] : 'Select date'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InvoiceStatus>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: InvoiceStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    )).toList(),
                    onChanged: (s) => setState(() => _status = s!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tổng tiền
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${loc.invoiceSubtotal}: ${_subtotal.toStringAsFixed(2)}'),
                    Text('${loc.invoiceTax}: ${_tax.toStringAsFixed(2)}'),
                    Text('${loc.invoiceTotal}: ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Note
            TextFormField(
              initialValue: _note,
              decoration: InputDecoration(
                labelText: loc.invoiceNote,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSaved: (v) => _note = v,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
} 