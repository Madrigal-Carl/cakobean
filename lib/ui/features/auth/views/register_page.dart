import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/auth/widgets/auth_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final displayName = '$firstName $lastName'.trim();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: displayName.isEmpty ? null : displayName,
          firstName: firstName,
          lastName: lastName,
        );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;
    final clearError = ref.read(authControllerProvider.notifier).clearError;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.x4),
                        const CaKoBeanLogoHeader(),
                        const SizedBox(height: AppSpacing.x5),
                        Text(
                          'Create Your Account',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        Text(
                          'Join the cacao farming network',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AuthTextField(
                          hintText: 'Last Name',
                          icon: Icons.person_outline,
                          controller: _lastNameController,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'First Name',
                          icon: Icons.person_outline,
                          controller: _firstNameController,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'Middle Name (optional)',
                          icon: Icons.person_outline,
                          controller: _middleNameController,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'Username',
                          icon: Icons.alternate_email,
                          controller: _usernameController,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          onChanged: (_) => clearError(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.trim().contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            color: ext.cocoa50,
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        AuthTextField(
                          hintText: 'Confirm Password',
                          icon: Icons.lock_outline,
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _register,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            color: ext.cocoa50,
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: AppSpacing.x2),
                          _RegisterErrorBanner(message: auth.error!),
                        ],
                        const SizedBox(height: AppSpacing.x4),
                        AuthGradientButton(
                          label: 'Create Account',
                          isLoading: isLoading,
                          onPressed: _register,
                          verticalPadding: AppSpacing.x3,
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        AuthFooterLink(
                          question: 'Already have an account?',
                          actionLabel: 'Log In',
                          onTap: isLoading ? () {} : () => context.go('/login'),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                      ],
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
}

class _RegisterErrorBanner extends StatelessWidget {
  final String message;

  const _RegisterErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      child: Container(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: ext.cocoa,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
