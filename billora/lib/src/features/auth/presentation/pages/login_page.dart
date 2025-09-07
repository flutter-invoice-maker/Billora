import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:billora/src/core/services/passkey_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  bool _isFormSubmitted = false;
  bool _isPasswordVisible = false;
  final PasskeyService _passkeyService = PasskeyService();
  bool _isPasskeyAvailable = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _startAnimations();
    _checkPasskeyAvailability();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  void _checkPasskeyAvailability() async {
    final isAvailable = await _passkeyService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isPasskeyAvailable = isAvailable;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onLogin() {
    setState(() => _isFormSubmitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  void _onPasskeyLogin() async {
    try {
      // Check if passkey is available
      if (!_isPasskeyAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passkey authentication is not available on this device.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Try to authenticate with passkey
      final result = await _passkeyService.authenticateWithPasskey(
        credentialId: 'demo_credential_id', // In real app, this would be retrieved from storage
      );

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        // Generate a user ID for passkey login
        final userId = _passkeyService.generateUserId();
        
        // Create a mock user for passkey login
        // In a real app, you would validate the passkey with your server
        // and get the actual user data
        if (mounted) {
          context.read<AuthCubit>().loginWithPasskey(userId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Passkey authentication failed: ${result['error']}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passkey login error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (user) {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              error: (error) {
                setState(() => _isFormSubmitted = false);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
            final String? errorMessage = state.maybeWhen(error: (e) => e, orElse: () => null);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 48.0 : 24.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                                                    
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Header
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: const Color(0xFF1E3A8A), // Blue 800
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Logo with animation and shadow
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoAnimation.value,
                                child: Container(
                                  width: isTablet ? 160 : 140,
                                  height: isTablet ? 160 : 140,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2), // Blue shadow
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/icons/logo.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)], // Blue gradient
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            size: isTablet ? 40 : 32,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Title and subtitle
                          Text(
                            'Login to Your Account',
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2937), // Gray 800
                              letterSpacing: -0.5,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Effortlessly manage your invoices and clients.',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.06),
                          
                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildEmailField(isTablet),
                                const SizedBox(height: 16),
                                _buildPasswordField(isTablet),
                                
                                const SizedBox(height: 12),
                                
                                // Forgot password - aligned to the right
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Password reset coming soon.'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(0xFF1E40AF), // Blue 800
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: const Color(0xFF2563EB), // Blue 600
                                        fontSize: isTablet ? 15 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Error message
                                if (errorMessage != null) 
                                  _buildErrorMessage(errorMessage),
                                
                                // Sign In Button
                                _buildSignInButton(isLoading, isTablet),
                                
                                const SizedBox(height: 20),
                                
                                // Sign up link - moved here
                                GestureDetector(
                                  onTap: isLoading ? null : () {
                                    // Reset animations before navigation
                                    _fadeController.reset();
                                    _slideController.reset();
                                    Navigator.of(context).pushReplacementNamed('/register');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: isTablet ? 15 : 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign up',
                                          style: TextStyle(
                                            color: const Color(0xFF2563EB), // Blue 600
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: screenHeight * 0.04),
                                
                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[300])),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                          fontSize: isTablet ? 14 : 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[300])),
                                  ],
                                ),
                                
                                SizedBox(height: screenHeight * 0.03),
                                
                                // Social buttons
                                _socialButton(
                                  onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithGoogle(),
                                  label: 'Continue with Google',
                                  icon: Icons.g_mobiledata,
                                  isTablet: isTablet,
                                ),
                                
                                const SizedBox(height: 12),
                                
                                _socialButton(
                                  onPressed: isLoading ? null : _onPasskeyLogin,
                                  label: 'Login with Passkey',
                                  icon: Icons.fingerprint,
                                  isTablet: isTablet,
                                ),
                                
                                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
                                  const SizedBox(height: 12),
                                  _socialButton(
                                    onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithApple(),
                                    label: 'Continue with Apple',
                                    icon: CupertinoIcons.person_solid,
                                    isTablet: isTablet,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                        ],
                      ),
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

  Widget _buildEmailField(bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        style: TextStyle(
          fontSize: isTablet ? 16 : 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Your Email',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: const Color(0xFF6B7280), // Gray 500
            size: isTablet ? 22 : 20,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB), // Gray 50
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isTablet ? 20 : 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1), // Gray 200
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2), // Blue 500
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (v) {
          if (!_isFormSubmitted) return null;
          if (v == null || v.isEmpty) return 'Email is required';
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(v)) return 'Please enter a valid email address';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        autofillHints: const [AutofillHints.password],
        style: TextStyle(
          fontSize: isTablet ? 16 : 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: const Color(0xFF6B7280), // Gray 500
            size: isTablet ? 22 : 20,
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF6B7280), // Gray 500
              size: isTablet ? 22 : 20,
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB), // Gray 50
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isTablet ? 20 : 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1), // Gray 200
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2), // Blue 500
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (v) {
          if (!_isFormSubmitted) return null;
          if (v == null || v.isEmpty) return 'Password is required';
          return null;
        },
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _friendlyError(errorMessage),
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(bool isLoading, bool isTablet) {
    return SizedBox(
      height: isTablet ? 60 : 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF), // Blue 800
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 17 : 16,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }

  Widget _socialButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet ? 56 : 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF9FAFB), // Gray 50
          side: BorderSide(color: const Color(0xFFD1D5DB), width: 1), // Gray 300
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF374151), size: isTablet ? 24 : 22), // Gray 700
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF374151), // Gray 700
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 16 : 15,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyError(String errorMessage) {
    if (errorMessage.contains('user-not-found')) return 'No account found with this email. Please check your email or create a new account.';
    if (errorMessage.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (errorMessage.contains('invalid-email')) return 'Please enter a valid email address.';
    if (errorMessage.contains('user-disabled')) return 'This account has been disabled. Please contact support.';
    if (errorMessage.contains('too-many-requests')) return 'Too many failed attempts. Please wait a moment before trying again.';
    if (errorMessage.contains('network')) return 'Network error. Please check your internet connection and try again.';
    return 'Something went wrong. Please try again.';
  }
}