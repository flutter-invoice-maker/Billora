import 'package:flutter/material.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/entities/scan_result.dart';

class DataCorrectionPage extends StatefulWidget {
  final ScannedBill scannedBill;
  
  const DataCorrectionPage({super.key, required this.scannedBill});
  
  @override
  State<DataCorrectionPage> createState() => _DataCorrectionPageState();
}

class _DataCorrectionPageState extends State<DataCorrectionPage> {
  late TextEditingController _storeNameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late List<BillLineItem> _items;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: widget.scannedBill.storeName);
    _totalAmountController = TextEditingController(text: widget.scannedBill.totalAmount.toString());
    _phoneController = TextEditingController(text: widget.scannedBill.phone ?? '');
    _addressController = TextEditingController(text: widget.scannedBill.address ?? '');
    _items = List.from(widget.scannedBill.items ?? []);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _totalAmountController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Review'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndContinue,
            tooltip: 'Confirm and continue',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with scan info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.document_scanner, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Scanned Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OCR Provider: ${widget.scannedBill.scanResult.ocrProvider}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Confidence: ${_getConfidenceText(widget.scannedBill.scanResult.confidence)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Review and correct extracted data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Store Name
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Amount
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'đ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 20),
            
            // Items Section
            if (_items.isNotEmpty) ...[
              Text(
                'Line Items (${_items.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._items.asMap().entries.map((entry) => _buildItemCard(entry.key, entry.value)),
              const SizedBox(height: 16),
            ],
            
            // Raw OCR Text (collapsible)
            ExpansionTile(
              title: const Text('Raw OCR Text'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    widget.scannedBill.scanResult.rawText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Confirm & Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, BillLineItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(
                labelText: 'Product Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _items[index] = item.copyWith(description: value);
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _items[index] = item.copyWith(quantity: quantity);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      suffixText: 'đ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final unitPrice = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _items[index] = item.copyWith(unitPrice: unitPrice);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndContinue() {
    final correctedBill = widget.scannedBill.copyWith(
      storeName: _storeNameController.text,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      items: _items,
    );
    
    Navigator.pop(context, correctedBill);
  }

  String _getConfidenceText(ScanConfidence confidence) {
    switch (confidence) {
      case ScanConfidence.high:
        return 'High';
      case ScanConfidence.medium:
        return 'Medium';
      case ScanConfidence.low:
        return 'Low';
      case ScanConfidence.unknown:
        return 'Unknown';
    }
  }
}