import 'package:flutter/material.dart';
import '../../domain/entities/bill_line_item.dart';

class ExtractedDataWidget extends StatelessWidget {
  final String storeName;
  final double totalAmount;
  final String? date;
  final String? phone;
  final String? address;
  final List<BillLineItem>? items;

  const ExtractedDataWidget({
    super.key,
    required this.storeName,
    required this.totalAmount,
    this.date,
    this.phone,
    this.address,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dữ Liệu Trích Xuất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildDataRow('Tên Cửa Hàng', storeName),
            _buildDataRow('Tổng Tiền', '${totalAmount.toStringAsFixed(0)} đ'),
            if (date != null) _buildDataRow('Ngày', date!),
            if (phone != null) _buildDataRow('Số Điện Thoại', phone!),
            if (address != null) _buildDataRow('Địa Chỉ', address!),
            
            if (items != null && items!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Danh Sách Sản Phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items!.map((item) => _buildItemRow(item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BillLineItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.description),
          ),
          Expanded(
            flex: 1,
            child: Text('x${item.quantity.toStringAsFixed(0)}'),
          ),
          Expanded(
            flex: 2,
            child: Text('${item.totalPrice.toStringAsFixed(0)} đ'),
          ),
        ],
      ),
    );
  }
} 