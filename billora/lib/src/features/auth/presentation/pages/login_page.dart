import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:billora/src/widgets/language_switcher.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class LoginPage extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const LoginPage({super.key, this.onLocaleChanged});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          LanguageSwitcher(onLocaleChanged: widget.onLocaleChanged),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (user) {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
          String? errorMessage = state.maybeWhen(error: (msg) => msg, orElse: () => null);
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.loginWelcome,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(loc.loginEmail),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "${loc.loginEmail} ${loc.loginError}";
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) return "${loc.loginEmail} ${loc.loginError}";
                        return null;
                      },
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _inputDecoration(loc.loginPassword),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "${loc.loginPassword} ${loc.loginError}";
                        if (value.length < 6) return "${loc.loginPassword} ${loc.loginError}";
                        return null;
                      },
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(height: 24),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.black12),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(loc.loginButton),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacementNamed('/register');
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: Text(loc.loginNoAccount),
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(context),
                    const SizedBox(height: 24),
                    _buildSocialLoginButtons(context, isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context, bool isLoading) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            icon: Image.asset('assets/icons/google.png', height: 22),
            label: const Text('Sign in with Google'),
            onPressed: isLoading ? null : () {
              context.read<AuthCubit>().signInWithGoogle();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              icon: Image.asset('assets/icons/apple_icon.png', height: 22, color: Colors.black),
              label: const Text('Sign in with Apple'),
              onPressed: isLoading ? null : () {
                context.read<AuthCubit>().signInWithApple();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
} 
