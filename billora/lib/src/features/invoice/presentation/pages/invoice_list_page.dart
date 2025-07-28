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
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
    // Delay to avoid calling after widget disposal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceCubit>().fetchInvoices();
      }
    });
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

  void _showShareOptions(BuildContext context, Invoice invoice, InvoiceCubit cubit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Invoice PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Option 1: Generate & Download
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.blue),
              title: const Text('Download PDF'),
              subtitle: const Text('Save to your device'),
              onTap: () async {
                Navigator.pop(context);
                final scaffold = ScaffoldMessenger.of(context);
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Text('Generating PDF...'),
                      ],
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await Printing.layoutPdf(onLayout: (format) async => pdfData);
                  
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('PDF ready for download!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Failed to generate PDF: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            
            // Option 2: Upload & Share Link (Mobile only)
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.link_outlined, color: Colors.green),
                title: const Text('Create Shareable Link'),
                subtitle: const Text('Upload and get a link to share'),
                onTap: () async {
                  Navigator.pop(context);
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Text('Creating shareable link...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  try {
                    final pdfData = await cubit.generatePdf(invoice);
                    final userId = invoice.customerId;
                    final url = await cubit.uploadPdf(
                      userId: userId,
                      invoiceId: invoice.id,
                      pdfData: pdfData,
                    );
                    if (!mounted) return;
                    await Clipboard.setData(ClipboardData(text: url));
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Shareable link created! Link copied to clipboard.')),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Failed to create link: ${e.toString()}')),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            
            // Option 3: Send via Email (Mobile only due to CORS)
            ListTile(
              leading: Icon(Icons.email_outlined, color: kIsWeb ? Colors.grey : Colors.orange),
              title: Text('Send via Email'),
              subtitle: Text(kIsWeb ? 'Not available on web due to CORS restrictions' : 'Email with PDF attachment'),
              enabled: !kIsWeb,
                              onTap: kIsWeb ? null : () async {
                  Navigator.pop(context);
                  
                  // Store ScaffoldMessenger before async operations
                  final scaffold = ScaffoldMessenger.of(context);
                  
                  final email = await _promptEmail(context);
                  if (email == null || email.isEmpty) return;
                
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Text('Sending email...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await cubit.sendEmail(
                    toEmail: email,
                    subject: 'Invoice #${invoice.id} - Billora',
                    body: 'Dear Customer,\n\nPlease find attached your invoice #${invoice.id}.\n\nThank you for your business!\n\nBest regards,\nBillora Team',
                    pdfData: pdfData,
                    fileName: 'invoice_${invoice.id}.pdf',
                  );
                  
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Email sent successfully to $email')),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Failed to send email: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            

          ],
        ),
      ),
    );
  }

  Future<String?> _promptEmail(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Invoice'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter recipient email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );
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
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by customer or invoice ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<InvoiceStatus?>(
                      value: _filterStatus,
                      hint: const Text('Filter by Status'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<InvoiceStatus?>(value: null, child: Text('All Status')),
                        ...InvoiceStatus.values.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        )),
                      ],
                      onChanged: (status) => setState(() => _filterStatus = status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Invoice List
          Expanded(
            child: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (invoices) {
                    // Filter invoices based on search term and status
                    final filteredInvoices = invoices.where((invoice) {
                      final matchesSearch = _searchTerm.isEmpty ||
                          invoice.id.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                          invoice.customerName.toLowerCase().contains(_searchTerm.toLowerCase());
                      
                      final matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
                      
                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredInvoices.isEmpty) {
                      return const Center(
                        child: Text(
                          'No invoices found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ID: ${invoice.id.substring(0, 8)}...',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            invoice.customerName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(invoice.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        invoice.status.name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total: \$${invoice.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                                                                      Text(
                                              'Due: ${_formatDate(invoice.dueDate!)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Template: ${_getTemplateName(invoice.templateId)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Action Buttons
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Preview Button
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined),
                                      tooltip: 'Preview',
                                      onPressed: () => _previewInvoice(invoice),
                                    ),
                                    
                                    // Share PDF Button
                                    IconButton(
                                      icon: const Icon(Icons.share_outlined),
                                      tooltip: 'Share PDF',
                                      onPressed: () => _showShareOptions(context, invoice, context.read<InvoiceCubit>()),
                                    ),
                                    
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit',
                                      onPressed: () => _openForm(invoice),
                                    ),
                                    
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteInvoice(context, invoice),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Color _getStatusColor(InvoiceStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}