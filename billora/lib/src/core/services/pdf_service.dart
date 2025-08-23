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

  // =============== TEMPLATE 1: PROFESSIONAL BUSINESS ===============
  void _addProfessionalBusinessPage(pw.Document pdf, Invoice invoice) {
    final firstItem = invoice.items.isNotEmpty ? invoice.items.first : null;
    final companyName = firstItem?.companyOrShopName?.isNotEmpty == true ? firstItem!.companyOrShopName! : 'COMPANY NAME';
    final addressLines = <String>[];
    if (firstItem?.companyAddress?.isNotEmpty == true) addressLines.add(firstItem!.companyAddress!);
    if (firstItem?.companyPhone?.isNotEmpty == true) addressLines.add('Phone: ${firstItem!.companyPhone}');
    if (firstItem?.companyEmail?.isNotEmpty == true) addressLines.add('Email: ${firstItem!.companyEmail}');
    if (firstItem?.companyWebsite?.isNotEmpty == true) addressLines.add('Website: ${firstItem!.companyWebsite}');
    final companyAddressBlock = addressLines.isNotEmpty
        ? addressLines.join('\n')
        : '123 Business Street\nCity, State 12345\nPhone: (555) 123-4567';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with company and QR
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 8),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        companyAddressBlock,
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 32),
                pw.Column(
                  children: [
                    _buildQr('invoice:${invoice.id}', 100),
                    pw.SizedBox(height: 8),
                    pw.Text('Scan for Details', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                )
              ],
            ),

            pw.SizedBox(height: 40),

            // Title and status
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _getInvoiceTypeTitle(invoice.templateId ?? ''),
                      style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
                    ),
                    pw.Text('No. ${invoice.id}', style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey600)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                  child: pw.Text(
                    invoice.status.name.toUpperCase(),
                    style: pw.TextStyle(color: PdfColors.black, fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                )
              ],
            ),

            pw.SizedBox(height: 40),

            // Bill to + info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      pw.SizedBox(height: 12),
                      pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Customer Address\nCity, State, ZIP\nCountry', style: const pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfInfoRow('Invoice Date', _formatDate(invoice.createdAt)),
                      pw.SizedBox(height: 16),
                      if (invoice.dueDate != null) _buildPdfInfoRow('Due Date', _formatDate(invoice.dueDate!)),
                      pw.SizedBox(height: 16),
                      _buildPdfInfoRow('Payment Terms', 'Net 30'),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            // Items table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.black),
                  children: [
                    _cellHeader('DESCRIPTION', 16, align: pw.TextAlign.left),
                    _cellHeader('QTY', 16),
                    _cellHeader('RATE', 16),
                    _cellHeader('AMOUNT', 16),
                  ],
                ),
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: index.isEven ? const PdfColor.fromInt(0xFFFAFAFA) : PdfColors.white),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            if (item.description != null) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(item.description!, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                            ],
                          ],
                        ),
                      ),
                      _cellBody(item.quantity.toString()),
                      _cellBody('\$${item.unitPrice.toStringAsFixed(2)}'),
                      _cellBody('\$${item.total.toStringAsFixed(2)}', isBold: true),
                    ],
                  );
                })
              ],
            ),

            pw.SizedBox(height: 32),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 300,
                  child: pw.Column(
                    children: [
                      _buildPdfTotalRow('Subtotal', invoice.subtotal),
                      pw.SizedBox(height: 8),
                      _buildPdfTotalRow('Tax', invoice.tax),
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 12),
                        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1))),
                        padding: const pw.EdgeInsets.symmetric(vertical: 12),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                            pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 32),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('NOTES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 32),
            pw.Container(
              decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1))),
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              child: pw.Center(
                child: pw.Text('Powered by Billora - Professional Invoice Management', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== TEMPLATE 2: MODERN CREATIVE ===============
  void _addModernCreativePage(pw.Document pdf, Invoice invoice) {
    final companyOrShopName = invoice.items.isNotEmpty ? (invoice.items.first.companyOrShopName ?? '') : '';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        pw.Container(width: 16, height: 16, color: PdfColors.black),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          companyOrShopName.isNotEmpty ? companyOrShopName : 'CREATIVE STUDIO',
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                        ),
                      ]),
                      pw.SizedBox(height: 12),
                      pw.Text(_getInvoiceTypeTitle(invoice.templateId ?? ''), style: const pw.TextStyle(fontSize: 16, color: PdfColors.black)),
                      pw.Text('#${invoice.id}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                      child: pw.Text(invoice.status.name.toUpperCase(), style: const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
                    )
                  ],
                )
              ],
            ),

            pw.SizedBox(height: 80),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 16),
                      pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.normal)),
                      pw.SizedBox(height: 8),
                      pw.Text('Customer Address\nCity, State ZIP\nCountry', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildMinimalPdfInfoRow('DATE', _formatDate(invoice.createdAt)),
                      pw.SizedBox(height: 16),
                      if (invoice.dueDate != null) _buildMinimalPdfInfoRow('DUE DATE', _formatDate(invoice.dueDate!)),
                      pw.SizedBox(height: 16),
                      _buildMinimalPdfInfoRow('TERMS', 'Net 30'),
                    ],
                  ),
                )
              ],
            ),

            pw.SizedBox(height: 80),

            pw.Column(children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: const pw.BorderSide(color: PdfColors.black, width: 2),
                    bottom: const pw.BorderSide(color: PdfColors.black, width: 1),
                  ),
                ),
                child: pw.Row(children: [
                  pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('RATE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('AMOUNT', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                ]),
              ),
              ...invoice.items.map((item) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 24),
                decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
                child: pw.Row(children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.name, style: const pw.TextStyle(fontSize: 16)),
                        if (item.description != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(item.description!, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                        ],
                      ],
                    ),
                  ),
                  pw.Expanded(child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 16))),
                  pw.Expanded(child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 16))),
                  pw.Expanded(child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                ]),
              )),
            ]),

            pw.SizedBox(height: 60),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  _buildMinimalPdfTotalRow('SUBTOTAL', invoice.subtotal),
                  pw.SizedBox(height: 16),
                  _buildMinimalPdfTotalRow('TAX', invoice.tax),
                  pw.SizedBox(height: 32),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                    child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                      pw.Text('TOTAL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 40),
                      pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    ]),
                  )
                ])
              ],
            ),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 80),
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('NOTES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 12),
                  pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 16)),
                ]),
              )
            ],

            pw.SizedBox(height: 60),
            pw.Center(child: pw.Text('Powered by Billora - Minimal. Professional. Effective.', style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  // =============== TEMPLATE 3: MINIMAL CLEAN ===============
  void _addMinimalCleanPage(pw.Document pdf, Invoice invoice) {
    final companyOrShopName = invoice.items.isNotEmpty ? (invoice.items.first.companyOrShopName ?? '') : '';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(50),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(
                    companyOrShopName.isNotEmpty
                        ? companyOrShopName
                        : _getInvoiceTypeTitle(invoice.templateId ?? '').toUpperCase(),
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('#${invoice.id}', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey600)),
                ]),
                pw.Column(children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                    child: _buildQr('invoice:${invoice.id}', 80),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                    child: pw.Text(invoice.status.name.toUpperCase(), style: const pw.TextStyle(fontSize: 12)),
                  ),
                ])
              ],
            ),

            pw.SizedBox(height: 60),

            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('BILL TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                  pw.SizedBox(height: 16),
                  pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 24, color: PdfColors.black)),
                  pw.SizedBox(height: 8),
                  pw.Text('Customer Address\nCity, State ZIP\nCountry', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                ]),
              ),
              pw.Expanded(
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  _buildMinimalPdfInfoRow('DATE', _formatDate(invoice.createdAt)),
                  pw.SizedBox(height: 16),
                  if (invoice.dueDate != null) _buildMinimalPdfInfoRow('DUE DATE', _formatDate(invoice.dueDate!)),
                  pw.SizedBox(height: 16),
                  _buildMinimalPdfInfoRow('TERMS', 'Net 30'),
                ]),
              ),
            ]),

            pw.SizedBox(height: 60),

            pw.Column(children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 2),
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                  ),
                ),
                child: pw.Row(children: [
                  pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('RATE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(child: pw.Text('AMOUNT', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                ]),
              ),
              ...invoice.items.map((item) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1))),
                child: pw.Row(children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text(item.name, style: const pw.TextStyle(fontSize: 16)),
                      if (item.description != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(item.description!, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                      ],
                    ]),
                  ),
                  pw.Expanded(child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 16))),
                  pw.Expanded(child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 16))),
                  pw.Expanded(child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                ]),
              )),
            ]),

            pw.SizedBox(height: 40),

            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                _buildMinimalPdfTotalRow('SUBTOTAL', invoice.subtotal),
                pw.SizedBox(height: 12),
                _buildMinimalPdfTotalRow('TAX', invoice.tax),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                  child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 32),
                    pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ]),
                ),
              ])
            ]),

            if (invoice.note != null && invoice.note!.isNotEmpty) ...[
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('NOTES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 12),
                  pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 16)),
                ]),
              ),
            ],

            pw.SizedBox(height: 40),
            pw.Center(child: pw.Text('Powered by Billora - Minimal. Professional. Effective.', style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  // =============== TEMPLATE 4: CORPORATE FORMAL ===============
  void _addCorporateFormalPage(pw.Document pdf, Invoice invoice) {
    final companyOrShopName = invoice.items.isNotEmpty ? (invoice.items.first.companyOrShopName ?? '') : '';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 3)),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(companyOrShopName.isNotEmpty ? companyOrShopName : 'CORPORATE HEADQUARTERS', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(_getInvoiceTypeTitle(invoice.templateId ?? ''), style: const pw.TextStyle(fontSize: 16)),
                pw.Text('Document #${invoice.id}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: PdfColors.black,
                  child: pw.Text(
                    invoice.status.name.toUpperCase(),
                    style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildQr('invoice:${invoice.id}', 80),
              ])
            ]),
          ),

          pw.SizedBox(height: 40),

          pw.Row(children: [
            pw.Expanded(child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('RECIPIENT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 8),
                pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Department/Division\nInternal Code: INT-001', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ]),
            )),
            pw.SizedBox(width: 20),
            pw.Expanded(child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('DOCUMENT DATE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 8),
                pw.Text(_formatDate(invoice.createdAt), style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 4),
                pw.Text('Fiscal Year: 2025\nQuarter: Q1', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ]),
            )),
            pw.SizedBox(width: 20),
            pw.Expanded(child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('AUTHORIZATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 8),
                pw.Text('APPROVED', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 4),
                pw.Text('Manager: J. Smith\nRef: AUTH-2025-001', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ]),
            )),
          ]),

          pw.SizedBox(height: 40),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.black),
                children: [
                  _cellHeader('ITEM DESCRIPTION', 14, align: pw.TextAlign.left),
                  _cellHeader('QTY', 14),
                  _cellHeader('UNIT COST', 14),
                  _cellHeader('TOTAL COST', 14),
                ],
              ),
              ...invoice.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: index.isEven ? const PdfColor.fromInt(0xFFF5F5F5) : PdfColors.white),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        if (item.description != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(item.description!, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        ],
                      ]),
                    ),
                    _cellBody(item.quantity.toString()),
                    _cellBody('\$${item.unitPrice.toStringAsFixed(2)}'),
                    _cellBody('\$${item.total.toStringAsFixed(2)}', isBold: true),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 32),

          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
            pw.Container(
              width: 400,
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
              child: pw.Column(children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  color: PdfColors.black,
                  width: double.infinity,
                  child: pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14), textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(children: [
                    _buildPdfCorporateRow('Net Amount:', invoice.subtotal),
                    pw.SizedBox(height: 8),
                    _buildPdfCorporateRow('Tax Amount:', invoice.tax),
                    pw.SizedBox(height: 8),
                    _buildPdfCorporateRow('Processing Fee:', 0.00),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 2))),
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('TOTAL AMOUNT:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            pw.SizedBox(height: 32),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('INTERNAL NOTES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 8),
                pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 14)),
              ]),
            ),
          ],

          pw.SizedBox(height: 32),
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            color: PdfColors.black,
            child: pw.Center(child: pw.Text('Enterprise Solution by Billora - Streamlining Corporate Operations', style: pw.TextStyle(color: PdfColors.white, fontSize: 12))),
          )
        ]),
      ),
    );
  }

  // =============== TEMPLATE 5: SERVICE BASED ===============
  void _addServiceBasedPage(pw.Document pdf, Invoice invoice) {
    final companyOrShopName = invoice.items.isNotEmpty ? (invoice.items.first.companyOrShopName ?? '') : '';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Row(children: [
                  pw.Container(width: 12, height: 30, color: PdfColors.black),
                  pw.SizedBox(width: 12),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(companyOrShopName.isNotEmpty ? companyOrShopName : 'SERVICE PROVIDER', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(_getInvoiceTypeTitle(invoice.templateId ?? ''), style: const pw.TextStyle(fontSize: 16)),
                  ])
                ]),
                pw.SizedBox(height: 8),
                pw.Text('Service ID: #${invoice.id}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
              ]),
            ),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
                child: pw.Text(invoice.status.name.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                child: _buildQr('invoice:${invoice.id}', 70),
              ),
              pw.SizedBox(height: 8),
              pw.Text('24/7 Support Available', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ])
          ]),

          pw.SizedBox(height: 40),

          pw.Row(children: [
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('CLIENT INFORMATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.SizedBox(height: 16),
                  pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Client ID: CLI-${invoice.customerName.hashCode.abs().toString().substring(0, 4)}\nService Level: Premium\nAccount Manager: Sarah Johnson', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                ]),
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('SERVICE PERIOD', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 8),
                    pw.Text(_formatDate(invoice.createdAt), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('TOTAL HOURS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 8),
                    pw.Text('${invoice.items.fold(0.0, (sum, item) => sum + item.quantity)} hrs', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                ),
              ]),
            ),
          ]),

          pw.SizedBox(height: 40),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.black),
                children: [
                  _cellHeader('SERVICE DESCRIPTION', 14, align: pw.TextAlign.left),
                  _cellHeader('HOURS', 14),
                  _cellHeader('RATE/HR', 14),
                  _cellHeader('SUBTOTAL', 14),
                ],
              ),
              ...invoice.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: index.isEven ? const PdfColor.fromInt(0xFFFAFAFA) : PdfColors.white),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Row(children: [
                          pw.Container(width: 4, height: 4, color: PdfColors.black),
                          pw.SizedBox(width: 8),
                          pw.Expanded(child: pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))),
                        ]),
                        if (item.description != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Padding(padding: const pw.EdgeInsets.only(left: 16), child: pw.Text(item.description!, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12))),
                        ],
                      ]),
                    ),
                    _cellBody('${item.quantity}h'),
                    _cellBody('\$${item.unitPrice.toStringAsFixed(2)}'),
                    _cellBody('\$${item.total.toStringAsFixed(2)}', isBold: true),
                  ],
                );
              })
            ],
          ),

          pw.SizedBox(height: 32),

          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              color: PdfColors.black,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('SERVICE TOTAL', style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Net: \$${invoice.subtotal.toStringAsFixed(2)} + Tax: \$${invoice.tax.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
              ]),
            ),
          ]),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            pw.SizedBox(height: 32),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('SERVICE NOTES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 8),
                pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 14)),
              ]),
            ),
          ],

          pw.SizedBox(height: 32),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 12),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1))),
            child: pw.Center(child: pw.Text('Powered by Billora - Excellence in Service Management', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12))),
          )
        ]),
      ),
    );
  }

  // =============== TEMPLATE 6: SIMPLE RECEIPT ===============
  void _addSimpleReceiptPage(pw.Document pdf, Invoice invoice) {
    final companyOrShopName = invoice.items.isNotEmpty ? (invoice.items.first.companyOrShopName ?? '') : '';

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
            child: pw.Column(children: [
              pw.Text(companyOrShopName.isNotEmpty ? companyOrShopName : 'OFFICIAL RECEIPT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(_getInvoiceTypeTitle(invoice.templateId ?? ''), style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Receipt #${invoice.id}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ]),
          ),

          pw.SizedBox(height: 24),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
            child: pw.Column(children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('RECEIVED FROM:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ]),
              pw.SizedBox(height: 12),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('DATE:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.Text(_formatDate(invoice.createdAt), style: const pw.TextStyle(fontSize: 14)),
              ]),
              pw.SizedBox(height: 12),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('PAYMENT METHOD:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.Text('Cash/Card', style: const pw.TextStyle(fontSize: 14)),
              ]),
            ]),
          ),

          pw.SizedBox(height: 20),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cellHeader('DESCRIPTION', 12, align: pw.TextAlign.left, color: PdfColors.black, textColor: PdfColors.black),
                  _cellHeader('QTY', 12, color: PdfColors.black, textColor: PdfColors.black),
                  _cellHeader('AMOUNT', 12, color: PdfColors.black, textColor: PdfColors.black),
                ],
              ),
              ...invoice.items.map((item) => pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 14))),
                pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 14))),
                pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
              ])),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
            child: pw.Column(children: [
              if (invoice.tax > 0) ...[
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(color: PdfColors.black, fontSize: 14)),
                  pw.Text('\$${invoice.subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.black, fontSize: 14)),
                ]),
                pw.SizedBox(height: 8),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('Tax:', style: const pw.TextStyle(color: PdfColors.black, fontSize: 14)),
                  pw.Text('\$${invoice.tax.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.black, fontSize: 14)),
                ]),
                pw.SizedBox(height: 12),
              ],
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL PAID:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ]),
            ]),
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('NOTES:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 4),
                pw.Text(invoice.note ?? '', style: const pw.TextStyle(fontSize: 12)),
              ]),
            ),
          ],

          pw.SizedBox(height: 20),
          pw.Text('PAYMENT RECEIVED - THANK YOU', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
          pw.SizedBox(height: 8),
          pw.Text('Transaction ID: TXN-${invoice.id}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          pw.Text('Powered by Billora - Simple & Secure Receipts', style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10)),
        ]),
      ),
    );
  }

  // ===================== HELPERS =====================

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


  pw.Widget _buildQr(String data, double size) {
    return pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: data,
      width: size,
      height: size,
      drawText: false,
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        ),
        pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 14))),
      ],
    );
  }

  pw.Widget _buildPdfTotalRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.Text('\$${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildMinimalPdfInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
      ],
    );
  }

  pw.Widget _buildMinimalPdfTotalRow(String label, double amount) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(width: 140, child: pw.Text(label, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700))),
        pw.SizedBox(width: 20),
        pw.Text('\$${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildPdfCorporateRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.Text('\$${amount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  pw.Widget _cellHeader(String text, double pad, {pw.TextAlign align = pw.TextAlign.center, PdfColor color = PdfColors.black, PdfColor textColor = PdfColors.white}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(pad),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(color: textColor, fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    );
  }

  pw.Widget _cellBody(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 14, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }
}
