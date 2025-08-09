import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import for ImageFilter
import 'package:billora/src/features/customer/presentation/pages/customer_form_page.dart';
import 'package:billora/src/features/product/presentation/pages/product_form_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/features/product/presentation/cubit/product_cubit.dart';
import 'package:billora/src/features/product/domain/entities/product.dart';

class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final List<String> _tabTitles = const [
    'Dashboard',
    'Customers',
    'Products',
    'Invoices',
  ];

  final List<IconData> _tabIcons = const [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.inventory_2_rounded,
    Icons.receipt_long_rounded,
  ];

  final List<Color> _tabColors = const [
    Color(0xFF667eea),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        // Enhanced floating effect with blur and transparency
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.15),
            blurRadius: 35,
            offset: const Offset(0, -15),
            spreadRadius: -5,
          ),
        ],
        // Add border for better floating effect
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: SafeArea(
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tab 1
                    _buildTabItem(context, 0),
                    // Tab 2
                    _buildTabItem(context, 1),
                    // Spacer for center FAB
                    const SizedBox(width: 70),
                    // Tab 3
                    _buildTabItem(context, 2),
                    // Tab 4
                    _buildTabItem(context, 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index) {
    final isSelected = currentIndex >= 0 && currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTabChanged(index);
          _navigateToPage(context, index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? _tabColors[index].withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _tabIcons[index],
                  color: isSelected ? _tabColors[index] : Colors.grey[400],
                  size: isSelected ? 24 : 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? _tabColors[index] : Colors.grey[400],
                ),
                child: Text(
                  _tabTitles[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customers');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/products');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/invoices');
        break;
    }
  }
}

class ScanFAB extends StatelessWidget {
  const ScanFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF8E53),
            Color(0xFFFFB366),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            Navigator.pushNamed(context, '/bill-scanner');
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeFAB extends StatelessWidget {
  const HomeFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerAddFAB extends StatelessWidget {
  const CustomerAddFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
            Color(0xFF1E40AF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerFormPage(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductAddFAB extends StatelessWidget {
  const ProductAddFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF7C3AED),
            Color(0xFF6D28D9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<ProductCubit>(
                  create: (_) => sl<ProductCubit>(),
                  child: const ProductFormPage(),
                ),
              ),
            );
            
            // If a product was created/updated, add it to the product list immediately
            if (result != null && result is Product) {
              // The product is already added to the cubit in ProductFormPage
              // We just need to ensure the UI updates
              if (context.mounted) {
                // Show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product "${result.name}" created successfully!'),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
