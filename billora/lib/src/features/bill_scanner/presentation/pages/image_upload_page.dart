import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/datasources/enhanced_free_ocr_datasource.dart';
import '../../data/repositories/bill_scanner_repository_impl.dart';
import '../../domain/entities/scanned_bill.dart';
import '../../domain/entities/bill_line_item.dart';
import '../../domain/entities/scan_result.dart';
import 'data_correction_page.dart';
// import 'bill_preview_page.dart';  // Temporarily disabled

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _selectedImagePath;
  String _processingStatus = '';

  late final BillScannerRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = BillScannerRepositoryImpl(
      ocrDataSource: EnhancedFreeOCRApiDataSource(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () => _navigateToScanLibrary(),
            tooltip: 'Scan Library',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Column(
              children: [
                Icon(
                  Icons.document_scanner,
                  size: 64,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Quét Hóa Đơn Tự Động',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chụp hoặc chọn ảnh hóa đơn để trích xuất thông tin tự động',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Upload Options
            Column(
              children: [
                _buildUploadOption(
                  icon: Icons.camera_alt,
                  title: 'Chụp Ảnh Mới',
                  subtitle: 'Sử dụng camera để chụp hóa đơn',
                  onTap: _takePhoto,
                ),
                const SizedBox(height: 16),
                _buildUploadOption(
                  icon: Icons.photo_library,
                  title: 'Chọn từ Thư viện',
                  subtitle: 'Chọn ảnh có sẵn từ thư viện',
                  onTap: _pickFromGallery,
                ),
                const SizedBox(height: 16),
                _buildUploadOption(
                  icon: Icons.folder_open,
                  title: 'Chọn File',
                  subtitle: 'Chọn file ảnh từ thiết bị',
                  onTap: _pickFile,
                ),
              ],
            ),
            
            // Selected Image Preview
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ảnh đã chọn:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.blue.shade600,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImagePath!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImagePath = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // Upload Button
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProcessing ? null : _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang xử lý...'),
                        ],
                      )
                    : const Text(
                        'Quét Hóa Đơn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              // Processing Status
              if (_isProcessing && _processingStatus.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _processingStatus,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Demo button for testing
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _demoScan,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Demo Scan (Test Data)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Lỗi chụp ảnh: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Lỗi chọn ảnh: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowCompression: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedImagePath = file.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi chọn file: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImagePath == null) return;
    
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Đang xử lý ảnh...';
    });
    
    try {
      setState(() => _processingStatus = 'Đang gọi OCR API...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _processingStatus = 'Đang trích xuất dữ liệu...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _processingStatus = 'Đang xử lý kết quả...');
      
      final file = File(_selectedImagePath!);
      final scannedBill = await _repository.scanBill(file);
      
      if (!mounted) return;
      
      setState(() => _processingStatus = 'Hoàn thành!');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      final corrected = await Navigator.push<ScannedBill>(
        context,
        MaterialPageRoute(
          builder: (context) => DataCorrectionPage(scannedBill: scannedBill),
        ),
      );
      
      if (corrected != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dữ liệu hóa đơn đã được xác nhận!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Chuyển dữ liệu đã scan vào invoice form
        _navigateToInvoiceForm(corrected);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi xử lý OCR: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingStatus = '';
        });
      }
    }
  }

  ScannedBill _parseScannedText(String text) {
    debugPrint('🔍 Parsing scanned text: $text');
    
    if (text.trim().isEmpty) {
      return ScannedBill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: _selectedImagePath ?? '',
        storeName: 'Cửa hàng',
        totalAmount: 0.0,
        scanDate: DateTime.now(),
        scanResult: ScanResult(
          rawText: text,
          confidence: ScanConfidence.unknown,
          processedAt: DateTime.now(),
          ocrProvider: 'OCR.Space',
        ),
        items: [],
      );
    }

    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    debugPrint('🔍 Parsed lines: $lines');

    // Extract store name (usually first non-empty line)
    String storeName = 'Cửa hàng';
    if (lines.isNotEmpty) {
      // Skip lines that are just numbers or special characters
      for (final line in lines) {
        if (line.length > 3 && !RegExp(r'^[\d\s\.,\-]+$').hasMatch(line)) {
          storeName = line;
          break;
        }
      }
    }

    // Extract total amount using multiple patterns
    double totalAmount = 0.0;
    final patterns = [
      // Vietnamese currency patterns
      RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)\s*(?:đ|VND|vnd|VNĐ)', caseSensitive: false),
      RegExp(r'(?:Tổng|TOTAL|Tổng cộng|Cộng|Tổng tiền|Thanh toán)[\s:]*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)', caseSensitive: false),
      // USD patterns
      RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)\s*(?:USD|\$)', caseSensitive: false),
      // General number patterns
      RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final raw = match.group(1)!.replaceAll('.', '').replaceAll(',', '.');
        final val = double.tryParse(raw);
        if (val != null && val > totalAmount && val < 1000000000) { // Reasonable range
          totalAmount = val;
        }
      }
    }

    // Extract items if possible
    final items = <BillLineItem>[];
    final itemPattern = RegExp(r'^(.+?)\s+(\d+(?:[.,]\d+)?)\s+(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)\s+(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)$', multiLine: true);
    final itemMatches = itemPattern.allMatches(text);
    
    for (final match in itemMatches) {
      final description = match.group(1)?.trim() ?? '';
      final quantity = double.tryParse(match.group(2)?.replaceAll(',', '.') ?? '1') ?? 1.0;
      final unitPrice = double.tryParse(match.group(3)?.replaceAll('.', '').replaceAll(',', '.') ?? '0') ?? 0.0;
      final totalPrice = double.tryParse(match.group(4)?.replaceAll('.', '').replaceAll(',', '.') ?? '0') ?? 0.0;
      
      if (description.isNotEmpty && unitPrice > 0) {
        items.add(BillLineItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: description,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
          confidence: 0.8,
        ));
      }
    }

    // Extract additional information
    String? phone;
    String? address;
    
    // Phone pattern
    final phonePattern = RegExp(r'(\+84|0)[3-9]\d{8}');
    final phoneMatch = phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      phone = phoneMatch.group(0);
    }
    
    // Address pattern (lines containing common address keywords)
    final addressKeywords = ['đường', 'phố', 'quận', 'huyện', 'tỉnh', 'thành phố', 'street', 'district', 'city'];
    for (final line in lines) {
      if (addressKeywords.any((keyword) => line.toLowerCase().contains(keyword))) {
        address = line;
        break;
      }
    }

    debugPrint('🔍 Extracted data: Store=$storeName, Total=$totalAmount, Items=${items.length}');
    
    return ScannedBill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: _selectedImagePath ?? '',
      storeName: storeName,
      totalAmount: totalAmount,
      scanDate: DateTime.now(),
      scanResult: ScanResult(
        rawText: text,
        confidence: ScanConfidence.medium,
        processedAt: DateTime.now(),
        ocrProvider: 'OCR.Space',
      ),
      items: items,
      phone: phone,
      address: address,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToInvoiceForm(ScannedBill scannedBill) {
    // Chuyển dữ liệu đã scan vào invoice form thông qua route
    Navigator.pushNamed(
      context,
      '/invoice-form',
      arguments: {
        'scannedBill': scannedBill,
        'fromScanner': true,
      },
    );
  }

  void _demoScan() {
    // Demo data để test chức năng scan
    final demoText = '''
CỬA HÀNG ABC
123 Đường ABC, Quận 1, TP.HCM
Điện thoại: 0123456789

Áo thun nam    2    150,000    300,000
Quần jean      1    250,000    250,000
Giày thể thao  1    500,000    500,000

Tổng cộng: 1,050,000 VND
Thuế VAT: 105,000 VND
Thanh toán: 1,155,000 VND
''';
    
    final parsedBill = _parseScannedText(demoText);
    
    Navigator.push<ScannedBill>(
      context,
      MaterialPageRoute(
        builder: (context) => DataCorrectionPage(scannedBill: parsedBill),
      ),
    );
  }

  void _navigateToScanLibrary() {
    // Implement navigation to a dedicated scan library page
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan Library feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
} 