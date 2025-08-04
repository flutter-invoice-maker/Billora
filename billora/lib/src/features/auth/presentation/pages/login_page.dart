import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _backgroundController;
  late AnimationController _fadeController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form validation state
  bool _isFormSubmitted = false;
  bool _isPasswordVisible = false;

  // Theme colors matching onboarding
  final Color _primaryColor = const Color(0xFF8B5FBF);
  final Color _secondaryColor = const Color(0xFFB794F6);
  final Color _accentColor = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 30000), // Longer duration for smoother, less noticeable loop
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _backgroundController.repeat();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _backgroundController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onLogin() {
    setState(() {
      _isFormSubmitted = true;
    });
    
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _secondaryColor.withValues(alpha: 0.08),
                  Colors.white,
                  _primaryColor.withValues(alpha: 0.12),
                  _accentColor.withValues(alpha: 0.06),
                ],
                stops: [
                  0.0,
                  0.25 + (_backgroundAnimation.value * 0.15),
                  0.5,
                  0.75 + (_backgroundAnimation.value * 0.1),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating icons background
                _buildFloatingIcons(screenHeight, screenWidth),
                
                // Main content
                SafeArea(
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        authenticated: (user) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        error: (error) {
                          // Reset form submission state on error
                          setState(() {
                            _isFormSubmitted = false;
                          });
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
                      String? errorMessage = state.maybeWhen(error: (msg) => msg, orElse: () => null);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight - MediaQuery.of(context).padding.top,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: isSmallScreen ? 16 : 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo and Header Section
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: _buildHeaderSection(isSmallScreen),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 32 : 48),

                                // Form Section
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: _buildFormSection(errorMessage, isLoading, isSmallScreen),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 24 : 32),

                                // Social Login Section
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: _buildSocialSection(isLoading, isSmallScreen),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 16 : 24),

                                // Footer
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildFooter(isLoading),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      children: [
        // Logo without container - larger size
        Image.asset(
          'assets/icons/logo.png',
          height: isSmallScreen ? 200 : 240, // Doubled size again
          width: isSmallScreen ? 200 : 240,  // Doubled size again
          fit: BoxFit.contain,
        ),

        SizedBox(height: isSmallScreen ? 24 : 32),

        // Welcome text
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          'Sign in to continue your journey',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: _primaryColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(String? errorMessage, bool isLoading, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            _buildEmailField(),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Password field
            _buildPasswordField(isSmallScreen),

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Error message
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getUserFriendlyErrorMessage(errorMessage),
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Login button
            _buildGradientButton(
              onPressed: isLoading ? null : _onLogin,
              text: 'Sign In',
              isLoading: isLoading,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final email = _emailController.text.trim();
    final isValidEmail = email.isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email);
    
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined, color: _primaryColor.withValues(alpha: 0.7)),
        suffixIcon: isValidEmail 
          ? Icon(Icons.check_circle, color: _primaryColor, size: 20)
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: _primaryColor.withValues(alpha: 0.7)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (!_isFormSubmitted) return null;
        if (value == null || value.isEmpty) return "Email is required";
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) return "Please enter a valid email address";
        return null;
      },
      autofillHints: const [AutofillHints.email],
      onChanged: (value) {
        setState(() {}); // Rebuild to show/hide check icon
      },
    );
  }

  Widget _buildPasswordField(bool isSmallScreen) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: _primaryColor.withValues(alpha: 0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: _primaryColor.withValues(alpha: 0.7),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: _primaryColor.withValues(alpha: 0.7)),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (!_isFormSubmitted) return null;
        if (value == null || value.isEmpty) return "Password is required";
        return null;
      },
      autofillHints: const [AutofillHints.password],
    );
  }

  String _getUserFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('user-not-found')) {
      return 'No account found with this email. Please check your email or create a new account.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a moment before trying again.';
    } else if (errorMessage.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }



  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isLoading,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialSection(bool isLoading, bool isSmallScreen) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: _primaryColor.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: _primaryColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: _primaryColor.withValues(alpha: 0.3)),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 20 : 24),

        // Social buttons
        _buildSocialButton(
          onPressed: isLoading ? null : () {
            context.read<AuthCubit>().signInWithGoogle();
          },
          text: 'Continue with Google',
          imagePath: 'assets/icons/google.png',
          isLoading: isLoading,
        ),

        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
          const SizedBox(height: 12),
          _buildSocialButton(
            onPressed: isLoading ? null : () {
              context.read<AuthCubit>().signInWithApple();
            },
            text: 'Continue with Apple',
            imagePath: 'assets/icons/apple_icon.png',
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required String text,
    required String imagePath,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: _primaryColor.withValues(alpha: 0.7),
            fontSize: 15,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pushReplacementNamed('/register');
                      },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcons(double screenHeight, double screenWidth) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Invoice icon (receipt) - moves from top-left to bottom-right
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.7 % 1.0),
                left: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.6 % 1.0),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.5,
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: _primaryColor.withValues(alpha: 0.25),
                  ),
                ),
              ),
              
              // Dollar icon (money) - moves from bottom-right to top-left
              Positioned(
                bottom: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.8 % 1.0),
                right: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.7 % 1.0),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.3,
                  child: Icon(
                    Icons.attach_money_outlined,
                    size: 34,
                    color: _secondaryColor.withValues(alpha: 0.28),
                  ),
                ),
              ),
              
              // Chart icon (trending up) - moves from top-right to bottom-left
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.6 % 1.0),
                right: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.5 % 1.0),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.4,
                  child: Icon(
                    Icons.trending_up_outlined,
                    size: 32,
                    color: _accentColor.withValues(alpha: 0.23),
                  ),
                ),
              ),
              
              // Credit card icon - moves from bottom-left to top-right
              Positioned(
                bottom: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.75 % 1.0),
                left: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.65 % 1.0),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.6,
                  child: Icon(
                    Icons.credit_card_outlined,
                    size: 28,
                    color: _primaryColor.withValues(alpha: 0.24),
                  ),
                ),
              ),
              
              // Calculator icon - moves from left-center to right-center
              Positioned(
                top: screenHeight * 0.4 + (screenHeight * 0.2 * (_backgroundAnimation.value * 0.9 % 1.0)),
                left: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.8 % 1.0),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.7,
                  child: Icon(
                    Icons.calculate_outlined,
                    size: 26,
                    color: _secondaryColor.withValues(alpha: 0.26),
                  ),
                ),
              ),
              
              // Wallet icon - moves from right-center to left-center
              Positioned(
                top: screenHeight * 0.6 - (screenHeight * 0.2 * (_backgroundAnimation.value * 0.85 % 1.0)),
                right: -50 + (screenWidth + 100) * (_backgroundAnimation.value * 0.7 % 1.0),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.4,
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 30,
                    color: _accentColor.withValues(alpha: 0.27),
                  ),
                ),
              ),
              // Printer icon - moves from top-center to bottom-center
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.5 % 1.0),
                left: screenWidth * 0.4 + (screenWidth * 0.1 * (_backgroundAnimation.value * 0.4 % 1.0)),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.8,
                  child: Icon(
                    Icons.print_outlined,
                    size: 30,
                    color: _primaryColor.withValues(alpha: 0.22),
                  ),
                ),
              ),
              // Checkmark icon (for completion/success) - moves from bottom-center to top-center
              Positioned(
                bottom: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.6 % 1.0),
                right: screenWidth * 0.3 + (screenWidth * 0.15 * (_backgroundAnimation.value * 0.5 % 1.0)),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.2,
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 34,
                    color: _secondaryColor.withValues(alpha: 0.29),
                  ),
                ),
              ),
              // Money bag icon - moves diagonally
              Positioned(
                top: -50 + (screenHeight + 100) * (_backgroundAnimation.value * 0.9 % 1.0),
                left: screenWidth * 0.1 + (screenWidth * 0.7 * (_backgroundAnimation.value * 0.8 % 1.0)),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.6,
                  child: Icon(
                    Icons.monetization_on_outlined,
                    size: 38,
                    color: _accentColor.withValues(alpha: 0.26),
                  ),
                ),
              ),
              // Document scanner icon - moves diagonally
              Positioned(
                top: screenHeight * 0.1 + (screenHeight * 0.7 * (_backgroundAnimation.value * 0.7 % 1.0)),
                right: screenWidth * 0.1 + (screenWidth * 0.6 * (_backgroundAnimation.value * 0.9 % 1.0)),
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.3,
                  child: Icon(
                    Icons.document_scanner_outlined,
                    size: 30,
                    color: _primaryColor.withValues(alpha: 0.20),
                  ),
                ),
              ),
              // Bar chart icon - moves diagonally
              Positioned(
                bottom: screenHeight * 0.1 + (screenHeight * 0.7 * (_backgroundAnimation.value * 0.8 % 1.0)),
                left: screenWidth * 0.1 + (screenWidth * 0.6 * (_backgroundAnimation.value * 0.7 % 1.0)),
                child: Transform.rotate(
                  angle: -_backgroundAnimation.value * 0.5,
                  child: Icon(
                    Icons.bar_chart_outlined,
                    size: 32,
                    color: _secondaryColor.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
