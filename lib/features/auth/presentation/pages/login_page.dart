import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.x6),
                      const CaKoBeanLogoHeader(size: 64),
                      const SizedBox(height: AppSpacing.x6),
                      Text(
                        'Welcome Back',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        'Sign in to your farmer account',
                        style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      const AuthTextField(
                        hintText: 'Username or Email',
                        icon: Icons.person_outline,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x6),
                      AuthGradientButton(
                        label: 'Log In',
                        onPressed: () => context.go('/home'),
                        verticalPadding: AppSpacing.x3,
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      AuthFooterLink(
                        question: "Don't have an account?",
                        actionLabel: 'Register',
                        onTap: () => context.go('/register'),
                      ),
                      const SizedBox(height: AppSpacing.x6),
                    ],
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
