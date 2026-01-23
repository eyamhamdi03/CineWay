import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_view_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  Future<void> _handleSignUp(AuthViewModel authViewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authViewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/profile_setup',
        arguments: {'isInitialSetup': true},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Sign up failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF000000);
    const primary = Color(0xFF4FC3F7);
    const textPrimary = Color(0xFFF5F5F5);
    const textSecondary = Color(0xFFB0B0B0);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          backgroundColor: bg,
          body: Container(
            color: bg,
            child: Stack(
              children: [
                // Top left blur - light blue
                Positioned(
                  top: -150,
                  left: -150,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.18),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom right blur - light blue
                Positioned(
                  bottom: -150,
                  right: -150,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withOpacity(0.20),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.14),
                          blurRadius: 100,
                          spreadRadius: 25,
                        ),
                      ],
                    ),
                  ),
                ),
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                // Logo Icon
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add,
                                    color: primary,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Title
                                const Text(
                                  'Join CineWay',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Subtitle
                                const Text(
                                  'Create your account to get started',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 50),
                                // Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Email label
                                      const Text(
                                        'EMAIL ADDRESS',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _InputField(
                                        controller: _emailController,
                                        hint: 'hello@example.com',
                                        icon: Icons.mail_outline,
                                        enabled: !authViewModel.isLoading,
                                        validator:
                                            AuthViewModel.validateEmail,
                                      ),
                                      const SizedBox(height: 28),
                                      // Password label
                                      const Text(
                                        'PASSWORD',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _InputField(
                                        controller: _passwordController,
                                        hint: '••••••••',
                                        icon: Icons.lock_outline,
                                        enabled: !authViewModel.isLoading,
                                        obscure:
                                            !authViewModel.isPasswordVisible,
                                        validator: AuthViewModel
                                            .validatePassword,
                                        suffix: IconButton(
                                          icon: Icon(
                                            authViewModel.isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: textSecondary,
                                          ),
                                          onPressed: authViewModel
                                              .togglePasswordVisibility,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      // Confirm Password label
                                      const Text(
                                        'CONFIRM PASSWORD',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _InputField(
                                        controller: _confirmController,
                                        hint: '••••••••',
                                        icon: Icons.lock_outline,
                                        enabled: !authViewModel.isLoading,
                                        obscure:
                                            !authViewModel.isPasswordVisible,
                                        validator: (v) =>
                                            AuthViewModel
                                                .validatePasswordConfirmation(
                                                    v,
                                                    _passwordController
                                                        .text),
                                        suffix: IconButton(
                                          icon: Icon(
                                            authViewModel.isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: textSecondary,
                                          ),
                                          onPressed: authViewModel
                                              .togglePasswordVisibility,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      // Sign Up Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: authViewModel.isLoading
                                              ? null
                                              : () => _handleSignUp(
                                                  authViewModel),
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor: primary,
                                            disabledBackgroundColor:
                                                primary.withOpacity(0.5),
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: authViewModel.isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                            Colors.black),
                                                    strokeWidth: 2.5,
                                                  ),
                                                )
                                              : const Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Sign In Link - pushed to bottom
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign In',
                                      style: const TextStyle(
                                        color: primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            Navigator.maybePop(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.suffix,
    this.enabled = true,
    this.obscure = false,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Widget? suffix;
  final bool enabled;
  final bool obscure;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF2C2C2C);
    const textPrimary = Color(0xFFF5F5F5);
    const textSecondary = Color(0xFFB0B0B0);
    const primary = Color(0xFF4FC3F7);

    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      obscureText: obscure,
      style: const TextStyle(
          color: textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: surface,
        prefixIcon: Icon(icon, color: textSecondary),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
