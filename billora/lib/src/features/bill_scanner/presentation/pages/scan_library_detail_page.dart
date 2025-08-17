import 'package:flutter/material.dart';
import '../../domain/entities/scan_library_item.dart';
import 'scan_library_edit_page.dart';

class ScanLibraryDetailPage extends StatelessWidget {
  final ScanLibraryItem scanItem;

  const ScanLibraryDetailPage({super.key, required this.scanItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scanItem.fileName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanLibraryEditPage(scanItem: scanItem),
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildScanDetailsSection(),
              const SizedBox(height: 20),
              _buildMetadataSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scanItem.fileName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scanItem.scannedBill.storeName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scanItem.isProcessed ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scanItem.isProcessed ? Colors.green.shade300 : Colors.orange.shade300,
                        ),
                      ),
                      child: Text(
                        scanItem.isProcessed ? 'Processed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scanItem.isProcessed ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${scanItem.scannedBill.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
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

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info,
      children: [
        _buildInfoRow('File Name', scanItem.fileName),
        _buildInfoRow('Store Name', scanItem.scannedBill.storeName),
        _buildInfoRow('Total Amount', '\$${scanItem.scannedBill.totalAmount.toStringAsFixed(2)}'),
        _buildInfoRow('Scan Date', _formatDate(scanItem.scannedBill.scanDate)),
        _buildInfoRow('Created', _formatDate(scanItem.createdAt)),
        _buildInfoRow('Last Modified', _formatDate(scanItem.lastModifiedAt)),
        if (scanItem.customerId != null)
          _buildInfoRow('Customer ID', scanItem.customerId!),
        if (scanItem.invoiceId != null)
          _buildInfoRow('Invoice ID', scanItem.invoiceId!),
      ],
    );
  }

  Widget _buildScanDetailsSection() {
    final scanResult = scanItem.scannedBill.scanResult;
    return _buildSection(
      title: 'Scan Details',
      icon: Icons.scanner,
      children: [
        _buildInfoRow('OCR Provider', scanResult['ocrProvider']?.toString() ?? 'N/A'),
        _buildInfoRow('AI Model Version', scanResult['aiModelVersion']?.toString() ?? 'N/A'),
        _buildInfoRow('Data Validated', scanResult['isDataValidated'] == true ? 'Yes' : 'No'),
        _buildInfoRow('Data Complete', scanItem.scannedBill.isDataComplete ? 'Yes' : 'No'),
        if (scanResult['processingTimeMs'] != null)
          _buildInfoRow('Processing Time', '${scanResult['processingTimeMs'].toStringAsFixed(0)}ms'),
      ],
    );
  }

  Widget _buildMetadataSection() {
    final scanResult = scanItem.scannedBill.scanResult;
    final aiSuggestions = List<String>.from(scanResult['aiSuggestions'] ?? []);
    return _buildSection(
      title: 'Additional Information',
      icon: Icons.more_horiz,
      children: [
        if (scanItem.tags.isNotEmpty) ...[
          _buildInfoRow('Tags', scanItem.tags.join(', ')),
          const SizedBox(height: 16),
        ],
        if (scanItem.note != null) ...[
          _buildInfoRow('Note', scanItem.note!),
          const SizedBox(height: 16),
        ],
        if (aiSuggestions.isNotEmpty) ...[
          const Text(
            'AI Suggestions:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...aiSuggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 