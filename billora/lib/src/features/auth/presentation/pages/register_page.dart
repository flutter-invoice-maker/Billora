import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormSubmitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _logoAnimation = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _logoAnimation.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoAnimation.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isFormSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthCubit>().register(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } catch (e) {
        // Error handling is done in the cubit
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (user) {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        
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
                              scale: 1.0 + (_logoAnimation.value * 0.1),
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
                        
                        SizedBox(height: screenHeight * 0.04),
                    
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Full Name',
                                icon: Icons.person_outline,
                                isTablet: isTablet,
                                validator: (v) {
                                  if (!_isFormSubmitted) return null;
                                  if (v == null || v.isEmpty) return 'Name is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildEmailField(isTablet),
                              const SizedBox(height: 16),
                              _buildPasswordField(isTablet),
                              const SizedBox(height: 16),
                              _buildConfirmPasswordField(isTablet),
                              const SizedBox(height: 24),
                              
                              // Register button
                              SizedBox(
                                width: double.infinity,
                                height: isTablet ? 64 : 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E40AF), // Blue 800
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Sign in link
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: GestureDetector(
                            onTap: _isLoading ? null : () {
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
                                      color: const Color(0xFF2563EB), // Blue 600
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
    );
  }

  Widget _buildPasswordField(bool isTablet) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      autofillHints: const [AutofillHints.newPassword],
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
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(bool isTablet) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      autofillHints: const [AutofillHints.newPassword],
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
          color: const Color(0xFF6B7280), // Gray 500
          size: isTablet ? 22 : 20,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}