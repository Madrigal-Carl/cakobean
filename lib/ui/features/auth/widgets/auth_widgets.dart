import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class CaKoBeanLogoHeader extends StatelessWidget {
  final String assetPath;
  final double size;

  const CaKoBeanLogoHeader({
    super.key,
    this.assetPath = 'assets/images/cakobean_icon.png',
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.eco_outlined, color: ext.ember, size: size * 0.42),
          ),
        ),
        Text('CaKoBean', style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

/// Sand-filled, icon-prefixed text field matching the Solflare Bloom tokens.
class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final double verticalPadding;
  final double fontSize;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    this.verticalPadding = AppSpacing.x4,
    this.fontSize = 15,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: ext.cocoa, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: ext.cocoa50, fontSize: fontSize),
        prefixIcon: Icon(icon, color: ext.cocoa50, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: ext.sand,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: verticalPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: ext.ember, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

/// Full-width pill button with the primary ember→marigold gradient.
class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double verticalPadding; // NEW
  final bool isLoading;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.verticalPadding = AppSpacing.x4, // was hardcoded to x4
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: ext.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: ext.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.creamLight,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.creamLight,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Don't have an account? Register" style footer row with a tappable,
/// ember-colored action word.
class AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return Center(
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: '$question ', style: TextStyle(fontSize: 12)),
            TextSpan(
              text: actionLabel,
              style: TextStyle(
                color: ext.ember,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
