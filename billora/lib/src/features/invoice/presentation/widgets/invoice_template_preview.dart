import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_print_templates.dart';

class InvoiceTemplatePreview extends StatelessWidget {
  final String templateId;
  final String customerName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? note;

  const InvoiceTemplatePreview({
    super.key,
    required this.templateId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    // Create invoice object for preview
    final previewInvoice = Invoice(
      id: 'PREVIEW',
      customerId: 'CUST-PREVIEW',
      customerName: customerName.isNotEmpty ? customerName : 'Customer Name',
      items: items.isNotEmpty ? items : [
        InvoiceItem(
          id: '1',
          name: 'Sample Item',
          description: 'Sample description',
          quantity: 1,
          unitPrice: 100.0,
          tax: 10.0,
          total: 110.0,
          productId: 'PROD-1',
        ),
      ],
      subtotal: subtotal > 0 ? subtotal : 100.0,
      tax: tax > 0 ? tax : 10.0,
      total: total > 0 ? total : 110.0,
      status: status,
      createdAt: createdAt,
      dueDate: dueDate,
      note: note,
      templateId: templateId,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.preview, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Template Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Template: ${_getTemplateName(templateId)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Template preview content
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width < 400 ? 180 : 300, // Tăng kích thước
              height: MediaQuery.of(context).size.width < 400 ? 250 : 420, // Tăng kích thước
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Transform.scale(
                  scale: 0.8, // Scale 80% để hóa đơn lấp đầy container
                  child: SizedBox(
                    width: 595,
                    height: 842, // Quay lại kích thước A4 gốc
                    child: InvoicePrintTemplates.getTemplateById(
                      templateId, 
                      context, 
                      previewInvoice,
                      isPreview: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTemplateName(String templateId) {
    switch (templateId) {
      case 'template_a':
        return 'Modern Business';
      case 'template_b':
        return 'Creative Studio';
      case 'template_c':
        return 'Minimal Classic';
      case 'template_d':
        return 'Corporate Pro';
      default:
        return 'Modern Business';
    }
  }
} 