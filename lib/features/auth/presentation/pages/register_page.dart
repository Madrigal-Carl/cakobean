import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                        'Create Your Account',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        'Join the cacao farming network',
                        style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      const AuthTextField(
                        hintText: 'Last Name',
                        icon: Icons.person_outline,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'First Name',
                        icon: Icons.person_outline,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'Middle Name (optional)',
                        icon: Icons.person_outline,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'Username',
                        icon: Icons.alternate_email,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'Email (optional)',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
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
                      const SizedBox(height: AppSpacing.x2),
                      const AuthTextField(
                        hintText: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        verticalPadding: AppSpacing.x3,
                        fontSize: 14,
                      ),
                      const SizedBox(height: AppSpacing.x6),
                      AuthGradientButton(
                        label: 'Create Account',
                        onPressed: () => context.go('/home'),
                        verticalPadding: AppSpacing.x3,
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      AuthFooterLink(
                        question: 'Already have an account?',
                        actionLabel: 'Log In',
                        onTap: () => context.go('/login'),
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
