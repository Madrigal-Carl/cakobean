import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _otpFormKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();
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
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final middleName = _middleNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text,
          password: _passwordController.text,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
        );
    if (ok && mounted) context.go('/home');
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (!_otpFormKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .confirmRegistration(code: _otpController.text.trim());
    if (ok && mounted) context.go('/home');
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).resendConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: auth.pendingRegistration == null
            ? _buildRegisterForm(context, auth)
            : _buildOtpStep(context, auth),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthState auth) {
    final textTheme = Theme.of(context).textTheme;
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final isLoading = auth.isLoading;
    final clearError = ref.read(authControllerProvider.notifier).clearError;

    return LayoutBuilder(
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
                      _AuthStatusBanner(
                        message: auth.error!,
                        isError: true,
                      ),
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
    );
  }

  Widget _buildOtpStep(BuildContext context, AuthState auth) {
    final textTheme = Theme.of(context).textTheme;
    final pending = auth.pendingRegistration!;
    final isLoading = auth.isLoading;
    final clearError = ref.read(authControllerProvider.notifier).clearError;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Form(
                key: _otpFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.x4),
                    const CaKoBeanLogoHeader(),
                    const SizedBox(height: AppSpacing.x5),
                    Text(
                      'Verify Your Email',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      'We sent a code to ${pending.email}. '
                      'Enter it below to finish creating your account.',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    AuthTextField(
                      hintText: 'Enter code',
                      icon: Icons.sms_outlined,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      verticalPadding: AppSpacing.x3,
                      fontSize: 20,
                      letterSpacing: 6,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      enabled: !isLoading,
                      onChanged: (_) => clearError(),
                      onSubmitted: _verify,
                      validator: (v) {
                        final code = v?.trim() ?? '';
                        if (code.length < 6 || code.length > 8) {
                          return 'Enter the code from your email';
                        }
                        return null;
                      },
                    ),
                    if (auth.info != null) ...[
                      const SizedBox(height: AppSpacing.x2),
                      _AuthStatusBanner(
                        message: auth.info!,
                        isError: false,
                      ),
                    ],
                    if (auth.error != null) ...[
                      const SizedBox(height: AppSpacing.x2),
                      _AuthStatusBanner(
                        message: auth.error!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.x4),
                    AuthGradientButton(
                      label: 'Verify Account',
                      isLoading: isLoading,
                      onPressed: _verify,
                      verticalPadding: AppSpacing.x3,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    AuthFooterLink(
                      question: "Didn't get the code?",
                      actionLabel: 'Resend',
                      onTap: isLoading ? () {} : _resend,
                    ),
                    const SizedBox(height: AppSpacing.x4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shared success/error banner matching the app theme (ember accent for
/// errors, green for informational/success messages).
class _AuthStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _AuthStatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final color = isError
        ? Theme.of(context).colorScheme.error
        : const Color(0xFF16A34A);

    return AnimatedSwitcher(
      duration: AppMotion.fast,
      child: Container(
        key: ValueKey('$isError-$message'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 18,
              color: color,
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
