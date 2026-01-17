import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../viewmodel/auth_view_model.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleSignIn(AuthViewModel authViewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authViewModel.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Sign in failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // logo + title
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Icon(Icons.movie, color: colorScheme.onPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Text('CineWay', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text('Welcome back', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Sign in to continue to your movies and bookings.', style: TextStyle(color: textColor.withOpacity(0.7))),

                  const SizedBox(height: 22),

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
                        Text('Email', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: textColor),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !authViewModel.isLoading,
                          decoration: InputDecoration(
                            hintText: 'you@company.com',
                            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          validator: AuthViewModel.validateEmail,
                        ),

                        const SizedBox(height: 14),
                        Text('Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: textColor),
                          obscureText: !authViewModel.isPasswordVisible,
                          enabled: !authViewModel.isLoading,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: Icon(
                                authViewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: textColor.withOpacity(0.6),
                              ),
                              onPressed: authViewModel.togglePasswordVisibility,
                            ),
                          ),
                          validator: AuthViewModel.validatePassword,
                        ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(value: false, onChanged: (_) {}),
                                Text('Remember me', style: TextStyle(color: textColor.withOpacity(0.7))),
                              ],
                            ),
                            TextButton(
                              onPressed: authViewModel.isLoading
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text('Forgot?', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authViewModel.isLoading ? null : () => _handleSignIn(authViewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dodgerBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: authViewModel.isLoading
                                ? CircularProgressIndicator(color: colorScheme.onPrimary)
                                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Color(0xFF232B36))),
                            SizedBox(width: 8),
                            Text('or', style: TextStyle(color: AppColors.jumbo)),
                            SizedBox(width: 8),
                            Expanded(child: Divider(color: Color(0xFF232B36))),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(context, Icons.apple),
                            const SizedBox(width: 12),
                            _buildSocialButton(context, Icons.facebook),
                            const SizedBox(width: 12),
                            _buildSocialButton(context, Icons.email),
                          ],
                        ),

                        const SizedBox(height: 22),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: textColor.withOpacity(0.7)),
                              children: [
                                TextSpan(
                                  text: 'Create',
                                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = authViewModel.isLoading
                                        ? null
                                        : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      );
                                    },
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

  Widget _buildSocialButton(BuildContext context, IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: const Color(0xFF0F1720), borderRadius: BorderRadius.circular(10)),
      child: IconButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social sign-in not implemented'))),
        icon: Icon(icon, color: AppColors.jumbo),
      ),
    );
  }
}
