import 'dart:ui';

import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_shadows.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) return;
    final auth = ref.read(authControllerProvider.notifier);
    final registered = await auth.register(
      userName: _nameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
    );
    if (!registered) return;
    final loggedIn = await auth.login(
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
    );
    if (loggedIn && mounted) context.goNamed(RouteNames.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.status == AuthStatus.authenticating;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                boxShadow: AppShadows.level2,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                child: Container(
                  color: AppColors.surfaceContainerLowest,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        right: -40,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryFixed,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create Account',
                                style: AppTextStyles.headlineLg,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Secure your access to ${AppConstants.appName}',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'Jane Doe',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().length < 4)
                                    ? 'At least 4 characters'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'jane@example.com',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (value) =>
                                    (value == null || !value.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null || value.length < 4)
                                    ? 'At least 4 characters'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) => setState(
                                      () => _agreedToTerms = value ?? false,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xs,
                                      ),
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () =>
                                              _agreedToTerms = !_agreedToTerms,
                                        ),
                                        child: Text(
                                          'I agree to the Terms of Service and Privacy Policy.',
                                          style: AppTextStyles.bodySm,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (authState.errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  authState.errorMessage!,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              FilledButton(
                                onPressed: (isSubmitting || !_agreedToTerms)
                                    ? null
                                    : _submit,
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Create Account'),
                                          SizedBox(width: AppSpacing.xs),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      context.goNamed(RouteNames.login),
                                  child: const Text(
                                    'Already have an account? Login here',
                                  ),
                                ),
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
        ),
      ),
    );
  }
}
