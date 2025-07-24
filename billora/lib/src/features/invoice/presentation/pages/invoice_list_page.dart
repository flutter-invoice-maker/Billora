import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/invoice_cubit.dart';
import '../cubit/invoice_state.dart';
import '../../domain/entities/invoice.dart';
import 'invoice_form_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:billora/src/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_preview_widget.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  String _searchTerm = '';
  InvoiceStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceCubit>().fetchInvoices();
  }

  void _openForm([Invoice? invoice]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<InvoiceCubit>()),
            BlocProvider.value(value: context.read<CustomerCubit>()),
            BlocProvider.value(value: context.read<ProductCubit>()),
          ],
          child: InvoiceFormPage(invoice: invoice),
        ),
      ),
    );
    if (!mounted) return;
    context.read<InvoiceCubit>().fetchInvoices();
  }

  void _deleteInvoice(BuildContext parentContext, Invoice invoice) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              parentContext.read<InvoiceCubit>().deleteInvoice(invoice.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _previewInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: InvoicePreviewWidget(invoice: invoice),
        ),
      ),
    );
  }

  String _getTemplateName(String? templateId) {
    switch (templateId) {
      case 'template_a':
        return 'Template A';
      case 'template_b':
        return 'Template B';
      case 'template_c':
        return 'Template C';
      default:
        return 'Default';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.invoiceListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by customer or invoice ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<InvoiceStatus?>(
                  value: _filterStatus,
                  hint: const Text('Status'),
                  items: [
                    const DropdownMenuItem<InvoiceStatus?>(value: null, child: Text('All')),
                    ...InvoiceStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    )),
                  ],
                  onChanged: (status) => setState(() => _filterStatus = status),
                  underline: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (invoices) {
                    var filtered = invoices;
                    if (_filterStatus != null) {
                      filtered = filtered.where((i) => i.status == _filterStatus).toList();
                    }
                    if (_searchTerm.isNotEmpty) {
                      final term = _searchTerm.toLowerCase();
                      filtered = filtered.where((i) =>
                        i.customerName.toLowerCase().contains(term) ||
                        i.id.toLowerCase().contains(term)
                      ).toList();
                    }
                    if (filtered.isEmpty) {
                      return Center(child: Text(loc.invoiceEmpty));
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Text('#${invoice.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(invoice.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(invoice.status.name, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text('Total: ${invoice.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepPurple)),
                                if (invoice.dueDate != null)
                                  Text('Due: ${invoice.dueDate!.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
                                Text('Template: ${_getTemplateName(invoice.templateId)}', style: const TextStyle(color: Colors.blueGrey)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined),
                                  tooltip: 'Preview',
                                  onPressed: () => _previewInvoice(invoice),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit',
                                  onPressed: () => _openForm(invoice),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () => _deleteInvoice(context, invoice),
                                ),
                              ],
                            ),
                            onTap: () => _openForm(invoice),
                          ),
                        );
                      },
                    );
                  },
                  error: (msg) => Center(child: Text(msg)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.black45;
    }
  }
} 