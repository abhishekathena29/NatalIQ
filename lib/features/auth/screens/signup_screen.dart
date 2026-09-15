import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/core/widgets/line_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _emailError = _emailRegex.hasMatch(email) ? null : 'Enter a valid email address';
      _passwordError = password.length >= 6 ? null : 'Password must be at least 6 characters';
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    try {
      await AuthService.instance.signUp(email, password);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _formError = e.message;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradientWarm),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.sprout, size: 26, color: AppColors.sageForeground),
                    ),
                    const SizedBox(height: 24),
                    Text('Create your account', style: displayFont(fontSize: 28, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      "A gentle companion for you and your baby's journey.",
                      style: sansFont(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    LineTextField(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 20),
                    LineTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hintText: 'At least 6 characters',
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      errorText: _passwordError,
                      onSubmitted: (_) => _submit(),
                      suffix: IconButton(
                        icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: AppColors.mutedForeground),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(_formError!, style: sansFont(fontSize: 13, color: AppColors.destructive)),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.x2l),
                        onTap: _submitting ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.x2l),
                            boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 20, offset: Offset(0, 4))],
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground),
                                )
                              : Text('Create account', style: sansFont(fontWeight: FontWeight.w700, color: AppColors.primaryForeground)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text.rich(
                          TextSpan(
                            style: sansFont(fontSize: 13, color: AppColors.mutedForeground),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log in',
                                style: sansFont(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
