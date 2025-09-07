import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_header.dart';
import 'app_tabbar.dart';
import 'global_ai_button.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';

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
    // Try to get AuthCubit from context, but don't fail if not available
    AuthCubit? authCubit;
    try {
      authCubit = context.read<AuthCubit>();
    } catch (e) {
      // AuthCubit not available in this context
      authCubit = null;
    }

    final header = AppHeader(
      currentTabIndex: currentTabIndex,
      pageTitle: pageTitle,
      actions: actions,
      bottom: headerBottom,
      authCubit: authCubit,
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
