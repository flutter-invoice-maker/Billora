import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:billora/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:billora/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:billora/src/features/auth/domain/entities/user.dart';
import 'package:billora/src/features/auth/presentation/widgets/profile_form.dart';

class AppHeader extends StatefulWidget {
  final String? pageTitle;
  final int currentTabIndex;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.pageTitle,
    required this.currentTabIndex,
    this.actions,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> with TickerProviderStateMixin {
  bool _showUserMenu = false;
  OverlayEntry? _overlayEntry;
  Timer? _menuTimer;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getCurrentUser();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));
    
    _headerController.forward();
  }

  @override
  void dispose() {
    _menuTimer?.cancel();
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      // Larger logo without container
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Image.asset(
                          'assets/icons/logo.png',
                          height: 55,
                          width: 55,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Content area - Fixed overflow
                      Expanded(
                        child: widget.currentTabIndex == -1
                            ? _buildHomeHeaderContent(authState)
                            : _buildPageHeaderContent(),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Right side content
                      if (widget.currentTabIndex == -1)
                        _buildUserAvatar(authState)
                      else if (widget.actions != null)
                        ...widget.actions!
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeHeaderContent(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: authState.maybeWhen(
            authenticated: (user) => Text(
              'Hello, ${user.displayName?.split(' ').first ?? 'User'}! 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            orElse: () => const Text(
              'Hello, Guest! 👋',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Ready to manage invoices?',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeaderContent() {
    return Text(
      widget.pageTitle ?? 'Page',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserAvatar(AuthState authState) {
    return GestureDetector(
      onTap: () {
        if (_showUserMenu) {
          if (_overlayEntry != null && _overlayEntry!.mounted) {
            _overlayEntry!.remove();
            _overlayEntry = null;
          }
          setState(() {
            _showUserMenu = false;
          });
        } else {
          setState(() {
            _showUserMenu = true;
          });
          _showMenuOverlay(context); // Pass the parent context here
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF667eea),
          border: _showUserMenu
              ? Border.all(color: const Color(0xFF667eea), width: 2)
              : null,
        ),
        child: _buildAvatar(authState),
      ),
    );
  }

  Widget _buildAvatar(AuthState authState) {
    return authState.maybeWhen(
      authenticated: (user) {
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          return ClipOval(
            child: Image.network(
              user.photoURL!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar(user);
              },
            ),
          );
        } else {
          return _buildDefaultAvatar(user);
        }
      },
      orElse: () => const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildDefaultAvatar(User user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return Center(
        child: Text(
          user.displayName![0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      );
    }
  }

  void _showMenuOverlay(BuildContext parentContext) {
    final RenderBox renderBox = parentContext.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final overlay = Overlay.of(parentContext);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Detect taps outside the menu
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_overlayEntry != null && _overlayEntry!.mounted) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                }
                setState(() {
                  _showUserMenu = false;
                });
              },
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          Positioned(
            top: position.dy + size.height - 10,
            right: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        if (_overlayEntry != null && _overlayEntry!.mounted) {
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        }
                        setState(() {
                          _showUserMenu = false;
                        });
                        _showProfileDialog(parentContext, parentContext.read<AuthCubit>());
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        if (_overlayEntry != null && _overlayEntry!.mounted) {
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        }
                        setState(() {
                          _showUserMenu = false;
                        });
                        parentContext.read<AuthCubit>().logout();
                        Navigator.pushReplacementNamed(parentContext, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext parentContext, AuthCubit authCubit) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      useSafeArea: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<AuthCubit>(),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.all(20),
                child: authState.maybeWhen(
                  authenticated: (user) => ProfileForm(
                    user: user,
                    onClose: () => Navigator.of(parentContext).pop(),
                  ),
                  orElse: () => Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF667eea),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Guest User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please login to edit profile',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


}
