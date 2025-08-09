import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_print_templates.dart';

class InvoicePreviewWidget extends StatelessWidget {
  final Invoice invoice;
  const InvoicePreviewWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    // Use the new template system with preview mode
    return InvoicePrintTemplates.getTemplateById(
      invoice.templateId ?? 'template_a',
      context,
      invoice,
      isPreview: true, // Enable preview mode
    );
  }
} 