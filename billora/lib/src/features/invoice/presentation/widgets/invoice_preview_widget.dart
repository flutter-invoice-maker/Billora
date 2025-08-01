import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/core/utils/localization_helper.dart';

class InvoicePreviewWidget extends StatelessWidget {
  final Invoice invoice;
  const InvoicePreviewWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    switch (invoice.templateId) {
      case 'template_a':
        return _buildTemplateA(context);
      case 'template_b':
        return _buildTemplateB(context);
      case 'template_c':
        return _buildTemplateC(context);
      default:
        return _buildTemplateA(context);
    }
  }

  Widget _buildTemplateA(BuildContext context) {
    return _InvoiceLayout(
      color: Colors.deepPurple,
      title: 'INVOICE (A)',
      invoice: invoice,
    );
  }

  Widget _buildTemplateB(BuildContext context) {
    return _InvoiceLayout(
      color: Colors.green,
      title: 'INVOICE (B)',
      invoice: invoice,
    );
  }

  Widget _buildTemplateC(BuildContext context) {
    return _InvoiceLayout(
      color: Colors.blue,
      title: 'INVOICE (C)',
      invoice: invoice,
    );
  }
}

class _InvoiceLayout extends StatelessWidget {
  final Color color;
  final String title;
  final Invoice invoice;
  const _InvoiceLayout({required this.color, required this.title, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(invoice.status.name, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Invoice #${invoice.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Customer: ${invoice.customerName}', style: const TextStyle(fontWeight: FontWeight.w500)),
        if (invoice.dueDate != null)
          Text('Due: ${invoice.dueDate!.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
        const Divider(height: 24),
        ...invoice.items.map((item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item.quantity.toStringAsFixed(0)} x ${LocalizationHelper.formatCurrency(item.unitPrice, context)}'),
              trailing: Text((item.total).toStringAsFixed(2)),
            )),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LocalizationHelper.getLocalizedString(context, 'invoiceSubtotal')),
            Text(invoice.subtotal.toStringAsFixed(2)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LocalizationHelper.getLocalizedString(context, 'invoiceTax')),
            Text(invoice.tax.toStringAsFixed(2)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(invoice.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        if (invoice.note != null && invoice.note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Note: ${invoice.note}', style: const TextStyle(color: Colors.grey)),
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(LocalizationHelper.getLocalizedString(context, 'close')),
          ),
        ),
      ],
    );
  }
} 