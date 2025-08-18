import 'package:flutter/material.dart';
import 'package:billora/src/core/widgets/enhanced_ai_chat_widget.dart';

class GlobalAIButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 200, // Move up more to avoid overlapping with Add Invoice button
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed ?? () => _showAIChatPanel(context),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(
            Icons.auto_awesome,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showAIChatPanel(BuildContext context) {
    if (invoiceId == null) {
      // Show general AI assistant for main pages
      _showGeneralAIAssistant(context);
    } else {
      // Show invoice-specific AI chat
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
          currentTabIndex: currentTabIndex,
          primaryColor: primaryColor,
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
          primaryColor: primaryColor,
          scrollController: scrollController,
        ),
      ),
    );
  }
} 