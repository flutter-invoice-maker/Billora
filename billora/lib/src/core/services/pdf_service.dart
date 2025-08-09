import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../features/invoice/domain/entities/invoice.dart';

@injectable
class PdfService {
  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();
    
    switch (invoice.templateId) {
      case 'modern_creative':
        _addModernCreativePage(pdf, invoice);
        break;
      case 'minimal_clean':
        _addMinimalCleanPage(pdf, invoice);
        break;
      case 'corporate_formal':
        _addCorporateFormalPage(pdf, invoice);
        break;
      case 'service_based':
        _addServiceBasedPage(pdf, invoice);
        break;
      case 'simple_receipt':
        _addSimpleReceiptPage(pdf, invoice);
        break;
      case 'professional_business':
      default:
        _addProfessionalBusinessPage(pdf, invoice);
        break;
    }
    
    return pdf.save();
  }

  void _addProfessionalBusinessPage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF1E3A8A),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'YOUR COMPANY NAME',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Professional Invoice Solutions',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      invoice.status.name.toUpperCase(),
                      style: pw.TextStyle(
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Invoice title and number
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _getInvoiceTypeTitle(invoice.templateId ?? ''),
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF1E3A8A),
                      ),
                    ),
                    pw.Text(
                      '#${invoice.id}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                // QR Code placeholder
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'QR\nCODE',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Customer and date info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFF8FAFC),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF64748B),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.customerName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1E293B),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Customer Address\nCity, State, ZIP\nCountry',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfInfoRow('Invoice Date', _formatDate(invoice.createdAt)),
                      pw.SizedBox(height: 12),
                      if (invoice.dueDate != null)
                        _buildPdfInfoRow('Due Date', _formatDate(invoice.dueDate!)),
                      pw.SizedBox(height: 12),
                      _buildPdfInfoRow('Payment Terms', 'Net 30'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Items table
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF1E3A8A),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'DESCRIPTION',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'RATE',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'AMOUNT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index.isEven ? const PdfColor.fromInt(0xFFF8FAFC) : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (item.description != null)
                              pw.Text(
                                item.description!,
                                style: pw.TextStyle(
                                  color: PdfColors.grey600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Totals section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 300,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfTotalRow('Subtotal', invoice.subtotal),
                      pw.SizedBox(height: 8),
                      _buildPdfTotalRow('Tax', invoice.tax),
                      pw.Divider(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF1E3A8A),
                            ),
                          ),
                          pw.Text(
                            '\$${invoice.total.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Footer with notes
            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFEF3C7),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFF59E0B)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTES',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF92400E),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice.note ?? '',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: const PdfColor.fromInt(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            pw.SizedBox(height: 24),
            
            // Promotional footer
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF1E3A8A),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Powered by Billora - Professional Invoice Management',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addModernCreativePage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Creative header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF7C3AED),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CREATIVE STUDIO',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          _getInvoiceTypeTitle(invoice.templateId ?? ''),
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        pw.Text(
                          '#${invoice.id}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(25),
                    ),
                    child: pw.Text(
                      invoice.status.name.toUpperCase(),
                      style: pw.TextStyle(
                        color: const PdfColor.fromInt(0xFF7C3AED),
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Info cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFF3E8FF),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFE9D5FF)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CLIENT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF7C3AED),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.customerName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFECFDF5),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFD1FAE5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DATE',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF059669),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          _formatDate(invoice.createdAt),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFFEF3C7),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DUE',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFFD97706),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.dueDate != null ? _formatDate(invoice.dueDate!) : 'On Receipt',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Creative items table
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE5E7EB), width: 2),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF111827),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Text(
                        'ITEM DESCRIPTION',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Text(
                        'RATE',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index.isEven ? const PdfColor.fromInt(0xFFF9FAFB) : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (item.description != null)
                              pw.Text(
                                item.description!,
                                style: pw.TextStyle(
                                  color: PdfColors.grey600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.normal),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: pw.Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.normal),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(20),
                        child: pw.Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                            color: const PdfColor.fromInt(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 32),

            // Creative totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF7C3AED),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'INVOICE TOTAL',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        '\$${invoice.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Subtotal: \$${invoice.subtotal.toStringAsFixed(2)} | Tax: \$${invoice.tax.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF3E8FF),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFE9D5FF)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTES',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF7C3AED),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.note ?? ''),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF111827),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Created with Billora - Where Creativity Meets Professionalism',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMinimalCleanPage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Minimal header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _getInvoiceTypeTitle(invoice.templateId ?? '').toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.normal,
                        color: const PdfColor.fromInt(0xFF374151),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '#${invoice.id}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey500,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFF374151), width: 2),
                  ),
                  child: pw.Text(
                    invoice.status.name.toUpperCase(),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.normal,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 60),

            // Clean info layout
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        invoice.customerName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.normal,
                          color: const PdfColor.fromInt(0xFF111827),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Customer Address\nCity, State ZIP\nCountry',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildMinimalPdfInfoRow('DATE', _formatDate(invoice.createdAt)),
                      pw.SizedBox(height: 16),
                      if (invoice.dueDate != null)
                        _buildMinimalPdfInfoRow('DUE DATE', _formatDate(invoice.dueDate!)),
                      pw.SizedBox(height: 16),
                      _buildMinimalPdfInfoRow('TERMS', 'Net 30'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 60),

            // Minimal table
            pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: const PdfColor.fromInt(0xFF374151), width: 2),
                      bottom: pw.BorderSide(color: const PdfColor.fromInt(0xFF374151), width: 1),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'DESCRIPTION',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'QTY',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'RATE',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'AMOUNT',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                ...invoice.items.map((item) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            if (item.description != null) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                item.description!,
                                style: pw.TextStyle(
                                  color: PdfColors.grey600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
            pw.SizedBox(height: 40),

            // Clean totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildMinimalPdfTotalRow('SUBTOTAL', invoice.subtotal),
                    pw.SizedBox(height: 12),
                    _buildMinimalPdfTotalRow('TAX', invoice.tax),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFF374151), width: 2),
                      ),
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 32),
                          pw.Text(
                            '\$${invoice.total.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTES',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      invoice.note ?? '',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text(
                'Powered by Billora - Minimal. Professional. Effective.',
                style: pw.TextStyle(
                  color: PdfColors.grey500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCorporateFormalPage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Corporate header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1F2937),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CORPORATE HEADQUARTERS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _getInvoiceTypeTitle(invoice.templateId ?? ''),
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        'Document #${invoice.id}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: _getPdfStatusColor(invoice.status),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      invoice.status.name.toUpperCase(),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Corporate info grid
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFF1F2937)),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RECIPIENT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1F2937),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.customerName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Department/Division\nInternal Code: INT-001',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFF1F2937)),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DOCUMENT DATE',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1F2937),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          _formatDate(invoice.createdAt),
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Fiscal Year: 2025\nQuarter: Q1',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFF1F2937)),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AUTHORIZATION',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1F2937),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'APPROVED',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF059669),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Manager: J. Smith\nRef: AUTH-2025-001',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Corporate table
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFF1F2937)),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF1F2937),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'ITEM DESCRIPTION',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'UNIT COST',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'TOTAL COST',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index.isEven ? const PdfColor.fromInt(0xFFF9FAFB) : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            if (item.description != null) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                item.description!,
                                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12),
                              ),
                            ],
                            pw.Text(
                              'SKU: ${item.name.replaceAll(' ', '').toUpperCase().substring(0, 3)}${index + 1}',
                              style: pw.TextStyle(
                                color: PdfColors.grey500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Corporate summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 350,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFF1F2937)),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF1F2937),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              'FINANCIAL SUMMARY',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Column(
                          children: [
                            _buildPdfCorporateRow('Net Amount:', invoice.subtotal),
                            pw.SizedBox(height: 8),
                            _buildPdfCorporateRow('Tax Amount:', invoice.tax),
                            pw.SizedBox(height: 8),
                            _buildPdfCorporateRow('Processing Fee:', 0.00),
                            pw.Divider(),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'TOTAL AMOUNT:',
                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  '\$${invoice.total.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFF1F2937)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INTERNAL NOTES',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF1F2937),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.note ?? ''),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1F2937),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Enterprise Solution by Billora - Streamlining Corporate Operations',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addServiceBasedPage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Service header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF0F766E),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SERVICE PROVIDER',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          _getInvoiceTypeTitle(invoice.templateId ?? ''),
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Service ID: #${invoice.id}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          invoice.status.name.toUpperCase(),
                          style: pw.TextStyle(
                            color: const PdfColor.fromInt(0xFF0F766E),
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '24/7 Support Available',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Service info
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFF0FDFA),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: const PdfColor.fromInt(0xFF5EEAD4)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CLIENT INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF0F766E),
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          invoice.customerName,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Client ID: CLI-${invoice.customerName.hashCode.abs().toString().substring(0, 4)}\nService Level: Premium\nAccount Manager: Sarah Johnson',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFFECFDF5),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: const PdfColor.fromInt(0xFFA7F3D0)),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'SERVICE PERIOD',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF059669),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              _formatDate(invoice.createdAt),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFFFEF3C7),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'TOTAL HOURS',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFFD97706),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              '${invoice.items.fold(0.0, (sum, item) => sum + item.quantity)} hrs',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Service items table
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFF0F766E), width: 2),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF0F766E),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'SERVICE DESCRIPTION',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'HOURS',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'RATE/HR',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Text(
                        'SUBTOTAL',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index.isEven ? const PdfColor.fromInt(0xFFF0FDFA) : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (item.description != null)
                              pw.Text(
                                item.description!,
                                style: pw.TextStyle(
                                  color: PdfColors.grey600,
                                  fontSize: 12,
                                ),
                              ),
                            pw.Text(
                              'Service Code: SVC-${(index + 1).toString().padLeft(3, '0')}',
                              style: pw.TextStyle(
                                color: PdfColors.grey500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '${item.quantity}h',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.normal),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.unitPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.normal),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Text(
                          '\$${item.total.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                            color: const PdfColor.fromInt(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Service totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF0F766E),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SERVICE TOTAL',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        '\$${invoice.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Net: \$${invoice.subtotal.toStringAsFixed(2)} + Tax: \$${invoice.tax.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Quality Guaranteed',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF0FDFA),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFF5EEAD4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SERVICE NOTES',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF0F766E),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.note ?? ''),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF0F766E),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Powered by Billora - Excellence in Service Management',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSimpleReceiptPage(pw.Document pdf, Invoice invoice) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Receipt header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF6B7280),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'OFFICIAL RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    _getInvoiceTypeTitle(invoice.templateId ?? ''),
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Receipt #${invoice.id}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Receipt details
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFD1D5DB)),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'RECEIVED FROM:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF6B7280),
                        ),
                      ),
                      pw.Text(
                        invoice.customerName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DATE:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF6B7280),
                        ),
                      ),
                      pw.Text(
                        _formatDate(invoice.createdAt),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'PAYMENT METHOD:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF6B7280),
                        ),
                      ),
                      pw.Text(
                        'Cash/Card',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Items list
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFD1D5DB)),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF9FAFB),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        'DESCRIPTION',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        'AMOUNT',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...invoice.items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        item.name,
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        item.quantity.toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Total section
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF6B7280),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  if (invoice.tax > 0) ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Subtotal:',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                        ),
                        pw.Text(
                          '\$${invoice.subtotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Tax:',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                        ),
                        pw.Text(
                          '\$${invoice.tax.toStringAsFixed(2)}',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                  ],
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL PAID:',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '\$${invoice.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF9FAFB),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTES:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF6B7280),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.note ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 20),
            pw.Text(
              'PAYMENT RECEIVED - THANK YOU',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF059669),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Transaction ID: TXN-${invoice.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Powered by Billora - Simple & Secure Receipts',
              style: pw.TextStyle(
                color: PdfColors.grey500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getInvoiceTypeTitle(String templateId) {
    switch (templateId) {
      case 'professional_business':
        return 'COMMERCIAL INVOICE';
      case 'modern_creative':
        return 'SALES INVOICE';
      case 'minimal_clean':
        return 'PROFORMA INVOICE';
      case 'corporate_formal':
        return 'INTERNAL TRANSFER NOTE';
      case 'service_based':
        return 'TIMESHEET INVOICE';
      case 'simple_receipt':
        return 'PAYMENT RECEIPT';
      default:
        return 'INVOICE';
    }
  }

  PdfColor _getPdfStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return PdfColors.grey;
      case InvoiceStatus.sent:
        return PdfColors.blue;
      case InvoiceStatus.paid:
        return PdfColors.green;
      case InvoiceStatus.overdue:
        return PdfColors.red;
      case InvoiceStatus.cancelled:
        return PdfColors.orange;
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTotalRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildMinimalPdfInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildMinimalPdfTotalRow(String label, double amount) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey600,
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfCorporateRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
