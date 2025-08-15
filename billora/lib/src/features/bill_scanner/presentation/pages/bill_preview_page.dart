// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubit/bill_scanner_cubit.dart';
// import '../cubit/bill_scanner_state.dart';
// import '../widgets/confidence_indicator_widget.dart';
// import '../widgets/cross_platform_image.dart';
// import '../../../invoice/presentation/pages/invoice_form_page.dart';

// class BillPreviewPage extends StatefulWidget {
//   final String imagePath;

//   const BillPreviewPage({
//     super.key,
//     required this.imagePath,
//   });
  
//   @override
//   State<BillPreviewPage> createState() => _BillPreviewPageState();
// }

// class _BillPreviewPageState extends State<BillPreviewPage> {
//   @override
//   void initState() {
//     super.initState();
//     _processImage();
//   }
  
//   void _processImage() {
//     context.read<BillScannerCubit>().extractBillData(widget.imagePath);
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Xử Lý Hóa Đơn'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Hiển thị ảnh đã chụp
//           SizedBox(
//             height: 250,
//             child: CrossPlatformImage(
//               imagePath: widget.imagePath,
//               fit: BoxFit.contain,
//             ),
//           ),
          
//           const Divider(),
          
//           // Nội dung chính
//           Expanded(
//             child: BlocBuilder<BillScannerCubit, BillScannerState>(
//               builder: (context, state) {
//                 return _buildContent(state);
//               },
//             ),
//           ),
          
//           // Buttons
//           BlocBuilder<BillScannerCubit, BillScannerState>(
//             builder: (context, state) {
//               return state.map(
//                 initial: (_) => _buildActionButtons(),
//                 loading: (_) => const SizedBox.shrink(),
//                 scanning: (_) => const SizedBox.shrink(),
//                 processing: (_) => const SizedBox.shrink(),
//                 scanSuccess: (_) => _buildActionButtons(),
//                 extractionSuccess: (_) => _buildActionButtons(),
//                 error: (_) => _buildActionButtons(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildContent(BillScannerState state) {
//     return state.map(
//       initial: (_) => const Center(
//         child: Text('Bắt đầu xử lý...'),
//       ),
//       loading: (_) => const Center(
//         child: CircularProgressIndicator(),
//       ),
//       scanning: (_) => const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Đang quét hóa đơn...'),
//           ],
//         ),
//       ),
//       processing: (_) => const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Đang xử lý dữ liệu...'),
//           ],
//         ),
//       ),
//       scanSuccess: (state) => _buildScanResult(state.result),
//       extractionSuccess: (state) => _buildExtractionResult(state.bill),
//       error: (state) => _buildError(state.message),
//     );
//   }

//   Widget _buildScanResult(ScanResult result) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Kết quả quét:',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 16),
//           Text('Text đã trích xuất: ${result.rawText}'),
//           const SizedBox(height: 8),
//           Text('Độ tin cậy: ${result.confidence.name}'),
//           const SizedBox(height: 8),
//           Text('Nhà cung cấp OCR: ${result.ocrProvider}'),
//         ],
//       ),
//     );
//   }

//   Widget _buildExtractionResult(ScannedBill bill) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Dữ liệu đã trích xuất:',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 16),
//           _buildInfoRow('Tên cửa hàng:', bill.storeName),
//           _buildInfoRow('Tổng tiền:', '\$${bill.totalAmount.toStringAsFixed(2)}'),
//           _buildInfoRow('Ngày quét:', bill.scanDate.toString()),
//           if (bill.phone != null) _buildInfoRow('Số điện thoại:', bill.phone!),
//           if (bill.address != null) _buildInfoRow('Địa chỉ:', bill.address!),
//           if (bill.items.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             Text(
//               'Danh sách sản phẩm:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             ...bill.items.map((item) => _buildItemRow(item)),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildError(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             color: Colors.red,
//             size: 64,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Lỗi: $message',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               color: Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemRow(BillLineItem item) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               item.description,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('SL: ${item.quantity}'),
//                 Text('Đơn giá: \$${item.unitPrice.toStringAsFixed(2)}'),
//                 Text('Thành tiền: \$${item.totalPrice.toStringAsFixed(2)}'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Quay lại'),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement create invoice from bill data
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const InvoiceFormPage(),
//                   ),
//                 );
//               },
//               child: const Text('Tạo Hóa Đơn'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 