import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_print_templates.dart';
import 'package:billora/src/features/invoice/presentation/widgets/qr_code_widget.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:billora/src/core/utils/app_strings.dart';
import 'package:billora/src/core/utils/snackbar_helper.dart';

class InvoicePreviewPage extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Invoice Preview',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Invoice template display
                  _buildInvoiceDisplay(context),
                  
                  const SizedBox(height: 24),
                  
                  // Action cards section
                  _buildActionCardsSection(context),
                  
                  const SizedBox(height: 120), // Space for bottom actions
                ],
              ),
            ),
          ),
          
          // Fixed bottom action bar
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildInvoiceDisplay(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Invoice header info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoice.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(invoice.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(invoice.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(invoice.status),
                      style: TextStyle(
                        color: _getStatusColor(invoice.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Invoice template content
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 400,
                maxHeight: 600,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: InvoicePrintTemplates.getTemplateById(
                      invoice.templateId ?? 'professional_business',
                      context,
                      invoice,
                      isPreview: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCardsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // AI Analysis Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Not Started',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _retryAnalysis(context),
                      child: const Text(
                        'Retry Analysis',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'AI analysis will be performed automatically once you save this invoice.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // QR Code Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // QR Code display
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        InvoiceQRCodeWidget(
                          invoice: invoice,
                          size: 160,
                          showLabel: false,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Scan to view invoice details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // QR Code actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyQRData(context),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Data'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _regenerateQR(context),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Regenerate'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvoice(context),
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: const Text(
                    'Share Invoice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendEmail(context),
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportPdf(context),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Export PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildBottomSheetOption(
            context,
            Icons.edit_outlined,
            'Edit Invoice',
            () => Navigator.pop(context),
          ),
          _buildBottomSheetOption(
            context,
            Icons.copy_outlined,
            'Duplicate Invoice',
            () => Navigator.pop(context),
          ),
          _buildBottomSheetOption(
            context,
            Icons.delete_outline,
            'Delete Invoice',
            () => Navigator.pop(context),
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF64748B),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return const Color(0xFF64748B);
      case InvoiceStatus.sent:
        return const Color(0xFF3B82F6);
      case InvoiceStatus.paid:
        return const Color(0xFF10B981);
      case InvoiceStatus.overdue:
        return const Color(0xFFEF4444);
      case InvoiceStatus.cancelled:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _retryAnalysis(BuildContext context) {
    // Implement retry analysis logic
    SnackBarHelper.showInfo(
      context,
      message: 'Analysis started...',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _copyQRData(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: invoice.id));
    if (context.mounted) {
      SnackBarHelper.showSuccess(
        context,
        message: 'QR data copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _regenerateQR(BuildContext context) {
    HapticFeedback.lightImpact();
    SnackBarHelper.showInfo(
      context,
      message: 'QR code refreshed',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final cubit = context.read<InvoiceCubit>();
    try {
      final pdfData = await cubit.generatePdf(invoice);
      await Printing.layoutPdf(onLayout: (format) async => pdfData);
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: AppStrings.pdfReady,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          message: '${AppStrings.failedToGeneratePdf}: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    final cubit = context.read<InvoiceCubit>();
    try {
      final pdfData = await cubit.generatePdf(invoice);
      final userId = invoice.customerId;
      final url = await cubit.uploadPdf(
        userId: userId,
        invoiceId: invoice.id,
        pdfData: pdfData,
      );
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: AppStrings.linkCreated,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          message: '${AppStrings.failedToCreateLink}: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _sendEmail(BuildContext context) async {
    final cubit = context.read<InvoiceCubit>();
    final controller = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Send Invoice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter recipient email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    if (context.mounted) {
      SnackBarHelper.showInfo(
        context,
        message: AppStrings.sendingEmail,
        duration: const Duration(seconds: 2),
      );
    }

    try {
      final pdfData = await cubit.generatePdf(invoice);
      await cubit.sendEmail(
        toEmail: email,
        subject: 'Invoice #${invoice.id} - Billora',
        body: 'Dear Customer,\n\nPlease find attached your invoice #${invoice.id}.\n\nThank you!\n\nBillora Team',
        pdfData: pdfData,
        fileName: 'invoice_${invoice.id}.pdf',
      );
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: '${AppStrings.emailSentSuccessfully} $email',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          message: '${AppStrings.failedToSendEmail}: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
}