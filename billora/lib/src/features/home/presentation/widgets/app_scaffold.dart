import 'package:flutter/material.dart';
import 'app_header.dart';
import 'app_tabbar.dart';
import 'global_ai_button.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentTabIndex;
  final String? pageTitle;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? actions;
  final String? invoiceId; // Add invoiceId parameter for AI context

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTabIndex,
    this.pageTitle,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.actions,
    this.invoiceId,
  });

  Widget _buildDefaultFAB(BuildContext context) {
    if (floatingActionButton != null) {
      return floatingActionButton!;
    }
    
    switch (currentTabIndex) {
      case 0:
        return const HomeFAB();
      case 1:
        return const CustomerAddFAB();
      case 2:
        return const ProductAddFAB();
      case 3:
        return const InvoiceFAB();
      case -1:
        return const ScanFAB();
      default:
        return const ScanFAB();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This is crucial for floating effect
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppHeader(
          currentTabIndex: currentTabIndex,
          pageTitle: pageTitle,
          actions: actions,
        ),
      ),
      body: Stack(
        children: [
          // Main body content
          body,
          // Global AI Button - positioned above tabbar
          GlobalAIButton(
            invoiceId: invoiceId,
            primaryColor: Theme.of(context).primaryColor,
            isVisible: true,
          ),
          // Floating tabbar positioned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppTabBar(
              currentIndex: currentTabIndex,
              onTabChanged: (index) {
                // Tab change is handled by AppTabBar navigation
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30), // Move FAB down a bit to reduce overlap
        child: _buildDefaultFAB(context),
      ),
      floatingActionButtonLocation: floatingActionButtonLocation ?? FloatingActionButtonLocation.centerDocked,
      // Remove bottomNavigationBar since we're using positioned tabbar
    );
  }
}
