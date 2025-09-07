import 'package:flutter/material.dart';
import 'package:billora/src/features/invoice/presentation/widgets/ai_chat_panel.dart';

class AIFloatingButton extends StatelessWidget {
  final String invoiceId;
  final Color primaryColor;
  final bool isVisible;

  const AIFloatingButton({
    super.key,
    required this.invoiceId,
    required this.primaryColor,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 100, // Move up to avoid overlapping with other elements
      right: 16, // Reduced from 20 to 16 for better margin
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32, // Ensure it doesn't exceed screen width
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: FloatingActionButton(
                  onPressed: () => _showAIChatPanel(context),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 2000),
                    turns: value * 2,
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAIChatPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AIChatPanel(
          invoiceId: invoiceId,
          primaryColor: primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }
} 