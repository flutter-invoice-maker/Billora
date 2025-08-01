import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' show TableHelper;
import '../../features/invoice/domain/entities/invoice.dart';
import '../../features/invoice/domain/entities/invoice_item.dart';

@injectable
class PdfService {
  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Invoice ID: ${invoice.id}'),
            pw.Text('Customer: ${invoice.customerName}'),
            if (invoice.dueDate != null)
              pw.Text('Due: ${invoice.dueDate!.toLocal().toString().split(' ')[0]}'),
            pw.SizedBox(height: 16),
            TableHelper.fromTextArray(
              headers: ['Name', 'Description', 'Qty', 'Unit Price', 'Tax', 'Total'],
              data: invoice.items.map((item) => _itemRow(item)).toList(),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Subtotal: ${invoice.subtotal.toStringAsFixed(2)}'),
                    pw.Text('Tax: ${invoice.tax.toStringAsFixed(2)}'),
                    pw.Text('Total: ${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            if (invoice.note != null && invoice.note!.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 16),
                child: pw.Text('Note: ${invoice.note}', style: pw.TextStyle(color: PdfColors.grey)),
              ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  List<String> _itemRow(InvoiceItem item) => [
    item.name,
    item.description ?? '',
    item.quantity.toStringAsFixed(0),
    item.unitPrice.toStringAsFixed(2),
    item.tax.toStringAsFixed(2),
    item.total.toStringAsFixed(2),
  ];
} 