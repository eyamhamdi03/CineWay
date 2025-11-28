import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final email = v.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Call AppState signIn (mock)
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.signIn(_emailController.text.trim(), _passwordController.text);
    setState(() => _loading = false);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in failed')));
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
                      decoration: InputDecoration(
                        hintText: 'you@company.com',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 14),
                    Text('Password', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: textColor),
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: textColor.withOpacity(0.6)),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: _validatePassword,
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
                          onPressed: () {
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
                        onPressed: _loading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dodgerBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading ? CircularProgressIndicator(color: colorScheme.onPrimary) : Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                        _socialButton(Icons.apple),
                        const SizedBox(width: 12),
                        _socialButton(Icons.facebook),
                        const SizedBox(width: 12),
                        _socialButton(Icons.email),
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
                                ..onTap = () {
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
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: const Color(0xFF0F1720), borderRadius: BorderRadius.circular(10)),
      child: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social sign-in not implemented'))), icon: Icon(icon, color: AppColors.jumbo)),
    );
  }
}
