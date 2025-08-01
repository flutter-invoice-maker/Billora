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
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/utils/localization_helper.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  String _searchTerm = '';
  InvoiceStatus? _filterStatus;
  String? _selectedTag; // Add tag filter
  List<String> _availableTags = []; // Available tags for filtering

  @override
  void initState() {
    super.initState();
    // Delay to avoid calling after widget disposal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceCubit>().fetchInvoices();
        context.read<TagsCubit>().getAllTags(); // Load tags
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
            BlocProvider.value(value: context.read<SuggestionsCubit>()),
            BlocProvider.value(value: context.read<TagsCubit>()),
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
        title: Text(LocalizationHelper.getLocalizedString(context, 'deleteInvoice')),
        content: Text(LocalizationHelper.getLocalizedString(context, 'deleteInvoiceConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocalizationHelper.getLocalizedString(context, 'invoiceCancel')),
          ),
          TextButton(
            onPressed: () {
              parentContext.read<InvoiceCubit>().deleteInvoice(invoice.id);
              Navigator.of(dialogContext).pop();
            },
            child: Text(LocalizationHelper.getLocalizedString(context, 'delete')),
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
              title: Text(LocalizationHelper.getLocalizedString(context, 'downloadPdf')),
              subtitle: Text(LocalizationHelper.getLocalizedString(context, 'saveToDevice')),
              onTap: () async {
                Navigator.pop(context);
                final scaffold = ScaffoldMessenger.of(context);
                final pdfReadyText = LocalizationHelper.getLocalizedString(context, 'pdfReady');
                final failedToGenerateText = LocalizationHelper.getLocalizedString(context, 'failedToGeneratePdf');
                
                scaffold.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 16),
                        Text(LocalizationHelper.getLocalizedString(context, 'generatingPdf')),
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
                
                try {
                  final pdfData = await cubit.generatePdf(invoice);
                  await Printing.layoutPdf(onLayout: (format) async => pdfData);
                  
                  if (!mounted) return;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(pdfReadyText),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
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
                          Expanded(child: Text('$failedToGenerateText: ${e.toString()}')),
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
                title: Text(LocalizationHelper.getLocalizedString(context, 'createShareableLink')),
                subtitle: Text(LocalizationHelper.getLocalizedString(context, 'uploadAndGetLink')),
                onTap: () async {
                  Navigator.pop(context);
                  final scaffold = ScaffoldMessenger.of(context);
                  final creatingLinkText = LocalizationHelper.getLocalizedString(context, 'creatingLink');
                  final linkCreatedText = LocalizationHelper.getLocalizedString(context, 'linkCreated');
                  final failedToCreateText = LocalizationHelper.getLocalizedString(context, 'failedToCreateLink');
                  
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(creatingLinkText),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
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
                            Expanded(child: Text(linkCreatedText)),
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
                            Expanded(child: Text('$failedToCreateText: ${e.toString()}')),
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
              title: Text(LocalizationHelper.getLocalizedString(context, 'sendViaEmail')),
              subtitle: Text(kIsWeb ? 'Not available on web due to CORS restrictions' : 'Email with PDF attachment'),
              enabled: !kIsWeb,
                              onTap: kIsWeb ? null : () async {
                  // Lưu tất cả localized strings và scaffold trước async operations
                  final scaffold = ScaffoldMessenger.of(context);
                  final sendInvoiceText = LocalizationHelper.getLocalizedString(context, 'sendInvoice');
                  final emailText = LocalizationHelper.getLocalizedString(context, 'email');
                  final cancelText = LocalizationHelper.getLocalizedString(context, 'invoiceCancel');
                  final sendText = LocalizationHelper.getLocalizedString(context, 'send');
                  final sendingEmailText = LocalizationHelper.getLocalizedString(context, 'sendingEmail');
                  final emailSentText = LocalizationHelper.getLocalizedString(context, 'emailSentSuccessfully');
                  final failedToSendText = LocalizationHelper.getLocalizedString(context, 'failedToSendEmail');
                  
                  // Tạo dialog với localized strings đã lưu
                  final controller = TextEditingController();
                  final email = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(sendInvoiceText),
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: emailText,
                          hintText: 'Enter recipient email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(cancelText),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(controller.text),
                          child: Text(sendText),
                        ),
                      ],
                    ),
                  );
                  
                  if (email == null || email.isEmpty) return;
                  
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(sendingEmailText),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
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
                            Expanded(child: Text('$emailSentText $email')),
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
                            Expanded(child: Text('$failedToSendText: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(
        body: Center(child: Text('Localization not available')),
      );
    }
    
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
                    hintText: LocalizationHelper.getLocalizedString(context, 'searchInvoices'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                      hint: Text(LocalizationHelper.getLocalizedString(context, 'filterByStatus')),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<InvoiceStatus?>(value: null, child: Text(LocalizationHelper.getLocalizedString(context, 'allStatus'))),
                        ...InvoiceStatus.values.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        )),
                      ],
                      onChanged: (status) => setState(() => _filterStatus = status),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tag Filter
                BlocBuilder<TagsCubit, TagsState>(
                  builder: (context, tagsState) {
                    if (tagsState is TagsLoaded) {
                      _availableTags = tagsState.tags.map((tag) => tag.name).toList();
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedTag,
                            hint: Text(LocalizationHelper.getLocalizedString(context, 'filterByTag')),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String?>(value: null, child: Text(LocalizationHelper.getLocalizedString(context, 'allTags'))),
                              ..._availableTags.map((tag) => DropdownMenuItem(
                                value: tag,
                                child: Text(tag),
                              )),
                            ],
                            onChanged: (tag) => setState(() => _selectedTag = tag),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
                    // Filter invoices based on search term, status, and tag
                    final filteredInvoices = invoices.where((invoice) {
                      final searchLower = _searchTerm.toLowerCase();
                      
                      final matchesSearch = _searchTerm.isEmpty ||
                          invoice.id.toLowerCase().contains(searchLower) ||
                          invoice.customerName.toLowerCase().contains(searchLower) ||
                          invoice.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
                          invoice.searchKeywords.any((keyword) => keyword.contains(searchLower));
                      
                      final matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
                      
                      final matchesTag = _selectedTag == null || invoice.tags.contains(_selectedTag);
                      
                      // Debug tags
                      if (_selectedTag != null) {
                        debugPrint('🔍 Invoice ${invoice.id} tags: ${invoice.tags}');
                        debugPrint('🔍 Selected tag: $_selectedTag');
                        debugPrint('🔍 Matches tag: $matchesTag');
                      }
                      
                      return matchesSearch && matchesStatus && matchesTag;
                    }).toList();

                    if (filteredInvoices.isEmpty) {
                      return Center(
                        child: Text(
                          LocalizationHelper.getLocalizedString(context, 'noInvoicesYet'),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                                        _getStatusText(invoice.status),
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
                                            '${LocalizationHelper.getLocalizedString(context, 'invoiceTotal')}: ${LocalizationHelper.formatCurrency(invoice.total, context)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${LocalizationHelper.getLocalizedString(context, 'due')}: ${invoice.dueDate != null ? _formatDate(invoice.dueDate!) : LocalizationHelper.getLocalizedString(context, 'noDueDate')}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          
                                          // Tags
                                          if (invoice.tags.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: invoice.tags.take(3).map((tag) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _getTagColor(tag),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            if (invoice.tags.length > 3)
                                              Text(
                                                '+${invoice.tags.length - 3} ${LocalizationHelper.getLocalizedString(context, 'more')}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                          ],
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
                                      tooltip: LocalizationHelper.getLocalizedString(context, 'preview'),
                                      onPressed: () => _previewInvoice(invoice),
                                    ),
                                    
                                    // Share PDF Button
                                    IconButton(
                                      icon: const Icon(Icons.share_outlined),
                                      tooltip: LocalizationHelper.getLocalizedString(context, 'sharePdf'),
                                      onPressed: () => _showShareOptions(context, invoice, context.read<InvoiceCubit>()),
                                    ),
                                    
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: LocalizationHelper.getLocalizedString(context, 'edit'),
                                      onPressed: () => _openForm(invoice),
                                    ),
                                    
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: LocalizationHelper.getLocalizedString(context, 'delete'),
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

  Color _getTagColor(String tag) {
    // Generate consistent color based on tag name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = tag.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return LocalizationHelper.getLocalizedString(context, 'invoiceStatusDraft');
      case InvoiceStatus.sent:
        return LocalizationHelper.getLocalizedString(context, 'invoiceStatusSent');
      case InvoiceStatus.paid:
        return LocalizationHelper.getLocalizedString(context, 'invoiceStatusPaid');
      case InvoiceStatus.overdue:
        return LocalizationHelper.getLocalizedString(context, 'invoiceStatusOverdue');
      case InvoiceStatus.cancelled:
        return LocalizationHelper.getLocalizedString(context, 'invoiceStatusCancelled');
    }
  }
}