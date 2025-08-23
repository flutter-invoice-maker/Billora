import 'package:flutter/material.dart';
import 'app_header.dart';
import 'app_tabbar.dart';
import 'global_ai_button.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentTabIndex;
  final String? pageTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? headerBottom;
  final Color backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTabIndex,
    this.pageTitle,
    this.actions,
    this.headerBottom,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final header = AppHeader(
      currentTabIndex: currentTabIndex,
      pageTitle: pageTitle,
      actions: actions,
      bottom: headerBottom,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: header.preferredSize,
        child: header,
      ),
      body: Stack(
        children: [
          body,
          GlobalAIButton(
            invoiceId: null,
            primaryColor: const Color(0xFF667EEA),
            currentTabIndex: currentTabIndex,
          ),
        ],
      ),
      bottomNavigationBar: AppTabBar(
        currentIndex: currentTabIndex,
        onTabChanged: (index) {},
      ),
    );
  }
}
