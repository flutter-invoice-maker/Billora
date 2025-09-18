import 'package:flutter/material.dart';
import 'package:billora/src/core/widgets/enhanced_ai_chat_widget.dart';
import 'package:billora/src/core/utils/debug_logger.dart';

class GlobalAIButton extends StatefulWidget {
  final String? invoiceId;
  final Color primaryColor;
  final bool isVisible;
  final VoidCallback? onPressed;
  final int currentTabIndex;

  const GlobalAIButton({
    super.key,
    this.invoiceId,
    required this.primaryColor,
    this.isVisible = true,
    this.onPressed,
    required this.currentTabIndex,
  });

  @override
  State<GlobalAIButton> createState() => _GlobalAIButtonState();
}

class _GlobalAIButtonState extends State<GlobalAIButton> with TickerProviderStateMixin {
  late Offset _position; // from bottom-right by default
  bool _initialized = false;
  bool _isDragging = false;
  late AnimationController _pulseController;
  late AnimationController _chatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _chatAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _chatController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _chatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final size = media.size;
    final padding = media.padding; // safe areas

    // Initialize default position once (right side, above tab bar)
    if (!_initialized) {
      _position = Offset(
        size.width - 20 - 56, // right padding - button width
        size.height * 0.5, // middle of screen for visibility
      );
      _initialized = true;
      // Only print once during initialization, not on every rebuild
      DebugLogger.log('AI Button initialized at position: $_position', tag: 'AIButton');
    }

    final button = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isDragging ? 1.0 : _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.primaryColor,
                  widget.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed ?? () => _showAIChatPanel(context),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              heroTag: "ai_button_${widget.currentTabIndex}",
              child: AnimatedBuilder(
                animation: _chatAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main chatbot icon
                      Transform.rotate(
                        angle: _chatAnimation.value * 0.1,
                        child: const Icon(
                          Icons.smart_toy,
                          size: 24,
                        ),
                      ),
                      // Animated chat bubbles
                      ...List.generate(3, (index) {
                        final delay = index * 0.3;
                        final progress = (_chatAnimation.value - delay).clamp(0.0, 1.0);
                        final opacity = (1.0 - progress).clamp(0.0, 1.0);
                        final scale = 0.3 + (progress * 0.7);
                        
                        return Positioned(
                          right: 8 + (index * 2),
                          top: 8 - (index * 2),
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          // Update position during drag for better visual feedback
          final global = details.globalPosition;
          const buttonSize = 56.0;
          
          // Constrain during drag to prevent going off-screen
          final minX = 16.0;
          final maxX = size.width - buttonSize - 16.0;
          final minY = padding.top + 16.0;
          final maxY = size.height - padding.bottom - buttonSize - 16.0;
          
          double x = global.dx.clamp(minX, maxX);
          double y = global.dy.clamp(minY, maxY);
          
          setState(() {
            _position = Offset(x, y);
          });
        },
        onPanEnd: (details) {
          // Use globalPosition for more accurate positioning
          final global = details.globalPosition;
          
          // Calculate the button size (56x56)
          const buttonSize = 56.0;
          
          // Constrain within screen bounds with proper margins
          final minX = 16.0; // Left margin
          final maxX = size.width - buttonSize - 16.0; // Right margin
          final minY = padding.top + 16.0; // Top margin (below status bar)
          final maxY = size.height - padding.bottom - buttonSize - 16.0; // Bottom margin (above navigation)
          
          // Clamp the position to stay within screen bounds
          double x = global.dx.clamp(minX, maxX);
          double y = global.dy.clamp(minY, maxY);
          
          // Snap to nearest horizontal edge for better UX
          final snapLeft = minX;
          final snapRight = maxX;
          x = (x < size.width / 2) ? snapLeft : snapRight;

          setState(() {
            _position = Offset(x, y);
            _isDragging = false;
          });
          
          DebugLogger.log('AI Button moved to: $_position (global: $global)', tag: 'AIButton');
        },
        child: button,
      ),
    );
  }

  void _showAIChatPanel(BuildContext context) {
    if (widget.invoiceId == null) {
      _showGeneralAIAssistant(context);
    } else {
      _showInvoiceAIChat(context);
    }
  }

  void _showGeneralAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return SizedBox(
          height: height,
          child: EnhancedAIChatWidget(
            currentTabIndex: widget.currentTabIndex,
            primaryColor: widget.primaryColor,
            scrollController: ScrollController(),
          ),
        );
      },
    );
  }

  void _showInvoiceAIChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return SizedBox(
          height: height,
          child: EnhancedAIChatWidget(
            currentTabIndex: 3, // Invoice tab
            primaryColor: widget.primaryColor,
            scrollController: ScrollController(),
          ),
        );
      },
    );
  }
} 