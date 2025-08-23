import 'package:flutter/material.dart';


class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                isSelected: currentIndex == 0,
                onTap: () => _navigate(context, 0),
              ),
              _NavItem(
                label: 'Customers',
                icon: Icons.people_outline,
                isSelected: currentIndex == 1,
                onTap: () => _navigate(context, 1),
              ),
              _ContextAwareFAB(currentIndex: currentIndex),
              _NavItem(
                label: 'Products',
                icon: Icons.inventory_2_outlined,
                isSelected: currentIndex == 3,
                onTap: () => _navigate(context, 3),
              ),
              _NavItem(
                label: 'Invoices',
                icon: Icons.receipt_long_outlined,
                isSelected: currentIndex == 4,
                onTap: () => _navigate(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    onTabChanged(index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customers');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/products');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/invoices');
        break;
    }
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : Colors.black54;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextAwareFAB extends StatelessWidget {
  final int currentIndex;

  const _ContextAwareFAB({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    VoidCallback onPressed;
    String tooltip;

    switch (currentIndex) {
      case 0: // Home
        icon = Icons.document_scanner_outlined;
        tooltip = 'Scan';
        onPressed = () => Navigator.pushNamed(context, '/enhanced-bill-scanner');
        break;
      case 1: // Customers
        icon = Icons.person_add;
        tooltip = 'Add Customer';
        onPressed = () => Navigator.pushNamed(context, '/customer-form');
        break;
      case 3: // Products
        icon = Icons.add_shopping_cart;
        tooltip = 'Add Product';
        onPressed = () => Navigator.pushNamed(context, '/product-form');
        break;
      case 4: // Invoices
        icon = Icons.add;
        tooltip = 'Add Invoice';
        onPressed = () => _showInvoiceOptions(context);
        break;
      default:
        icon = Icons.add;
        tooltip = 'Add';
        onPressed = () {};
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _showInvoiceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.document_scanner_outlined),
                  title: const Text('Scan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/enhanced-bill-scanner');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('New Invoice'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/invoice-form');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
