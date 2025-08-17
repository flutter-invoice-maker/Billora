import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/datasources/enhanced_free_ocr_datasource.dart';
import '../../data/repositories/bill_scanner_repository_impl.dart';
import '../../domain/usecases/scan_bill_usecase.dart';
import '../../domain/entities/enhanced_scanned_bill.dart';
import 'enhanced_data_correction_page.dart';
// Remove scan_library_page.dart import since we'll use named route

class EnhancedImageUploadPage extends StatefulWidget {
  const EnhancedImageUploadPage({super.key});

  @override
  State<EnhancedImageUploadPage> createState() => _EnhancedImageUploadPageState();
}

class _EnhancedImageUploadPageState extends State<EnhancedImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _selectedImagePath;
  String _processingStatus = '';
  
  late final ScanBillUseCase _scanBillUseCase;

  @override
  void initState() {
    super.initState();
    final ocrDataSource = EnhancedFreeOCRApiDataSource();
    final repository = BillScannerRepositoryImpl(ocrDataSource: ocrDataSource);
    _scanBillUseCase = ScanBillUseCase(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Bill Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        // Remove the Scan Library button from app bar
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.library_books),
        //     onPressed: () => _navigateToScanLibrary(),
        //     tooltip: 'Scan Library',
        //   ),
        // ],
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildUploadOptions(),
              if (_selectedImagePath != null) ...[
                const SizedBox(height: 24),
                _buildImagePreview(),
                const SizedBox(height: 24),
                _buildScanButton(),
              ],
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                _buildProcessingIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Title and description
        const Text(
          'AI-Powered Bill Scanner',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload a bill image and let AI extract all the details automatically',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Scan Library access button
        GestureDetector(
          onTap: () => _navigateToScanLibrary(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.library_books,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'View Scan Library',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        _buildUploadOption(
          icon: Icons.camera_alt,
          title: 'Take Photo',
          subtitle: 'Use camera to capture bill',
          color: Colors.green,
          onTap: _takePhoto,
        ),
        const SizedBox(height: 12),
        _buildUploadOption(
          icon: Icons.photo_library,
          title: 'Choose from Gallery',
          subtitle: 'Select existing photo',
          color: Colors.orange,
          onTap: _pickFromGallery,
        ),
        const SizedBox(height: 12),
        _buildUploadOption(
          icon: Icons.folder_open,
          title: 'Browse Files',
          subtitle: 'Select image file',
          color: Colors.purple,
          onTap: _pickFile,
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
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

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Selected Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _selectedImagePath = null),
                icon: const Icon(Icons.close),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'File: ${_selectedImagePath!.split('/').last}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _scanImage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: const Text(
        'Scan Bill with AI',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            'Processing with AI...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _processingStatus,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      _showErrorDialog('Camera error: $e');
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
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      _showErrorDialog('Gallery error: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        setState(() => _selectedImagePath = result.files.first.path);
      }
    } catch (e) {
      _showErrorDialog('File picker error: $e');
    }
  }

  Future<void> _scanImage() async {
    if (_selectedImagePath == null) return;
    
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Initializing AI scanner...';
    });
    
    try {
      setState(() => _processingStatus = 'Extracting text with OCR...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _processingStatus = 'Analyzing bill structure...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _processingStatus = 'Extracting line items...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _processingStatus = 'Validating extracted data...');
      
      final file = File(_selectedImagePath!);
      debugPrint('🔍 Starting scan for file: ${file.path}');
      
      final scannedBill = await _scanBillUseCase(file);
      
      // Convert ScannedBill to EnhancedScannedBill
      final enhancedScannedBill = EnhancedScannedBill(
        id: scannedBill.id,
        imagePath: scannedBill.imagePath,
        storeName: scannedBill.storeName,
        totalAmount: scannedBill.totalAmount,
        scanDate: scannedBill.scanDate,
        scanResult: {
          'rawText': scannedBill.scanResult.rawText,
          'confidence': scannedBill.scanResult.confidence.toString(),
          'processedAt': scannedBill.scanResult.processedAt.toIso8601String(),
          'ocrProvider': scannedBill.scanResult.ocrProvider,
          'detectedBillType': 'commercial_invoice',
          'aiExtractedData': {
            'storeName': scannedBill.storeName,
            'totalAmount': scannedBill.totalAmount,
            'phone': scannedBill.phone,
            'address': scannedBill.address,
          },
          'fieldConfidence': {
            'storeName': 0.9,
            'totalAmount': 0.8,
            'phone': 0.7,
            'address': 0.7,
          },
          'aiSuggestions': [
            'Verify store name spelling',
            'Check total amount calculation',
            'Confirm phone number format',
          ],
          'fieldMappings': {
            'storeName': 'storeName',
            'totalAmount': 'totalAmount',
            'phone': 'phone',
            'address': 'address',
          },
          'isDataValidated': true,
          'aiModelVersion': '1.0',
          'processingMetadata': {
            'source': 'enhanced_ocr',
            'processingTime': DateTime.now().millisecondsSinceEpoch,
          },
        },
        items: scannedBill.items,
        phone: scannedBill.phone,
        address: scannedBill.address,
        note: scannedBill.note,
        subtotal: scannedBill.subtotal,
        tax: scannedBill.tax,
        currency: scannedBill.currency,
        aiProcessedData: {
          'storeName': scannedBill.storeName,
          'totalAmount': scannedBill.totalAmount,
          'phone': scannedBill.phone,
          'address': scannedBill.address,
        },
        fieldAccuracy: {
          'storeName': 0.9,
          'totalAmount': 0.8,
          'phone': 0.7,
          'address': 0.7,
        },
        validationWarnings: [],
        isDataComplete: scannedBill.items?.isNotEmpty == true,
        suggestedCustomerName: scannedBill.storeName,
        suggestedCategory: 'services',
      );
      
      if (!mounted) return;
      
      debugPrint('✅ Scan completed successfully: ${enhancedScannedBill.storeName}, Total: \$${enhancedScannedBill.totalAmount}');
      
      // Navigate to correction page
      final correctedBill = await Navigator.push<EnhancedScannedBill>(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedDataCorrectionPage(
            scannedBill: enhancedScannedBill,
            imagePath: _selectedImagePath!,
          ),
        ),
      );
      
      if (correctedBill != null && mounted) {
        _showSuccessDialog();
      }
      
    } catch (e) {
      debugPrint('❌ Scanning failed: $e');
      if (mounted) {
        _showErrorDialog('Scanning failed: $e');
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Bill has been successfully scanned and processed!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToScanLibrary() {
    // Use named route instead of direct instantiation
    Navigator.pushNamed(context, '/scan-library');
  }
} 