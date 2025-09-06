import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';  // Temporarily disabled due to compatibility issues
// import 'package:permission_handler/permission_handler.dart';  // Temporarily disabled due to compatibility issues
import 'package:billora/src/core/utils/app_strings.dart';

class BillScannerHubPage extends StatefulWidget {
  const BillScannerHubPage({super.key});

  @override
  State<BillScannerHubPage> createState() => _BillScannerHubPageState();
}

class _BillScannerHubPageState extends State<BillScannerHubPage>
    with TickerProviderStateMixin {
  // CameraController? _controller;  // Temporarily disabled
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // _initializeCamera();  // Temporarily disabled
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _controller?.dispose();  // Temporarily disabled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.scanInvoice),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: Colors.blue.shade600),
            const SizedBox(height: 16),
            Text(
              AppStrings.scanFeatureTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.scanFeatureMobileOnly}\n${AppStrings.scanFeatureUseMobile}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 