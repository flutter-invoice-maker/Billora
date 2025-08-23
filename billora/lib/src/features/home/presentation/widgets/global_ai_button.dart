import 'package:flutter/material.dart';
import 'package:billora/src/core/widgets/enhanced_ai_chat_widget.dart';

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

class _GlobalAIButtonState extends State<GlobalAIButton> {
  late Offset _position; // from bottom-right by default
  bool _initialized = false;

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
        size.height - padding.bottom - 200, // similar to previous bottom value
      );
      _initialized = true;
    }

    final button = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: widget.onPressed ?? () => _showAIChatPanel(context),
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(
          Icons.auto_awesome,
          size: 24,
        ),
      ),
    );

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: Material(color: Colors.transparent, child: button),
        childWhenDragging: const SizedBox(width: 56, height: 56),
        onDragEnd: (details) {
          final global = details.offset;
          // Constrain within screen minus button size and safe areas
          double x = global.dx.clamp(20.0, size.width - 20.0 - 56.0);
          double y = global.dy.clamp(padding.top + 80.0, size.height - padding.bottom - 80.0);

          // Snap to nearest horizontal edge
          final snapLeft = 20.0;
          final snapRight = size.width - 20.0 - 56.0;
          x = (x < size.width / 2) ? snapLeft : snapRight;

          setState(() {
            _position = Offset(x, y);
          });
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
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => EnhancedAIChatWidget(
          currentTabIndex: widget.currentTabIndex,
          primaryColor: widget.primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showInvoiceAIChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => EnhancedAIChatWidget(
          currentTabIndex: 3, // Invoice tab
          primaryColor: widget.primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }
} 