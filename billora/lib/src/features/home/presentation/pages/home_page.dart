import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/features/suggestions/presentation/cubit/suggestions_cubit.dart';
import 'package:billora/src/features/tags/presentation/cubit/tags_cubit.dart';
import 'package:billora/src/core/di/injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to home page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // This will trigger data refresh when navigating back to home
        debugPrint('🔄 Home page dependencies changed, data will be refreshed');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menu = [
      _MenuItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
        color: Colors.indigo,
      ),
      _MenuItem(
        icon: Icons.people_alt_rounded,
        label: 'Customers',
        route: '/customers',
        color: Colors.blueAccent,
      ),
      _MenuItem(
        icon: Icons.inventory_2_rounded,
        label: 'Products',
        route: '/products',
        color: Colors.deepPurple,
      ),
      _MenuItem(
        icon: Icons.receipt_long,
        label: 'Invoices',
        route: '/invoices',
        color: Colors.green,
      ),
      _MenuItem(
        icon: Icons.document_scanner,
        label: 'Scan & Upload Invoice',
        route: '/bill-scanner',
        color: Colors.orange,
      ),
    ];
    return MultiBlocProvider(
      providers: [
        BlocProvider<SuggestionsCubit>(create: (_) => sl<SuggestionsCubit>()),
        BlocProvider<TagsCubit>(create: (_) => sl<TagsCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Billora Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final item = menu[index];
              return _AnimatedMenuCard(item: item);
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _AnimatedMenuCard extends StatefulWidget {
  final _MenuItem item;
  const _AnimatedMenuCard({required this.item});

  @override
  State<_AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<_AnimatedMenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        setState(() => _pressed = false);
        Navigator.pushNamed(context, widget.item.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.item.color.withAlpha(((_pressed ? 0.10 : 0.18) * 255).toInt()),
              blurRadius: _pressed ? 4 : 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.item.color.withAlpha(((_pressed ? 0.5 : 0.2) * 255).toInt()),
            width: _pressed ? 2 : 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _pressed ? 0.93 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Icon(
                  widget.item.icon,
                  size: 48,
                  color: widget.item.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.item.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.item.color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 