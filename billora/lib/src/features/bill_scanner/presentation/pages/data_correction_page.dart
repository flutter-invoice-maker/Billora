import 'package:flutter/material.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';

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
        title: const Text('Sửa Dữ Liệu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kiểm tra và sửa dữ liệu trích xuất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Store Name
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Tên Cửa Hàng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Amount
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: 'Tổng Tiền',
                border: OutlineInputBorder(),
                suffixText: 'đ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số Điện Thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa Chỉ',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            
            // Items
            if (_items.isNotEmpty) ...[
              const Text(
                'Danh Sách Sản Phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...(_items.asMap().entries.map((entry) => 
                _buildItemCard(entry.key, entry.value)
              )),
            ],
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _saveAndContinue,
                    child: const Text('Lưu & Tiếp Tục'),
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
                labelText: 'Mô tả sản phẩm',
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
                      labelText: 'Số lượng',
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
                      labelText: 'Đơn giá',
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
} 