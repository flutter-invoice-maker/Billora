import 'package:flutter/material.dart';

class SnackBarHelper {
  /// Hiển thị Modern Dialog thay vì SnackBar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration? duration,
    SnackBarBehavior? behavior,
    EdgeInsets? margin,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return ModernNotificationDialog(
          message: message,
          backgroundColor: backgroundColor,
          duration: duration,
        );
      },
    );
  }

  /// Hiển thị Dialog thành công
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Hiển thị Dialog lỗi
  static void showError(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Hiển thị Dialog thông tin
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Hiển thị Dialog cảnh báo
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Hiển thị Dialog với vị trí tùy chỉnh
  static void showSnackBarAtPosition(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration? duration,
    EdgeInsets? margin,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }
}

class ModernNotificationDialog extends StatefulWidget {
  final String message;
  final Color? backgroundColor;
  final Duration? duration;

  const ModernNotificationDialog({
    super.key,
    required this.message,
    this.backgroundColor,
    this.duration,
  });

  @override
  State<ModernNotificationDialog> createState() => _ModernNotificationDialogState();
}

class _ModernNotificationDialogState extends State<ModernNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration ?? const Duration(seconds: 3), () {
      if (mounted) {
        _dismissDialog();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissDialog() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForColor(widget.backgroundColor),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Message
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Close Button
                        GestureDetector(
                          onTap: _dismissDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForColor(Color? color) {
    if (color == Colors.green) return Icons.check_circle;
    if (color == Colors.red) return Icons.error;
    if (color == Colors.blue) return Icons.info;
    if (color == Colors.orange) return Icons.warning;
    return Icons.check_circle;
  }
} 