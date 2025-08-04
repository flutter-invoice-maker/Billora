import 'package:flutter/material.dart';

class AnimatedImageContainer extends StatefulWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final String placeholderText;
  final VoidCallback? onTap;
  final int slideIndex;

  const AnimatedImageContainer({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.placeholderText,
    this.onTap,
    required this.slideIndex,
  });

  @override
  State<AnimatedImageContainer> createState() => _AnimatedImageContainerState();
}

class _AnimatedImageContainerState extends State<AnimatedImageContainer>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  final bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start floating animation
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _floatAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: screenWidth * 0.85,
                height: screenWidth * 0.65, // More rectangular, wider aspect ratio
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                                         colors: [
                       const Color(0xFF8B5FBF).withValues(alpha: 0.1),
                       const Color(0xFFB794F6).withValues(alpha: 0.05),
                       const Color(0xFFE9D5FF).withValues(alpha: 0.1),
                     ],
                  ),
                  boxShadow: [
                                         BoxShadow(
                       color: const Color(0xFF8B5FBF).withValues(alpha: _glowAnimation.value * 0.3),
                       blurRadius: 30,
                       offset: const Offset(0, 15),
                       spreadRadius: 5,
                     ),
                                         BoxShadow(
                       color: const Color(0xFFB794F6).withValues(alpha: 0.1),
                       blurRadius: 60,
                       offset: const Offset(0, 30),
                     ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                                             border: Border.all(
                         color: const Color(0xFF8B5FBF).withValues(alpha: 0.2),
                         width: 1.5,
                       ),
                                             gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.white.withValues(alpha: 0.9),
                           Colors.white.withValues(alpha: 0.7),
                         ],
                       ),
                    ),
                    child: Stack(
                      children: [
                        // Animated background pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ModernBackgroundPainter(
                              animationValue: _floatAnimation.value,
                              slideIndex: widget.slideIndex,
                            ),
                          ),
                        ),
                        
                        // Main content
                        Positioned.fill(
                          child: _buildImageContent(),
                        ),
                        
                        // Subtle overlay gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                                                 colors: [
                                   Colors.transparent,
                                   const Color(0xFF8B5FBF).withValues(alpha: 0.05),
                                 ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Shimmer effect for loading
                        if (!_isImageLoaded)
                          Positioned.fill(
                            child: _buildShimmerEffect(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with glow effect
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                                     gradient: RadialGradient(
                     colors: [
                       const Color(0xFF8B5FBF).withValues(alpha: _glowAnimation.value * 0.3),
                       const Color(0xFF8B5FBF).withValues(alpha: 0.1),
                       Colors.transparent,
                     ],
                   ),
                ),
                child: Icon(
                  widget.fallbackIcon,
                  size: 80,
                  color: const Color(0xFF8B5FBF),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            widget.placeholderText,
            style: const TextStyle(
              color: Color(0xFF6B46C1),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Beautiful illustration will be here',
                         style: TextStyle(
               color: const Color(0xFF8B5FBF).withValues(alpha: 0.7),
               fontSize: 14,
               fontWeight: FontWeight.w400,
             ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_floatController.value * 2), 0.0),
              end: Alignment(1.0 + (_floatController.value * 2), 0.0),
                               colors: [
                   Colors.transparent,
                   const Color(0xFFB794F6).withValues(alpha: 0.1),
                   Colors.transparent,
                 ],
            ),
          ),
        );
      },
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final double animationValue;
  final int slideIndex;

  ModernBackgroundPainter({
    required this.animationValue,
    required this.slideIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Different patterns for different slides
    switch (slideIndex) {
      case 0:
        _drawDashboardPattern(canvas, size, paint);
        break;
      case 1:
        _drawScanPattern(canvas, size, paint);
        break;
      case 2:
        _drawAnalyticsPattern(canvas, size, paint);
        break;
    }
  }

  void _drawDashboardPattern(Canvas canvas, Size size, Paint paint) {
    // Floating circles
         paint.color = const Color(0xFF8B5FBF).withValues(alpha: 0.08);
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3 + animationValue),
      25,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7 - animationValue),
      15,
      paint,
    );
    
    // Geometric shapes
         paint.color = const Color(0xFFB794F6).withValues(alpha: 0.06);
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6 + animationValue * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawScanPattern(Canvas canvas, Size size, Paint paint) {
    // Scanning lines effect
         paint.color = const Color(0xFF8B5FBF).withValues(alpha: 0.1);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 6) * (i + 1) + (animationValue * 2);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        paint,
      );
    }
    
    // Corner brackets
         paint.color = const Color(0xFFB794F6).withValues(alpha: 0.3);
    paint.strokeWidth = 3;
    
    // Top-left corner
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.3),
      paint,
    );
  }

  void _drawAnalyticsPattern(Canvas canvas, Size size, Paint paint) {
    // Chart bars
    paint.style = PaintingStyle.fill;
    final barWidth = size.width * 0.08;
    final barSpacing = size.width * 0.12;
    
    for (int i = 0; i < 4; i++) {
      final height = (size.height * 0.3) * (0.4 + (i * 0.2)) + (animationValue * 0.1);
      paint.color = Color.lerp(
        const Color(0xFF8B5FBF),
        const Color(0xFFB794F6),
        i / 3,
             )!.withValues(alpha: 0.15);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.2 + (i * barSpacing),
            size.height * 0.7 - height,
            barWidth,
            height,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
    
    // Trend line
         paint.color = const Color(0xFF8B5FBF).withValues(alpha: 0.4);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4 + animationValue,
      size.width * 0.9,
      size.height * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
