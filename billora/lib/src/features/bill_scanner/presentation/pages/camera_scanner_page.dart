import 'package:flutter/material.dart';
class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage({super.key});

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Hóa Đơn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Stack(
        children: [
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