import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
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
      Navigator.pushReplacementNamed(context, '/profile_setup');
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
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.mirage,
          appBar: AppBar(
            backgroundColor: AppColors.mirage,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 8),
                        Text('CineWay', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        Text('Create Your Account', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (authViewModel.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authViewModel.errorMessage!,
                              style: TextStyle(color: Colors.red[400], fontSize: 14),
                            ),
                          ),
                          GestureDetector(
                            onTap: authViewModel.clearError,
                            child: Icon(Icons.close, color: Colors.red[400], size: 18),
                          ),
                        ],
                      ),
                    ),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !authViewModel.isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: const TextStyle(color: AppColors.mirageLight),
                            filled: true,
                            fillColor: const Color(0xFF141A20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: AuthViewModel.validateEmail,
                        ),

                        const SizedBox(height: 16),
                        const Text('Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !authViewModel.isPasswordVisible,
                          enabled: !authViewModel.isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(color: AppColors.mirageLight),
                            filled: true,
                            fillColor: const Color(0xFF141A20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: Icon(
                                authViewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.mirageLight,
                              ),
                              onPressed: authViewModel.togglePasswordVisibility,
                            ),
                          ),
                          validator: AuthViewModel.validatePassword,
                        ),

                        const SizedBox(height: 16),
                        const Text('Confirm Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: !authViewModel.isPasswordVisible,
                          enabled: !authViewModel.isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            hintStyle: const TextStyle(color: AppColors.mirageLight),
                            filled: true,
                            fillColor: const Color(0xFF141A20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: Icon(
                                authViewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.mirageLight,
                              ),
                              onPressed: authViewModel.togglePasswordVisibility,
                            ),
                          ),
                          validator: (v) => AuthViewModel.validatePasswordConfirmation(v, _passwordController.text),
                        ),

                        const SizedBox(height: 22),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authViewModel.isLoading ? null : () => _handleSignUp(authViewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dodgerBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: authViewModel.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                        ),

                        const SizedBox(height: 18),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: const TextStyle(color: AppColors.jumbo),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: const TextStyle(color: AppColors.dodgerBlue, fontWeight: FontWeight.w700),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = authViewModel.isLoading ? null : () => Navigator.maybePop(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
