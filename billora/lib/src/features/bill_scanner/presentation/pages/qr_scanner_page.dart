import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/presentation/pages/invoice_form_page.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';
import 'package:billora/src/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = false;
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _handleManualInput() {
    final input = _manualInputController.text.trim();
    if (input.isNotEmpty) {
      _handleScannedQR(input);
    }
  }

  void _handleScannedQR(String qrData) {
    setState(() {
      _isScanning = true;
    });

    try {
      // Parse QR data để lấy invoice ID
      final invoiceId = _extractInvoiceId(qrData);
      
      if (invoiceId != null) {
        // Tìm hóa đơn trong state hiện tại
        final invoiceState = context.read<InvoiceCubit>().state;
        Invoice? foundInvoice;
        
        invoiceState.when(
          loaded: (invoices) {
            try {
              foundInvoice = invoices.firstWhere(
                (invoice) => invoice.id == invoiceId,
              );
            } catch (e) {
              foundInvoice = null;
            }
          },
          initial: () => null,
          loading: () => null,
          error: (_) => null,
        );

        if (foundInvoice != null) {
          // Chuyển đến edit hóa đơn
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceFormPage(
                invoice: foundInvoice,
              ),
            ),
          );
        } else {
          // Hóa đơn không tìm thấy trong state, thử fetch từ server
          _fetchAndNavigateToInvoice(invoiceId);
        }
      } else {
        _showErrorDialog('QR code không hợp lệ. Vui lòng thử lại.');
      }
    } catch (e) {
      _showErrorDialog('Lỗi xử lý QR code: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  String? _extractInvoiceId(String qrData) {
    try {
      // Format: "invoice:123456789"
      if (qrData.startsWith('invoice:')) {
        return qrData.substring(8); // Bỏ "invoice:" prefix
      }
      
      // Format: "123456789" (chỉ ID)
      if (qrData.isNotEmpty && qrData.length < 50) {
        return qrData;
      }
      
      // Format JSON: {"t":"inv","id":"123456789","v":1}
      if (qrData.startsWith('{')) {
        try {
          final jsonData = json.decode(qrData);
          if (jsonData is Map<String, dynamic>) {
            return jsonData['id']?.toString();
          }
        } catch (e) {
          // Fallback: thử parse với single quotes
          final cleanData = qrData.replaceAll("'", '"');
          final jsonData = json.decode(cleanData);
          if (jsonData is Map<String, dynamic>) {
            return jsonData['id']?.toString();
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error extracting invoice ID: $e');
      return null;
    }
  }

  void _fetchAndNavigateToInvoice(String invoiceId) async {
    try {
      // Fetch hóa đơn từ server - sử dụng fetchInvoices thay vì fetchInvoiceById
      context.read<InvoiceCubit>().fetchInvoices();
      
      // Đợi một chút để fetch hoàn thành
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        final invoiceState = context.read<InvoiceCubit>().state;
        invoiceState.when(
          loaded: (invoices) {
            try {
              final foundInvoice = invoices.firstWhere(
                (invoice) => invoice.id == invoiceId,
              );
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceFormPage(
                    invoice: foundInvoice,
                  ),
                ),
              );
            } catch (e) {
              _showErrorDialog('Không tìm thấy hóa đơn với ID: $invoiceId');
            }
          },
          initial: () => _showErrorDialog('Đang tải dữ liệu...'),
          loading: () => _showErrorDialog('Đang tải dữ liệu...'),
          error: (message) => _showErrorDialog('Lỗi: $message'),
        );
      }
    } catch (e) {
      _showErrorDialog('Lỗi khi tải hóa đơn: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Quét QR Code'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quét QR Code để chỉnh sửa hóa đơn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đặt QR code vào khung quét hoặc nhập ID hóa đơn thủ công',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Manual Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập ID hóa đơn thủ công',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manualInputController,
                    decoration: InputDecoration(
                      hintText: 'Nhập ID hóa đơn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _handleManualInput,
                      ),
                    ),
                    onSubmitted: (_) => _handleManualInput(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hướng dẫn sử dụng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    icon: Icons.qr_code,
                    title: 'Quét QR Code',
                    description: 'Sử dụng camera để quét QR code từ hóa đơn',
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    icon: Icons.edit,
                    title: 'Chỉnh sửa hóa đơn',
                    description: 'Sau khi quét, bạn sẽ được chuyển đến trang chỉnh sửa',
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    icon: Icons.info,
                    title: 'Định dạng QR',
                    description: 'QR code chứa ID hóa đơn (ví dụ: invoice:123456789)',
                  ),
                ],
              ),
            ),
            
            if (_isScanning) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(width: 16),
                    Text(
                      'Đang xử lý...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 