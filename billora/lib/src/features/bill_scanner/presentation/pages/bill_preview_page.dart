import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/bill_scanner_cubit.dart';
import '../cubit/bill_scanner_state.dart';
import '../widgets/confidence_indicator_widget.dart';
import '../widgets/cross_platform_image.dart';
import '../../../invoice/presentation/pages/invoice_form_page.dart';

class BillPreviewPage extends StatefulWidget {
  final String imagePath;

  const BillPreviewPage({
    super.key,
    required this.imagePath,
  });
  
  @override
  State<BillPreviewPage> createState() => _BillPreviewPageState();
}

class _BillPreviewPageState extends State<BillPreviewPage> {
  @override
  void initState() {
    super.initState();
    _processImage();
  }
  
  void _processImage() {
    context.read<BillScannerCubit>().extractBillData(widget.imagePath);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử Lý Hóa Đơn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Hiển thị ảnh đã chụp
          SizedBox(
            height: 250,
            child: CrossPlatformImage(
              imagePath: widget.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          
          const Divider(),
          
          // Nội dung chính
          Expanded(
            child: BlocBuilder<BillScannerCubit, BillScannerState>(
              builder: (context, state) {
                return _buildContent(state);
              },
            ),
          ),
          
          // Buttons
          BlocBuilder<BillScannerCubit, BillScannerState>(
            builder: (context, state) {
              return state.map(
                initial: (_) => _buildActionButtons(),
                loading: (_) => const SizedBox.shrink(),
                scanning: (_) => const SizedBox.shrink(),
                processing: (_) => const SizedBox.shrink(),
                scanSuccess: (_) => _buildActionButtons(),
                extractionSuccess: (_) => _buildActionButtons(),
                error: (_) => _buildActionButtons(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(BillScannerState state) {
    return state.map(
      initial: (_) => const Center(
        child: Text('Bắt đầu xử lý...'),
      ),
      loading: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
      scanning: (_) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang quét hóa đơn...'),
          ],
        ),
      ),
      processing: (_) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xử lý dữ liệu...'),
          ],
        ),
      ),
      scanSuccess: (state) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Quét thành công!'),
            const SizedBox(height: 8),
            Text('Độ tin cậy: ${_getConfidenceText(state.result.confidence)}'),
          ],
        ),
      ),
      extractionSuccess: (state) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dữ Liệu Trích Xuất', 
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Thông tin cơ bản
            _buildDataCard('Tên Cửa Hàng', state.bill.storeName),
            _buildDataCard('Tổng Tiền', '${state.bill.totalAmount.toStringAsFixed(0)} đ'),
            _buildDataCard('Ngày Quét', state.bill.scanDate.toString().split(' ')[0]),
            if (state.bill.phone != null) _buildDataCard('Số Điện Thoại', state.bill.phone!),
            if (state.bill.address != null) _buildDataCard('Địa Chỉ', state.bill.address!),
            
            // Items
            if (state.bill.items != null && state.bill.items!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Danh Sách Sản Phẩm', 
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...(state.bill.items!.map((item) => 
                Card(
                  child: ListTile(
                    title: Text(item.description),
                    subtitle: Text('Số lượng: ${item.quantity.toStringAsFixed(0)}'),
                    trailing: Text('${item.totalPrice.toStringAsFixed(0)} đ'),
                  ),
                )
              )),
            ],
            
            // Confidence indicator
            const SizedBox(height: 20),
            ConfidenceIndicatorWidget(confidence: state.bill.scanResult.confidence),
          ],
        ),
      ),
      error: (state) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processImage,
              child: const Text('Thử Lại'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataCard(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Quét Lại'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: _confirmAndSave,
              child: const Text('Xác Nhận & Tạo Hóa Đơn'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _confirmAndSave() {
    // TODO: Chuyển dữ liệu đến trang tạo hóa đơn
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const InvoiceFormPage(),
      ),
    );
  }
  
  String _getConfidenceText(dynamic confidence) {
    if (confidence.toString().contains('high')) return 'Cao';
    if (confidence.toString().contains('medium')) return 'Trung bình';
    if (confidence.toString().contains('low')) return 'Thấp';
    return 'Không xác định';
  }
} 