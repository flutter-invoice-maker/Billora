import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';  // Temporarily disabled due to compatibility issues
// import 'package:image_picker/image_picker.dart';  // Temporarily disabled due to compatibility issues
// import 'package:permission_handler/permission_handler.dart';  // Temporarily disabled due to compatibility issues
// import 'bill_preview_page.dart';  // Temporarily disabled

class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage({super.key});

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage>
    with TickerProviderStateMixin {
  // CameraController? _controller;  // Temporarily disabled
// Temporarily disabled
// Temporarily disabled
  late AnimationController _animationController;
  // final ImagePicker _picker = ImagePicker();  // Temporarily disabled

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Kiểm tra platform và khởi tạo camera
    // _initializeCamera();  // Temporarily disabled
  }

  // Future<void> _initializeCamera() async {
  //   // Camera functionality temporarily disabled due to compatibility issues
  //   // try {
  //   //   // Kiểm tra quyền camera
  //   //   final status = await Permission.camera.request();
  //   //   if (status != PermissionStatus.granted) {
  //   //     _showPermissionDialog();
  //   //     return;
  //   //   }

  //   //   // Lấy danh sách camera
  //   //   final cameras = await availableCameras();
  //   //   if (cameras.isEmpty) {
  //   //     _showErrorDialog('Không tìm thấy camera');
  //   //     return;
  //   //   }

  //   //   // Chọn camera back (nếu có)
  //   //   final camera = cameras.firstWhere(
  //   //     (camera) => camera.lensDirection == CameraLensDirection.back,
  //   //     orElse: () => cameras.first,
  //   //   );

  //   //   _controller = CameraController(
  //   //     camera,
  //   //     ResolutionPreset.high,
  //   //     enableAudio: false,
  //   //     imageFormatGroup: Platform.isAndroid 
  //   //         ? ImageFormatGroup.yuv420 
  //   //         : ImageFormatGroup.bgra8888,
  //   //   );

  //   //   await _controller!.initialize();
  //   //   
  //   //   if (mounted) {
  //   //     setState(() {});
  //   //   }
  //   // } catch (e) {
  //   //   if (mounted) {
  //   //     _showErrorDialog('Lỗi khởi tạo camera: $e');
  //   //   }
  //   // }
  // }

  // void _showPermissionDialog() {
  //   // Permission handler functionality temporarily disabled due to compatibility issues
  //   // showDialog(
  //   //   context: context,
  //   //   builder: (context) => AlertDialog(
  //   //     title: const Text('Quyền Camera'),
  //   //     content: const Text('Ứng dụng cần quyền truy cập camera để quét hóa đơn.'),
  //   //     actions: [
  //   //       TextButton(
  //   //         onPressed: () => Navigator.pop(context),
  //   //         child: const Text('Hủy'),
  //   //       ),
  //   //       TextButton(
  //   //         onPressed: () {
  //   //           Navigator.pop(context);
  //   //           openAppSettings();
  //   //         },
  //   //         child: const Text('Cài Đặt'),
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );
  // }

  // void _showErrorDialog(String message) {
  //   // Temporarily disabled error dialog functionality
  //   // showDialog(
  //   //   context: context,
  //   //   builder: (context) => AlertDialog(
  //   //     title: const Text('Lỗi'),
  //   //     content: Text(message),
  //   //     actions: [
  //   //       TextButton(
  //   //         onPressed: () => Navigator.pop(context),
  //   //         child: const Text('OK'),
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );
  // }

  // Future<void> _toggleFlash() async {
  //   // Camera functionality temporarily disabled due to compatibility issues
  //   // if (_controller == null || !_controller!.value.isInitialized) return;
  //   
  //   // try {
  //   //   await _controller!.setFlashMode(
  //   //     _isFlashOn ? FlashMode.off : FlashMode.torch,
  //   //   );
  //   //   setState(() {
  //   //     _isFlashOn = !_isFlashOn;
  //   //   });
  //   // } catch (e) {
  //   //   // Flash không khả dụng trên một số thiết bị
  //   // }
  // }

  // Future<void> _captureImage() async {
  //   // Camera functionality temporarily disabled due to compatibility issues
  //   // if (_controller == null || !_controller!.value.isInitialized) return;
  //   
  //   // setState(() {
  //   //     _isScanning = true;
  //   // });

  //   // try {
  //   //     final image = await _controller!.takePicture();
  //   //     if (mounted) {
  //   //       Navigator.push(
  //   //         context,
  //   //         MaterialPageRoute(
  //   //           builder: (context) => BillPreviewPage(imagePath: image.path),
  //   //         ),
  //   //       );
  //   //     }
  //   //   } catch (e) {
  //   //     if (mounted) {
  //   //       _showErrorDialog('Lỗi chụp ảnh: $e');
  //   //     }
  //   //   } finally {
  //   //     if (mounted) {
  //   //       setState(() {
  //   //         _isScanning = false;
  //   //       });
  //   //     }
  //   //   }
  // }

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
        title: const Text('Quét Hóa Đơn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // IconButton(
          //   onPressed: _toggleFlash,
          //   icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          // ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview - Temporarily disabled
          // CameraPreview(_controller!),
          
          // Overlay với khung quét
          CustomPaint(
            painter: ScannerOverlayPainter(_animationController),
            size: Size.infinite,
          ),
          
          // Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // FloatingActionButton(
                //   onPressed: _captureImage,
                //   backgroundColor: Colors.blue,
                //   child: _isScanning 
                //     ? const CircularProgressIndicator(color: Colors.white)
                //     : const Icon(Icons.camera, color: Colors.white),
                // ),
                FloatingActionButton(
                  onPressed: () {
                    // Temporarily disabled camera functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera functionality temporarily disabled'),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.camera, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;

  ScannerOverlayPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final rectSize = size.width * 0.7;
    final rect = Rect.fromCenter(
      center: center,
      width: rectSize,
      height: rectSize,
    );

    // Vẽ khung quét
    canvas.drawRect(rect, paint);

    // Vẽ góc quét
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Góc trên trái
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Góc trên phải
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Góc dưới trái
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Góc dưới phải
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );

    // Vẽ đường quét
    final scanLinePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final scanLineY = rect.top + (rect.height * animation.value);
    canvas.drawLine(
      Offset(rect.left, scanLineY),
      Offset(rect.right, scanLineY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 