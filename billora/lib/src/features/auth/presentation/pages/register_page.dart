import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  bool _isFormSubmitted = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSignup() {
    setState(() => _isFormSubmitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
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
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account created successfully!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.black,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacementNamed('/login');
                });
              },
              error: (_) => setState(() => _isFormSubmitted = false),
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
            final String? errorMessage = state.maybeWhen(error: (e) => e, orElse: () => null);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.05),
                          
                          // Header
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.black,
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
                                        color: Colors.black.withValues(alpha: 0.1),
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
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            size: isTablet ? 50 : 40,
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
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
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
                          
                          SizedBox(height: screenHeight * 0.04),
                      
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline,
                                  isTablet: isTablet,
                                  validator: (v) => _isFormSubmitted && (v == null || v.isEmpty) ? 'Name is required' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildEmailField(isTablet),
                                const SizedBox(height: 16),
                                _buildPasswordField(isTablet),
                                const SizedBox(height: 16),
                                _buildConfirmPasswordField(isTablet),
                                const SizedBox(height: 24),
                                
                                if (errorMessage != null) ...[
                                  Container(
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
                                  ),
                                ],
                                
                                SizedBox(
                                  height: isTablet ? 60 : 56,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onSignup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: isTablet ? 17 : 16,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                GestureDetector(
                                  onTap: isLoading ? null : () {
                                    // Reset animations before navigation
                                    _fadeController.reset();
                                    _slideController.reset();
                                    Navigator.of(context).pushReplacementNamed('/login');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: isTablet ? 15 : 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign in',
                                          style: TextStyle(
                                            color: Colors.blue[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 40),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isTablet,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        fontSize: isTablet ? 16 : 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[500],
          size: isTablet ? 22 : 20,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isTablet) {
    return TextFormField(
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
          color: Colors.grey[500],
          size: isTablet ? 22 : 20,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
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
    );
  }

  Widget _buildPasswordField(bool isTablet) {
    return TextFormField(
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
          color: Colors.grey[500],
          size: isTablet ? 22 : 20,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: isTablet ? 22 : 20,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (v) {
        if (!_isFormSubmitted) return null;
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(bool isTablet) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: TextStyle(
        fontSize: isTablet ? 16 : 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.grey[500],
          size: isTablet ? 22 : 20,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey[500],
            size: isTablet ? 22 : 20,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
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
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (v) {
        if (!_isFormSubmitted) return null;
        if (v != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  String _friendlyError(String errorMessage) {
    if (errorMessage.contains('email-already-in-use')) return 'An account with this email already exists. Please try signing in instead.';
    if (errorMessage.contains('weak-password')) return 'Password is too weak. Please choose a stronger password.';
    if (errorMessage.contains('invalid-email')) return 'Please enter a valid email address.';
    if (errorMessage.contains('network')) return 'Network error. Please check your internet connection and try again.';
    if (errorMessage.contains('too-many-requests')) return 'Too many attempts. Please wait a moment before trying again.';
    if (errorMessage.contains('user-disabled')) return 'This account has been disabled. Please contact support.';
    return 'Something went wrong. Please try again.';
  }
}