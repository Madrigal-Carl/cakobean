import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/auth/widgets/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;

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
                        const SizedBox(height: AppSpacing.x5),
                        const CaKoBeanLogoHeader(),
                        const SizedBox(height: AppSpacing.x5),
                        Text(
                          'Welcome Back',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x2),
                        Text(
                          'Sign in to your farmer account',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AuthTextField(
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          onChanged: (_) => ref
                              .read(authControllerProvider.notifier)
                              .clearError(),
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
                          textInputAction: TextInputAction.done,
                          verticalPadding: AppSpacing.x3,
                          fontSize: 14,
                          enabled: !isLoading,
                          onSubmitted: _login,
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
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your password'
                              : null,
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: AppSpacing.x2),
                          _AuthErrorBanner(message: auth.error!),
                        ],
                        const SizedBox(height: AppSpacing.x2),
                        AuthGradientButton(
                          label: 'Log In',
                          isLoading: isLoading,
                          onPressed: _login,
                          verticalPadding: AppSpacing.x3,
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        AuthFooterLink(
                          question: "Don't have an account?",
                          actionLabel: 'Register',
                          onTap: isLoading
                              ? () {}
                              : () => context.go('/register'),
                        ),
                        const SizedBox(height: AppSpacing.x6),
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

class _AuthErrorBanner extends StatelessWidget {
  final String message;

  const _AuthErrorBanner({required this.message});

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
