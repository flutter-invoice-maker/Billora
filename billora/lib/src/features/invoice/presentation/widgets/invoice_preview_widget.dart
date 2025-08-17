import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/presentation/widgets/invoice_print_templates.dart';
import 'package:billora/src/features/invoice/presentation/widgets/ai_summary_card.dart';
import 'package:billora/src/features/invoice/presentation/widgets/qr_code_widget.dart';

class InvoicePreviewWidget extends StatelessWidget {
  final Invoice invoice;
  const InvoicePreviewWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive scale for A4 format (595x842)
    // Keep aspect ratio but fit within screen bounds
    final maxWidth = screenSize.width * 0.8; // 80% of screen width
    final maxHeight = screenSize.height * 0.6; // 60% of screen height
    
    final scaleX = maxWidth / 595;
    final scaleY = maxHeight / 842;
    final scale = scaleX < scaleY ? scaleX : scaleY; // Use smaller scale to fit both dimensions
    
    final scaledWidth = 595 * scale;
    final scaledHeight = 842 * scale;
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice preview with responsive scaling
            Center(
              child: Container(
                width: scaledWidth,
                height: scaledHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 595,
                      height: 842,
                      child: InvoicePrintTemplates.getTemplateById(
                        invoice.templateId ?? 'professional_business',
                        context,
                        invoice,
                        isPreview: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Summary Card
            AISummaryCard(
              invoice: invoice,
              primaryColor: primaryColor,
              onRetry: () {
                // Retry logic for AI analysis - will be implemented when AI service is enhanced
              },
            ),
            
            const SizedBox(height: 24),
            
            // QR Code Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'QR Code',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: InvoiceQRCodeWidget(
                        invoice: invoice,
                        size: 200,
                        showLabel: true,
                        labelText: 'Scan to view invoice details',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Copy QR data functionality - will be implemented when clipboard service is added
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('QR data copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Regenerate QR functionality - will be implemented when QR generation service is enhanced
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('QR code regenerated')),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
    );
  }
} 