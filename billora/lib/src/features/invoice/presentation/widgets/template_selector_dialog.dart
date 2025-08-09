import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice_item.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_print_templates.dart';

class TemplateSelectorDialog extends StatelessWidget {
  final String currentTemplateId;
  final Function(String) onTemplateSelected;
  final Color primaryColor;

  const TemplateSelectorDialog({
    super.key,
    required this.currentTemplateId,
    required this.onTemplateSelected,
    required this.primaryColor,
  });

  static const List<Map<String, dynamic>> _templates = [
    {
      'id': 'professional_business',
      'name': 'Professional Business',
      'description': 'For Commercial, Tax, Electronic, VAT invoices',
      'icon': Icons.business_center,
      'color': Color(0xFF1E3A8A),
    },
    {
      'id': 'modern_creative',
      'name': 'Modern Creative',
      'description': 'For Sales, Self-billing invoices',
      'icon': Icons.palette,
      'color': Color(0xFF7C3AED),
    },
    {
      'id': 'minimal_clean',
      'name': 'Minimal Clean',
      'description': 'For Proforma, Credit/Debit notes',
      'icon': Icons.style,
      'color': Color(0xFF374151),
    },
    {
      'id': 'corporate_formal',
      'name': 'Corporate Formal',
      'description': 'For Internal transfers, consignment notes',
      'icon': Icons.account_balance,
      'color': Color(0xFF1F2937),
    },
    {
      'id': 'service_based',
      'name': 'Service Based',
      'description': 'For Timesheet, transport receipts',
      'icon': Icons.miscellaneous_services,
      'color': Color(0xFF0F766E),
    },
    {
      'id': 'simple_receipt',
      'name': 'Simple Receipt',
      'description': 'For Bank fees, stamps/tickets/cards',
      'icon': Icons.receipt_long,
      'color': Color(0xFF6B7280),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Giảm padding
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // Giảm từ 95% xuống 90%
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Giảm từ 98% xuống 80%
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.description, color: primaryColor, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Choose Invoice Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Template Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  int crossAxisCount;
                  double childAspectRatio;
                  
                  if (screenWidth < 600) {
                    crossAxisCount = 1;
                    childAspectRatio = 0.5; // Giảm từ 0.8 xuống 0.5 để card cao hơn
                  } else if (screenWidth < 900) {
                    crossAxisCount = 2;
                    childAspectRatio = 0.5;
                  } else {
                    crossAxisCount = 3;
                    childAspectRatio = 0.5;
                  }
                  
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8, // Giảm từ 12 xuống 8
                      mainAxisSpacing: 8, // Giảm từ 12 xuống 8
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      final isSelected = currentTemplateId == template['id'];
                      final templateColor = template['color'] as Color;
                      
                      return InkWell(
                        onTap: () {
                          onTemplateSelected(template['id']);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? templateColor : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? templateColor.withValues(alpha: 0.05) : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Template header
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? templateColor : Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      template['icon'] as IconData,
                                      color: isSelected ? Colors.white : templateColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            template['name'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelected ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            template['description'] ?? '',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Template preview - thu nhỏ đáng kể
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6), // Giảm từ 12 xuống 6
                                  child: _buildTemplatePreview(template['id'] as String),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select Template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(String templateId) {
    // Create a sample invoice for preview
    final sampleInvoice = Invoice(
      id: 'INV-001',
      customerId: 'CUST-001',
      customerName: 'John Doe',
      items: [
        InvoiceItem(
          id: '1',
          name: 'Sample Item',
          description: 'Sample description',
          quantity: 2,
          unitPrice: 50.0,
          tax: 10.0,
          total: 110.0,
          productId: 'PROD-001',
        ),
      ],
      subtotal: 100.0,
      tax: 10.0,
      total: 110.0,
      status: InvoiceStatus.draft,
      createdAt: DateTime.now(),
      templateId: templateId,
    );

    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Transform.scale(
              scale: 0.6, // Scale 60% để hóa đơn lấp đầy card
              child: SizedBox(
                width: 595,
                height: 842, // Quay lại kích thước A4 gốc
                child: InvoicePrintTemplates.getTemplateById(
                  templateId, 
                  context, 
                  sampleInvoice,
                  isPreview: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 