import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Small muted label shown above a [FarmFormField]. Mirrors the label style
/// used across the auth/farm forms.
class FarmFieldLabel extends StatelessWidget {
  final AppThemeExtension ext;
  final String text;

  const FarmFieldLabel({super.key, required this.ext, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: ext.cocoa50,
      ),
    );
  }
}

/// Sand-filled, icon-prefixed form field used by the farm and tree sheets.
/// Matches the app's `AuthTextField` visual language (sm radius, ember focus
/// ring) so every form in the app reads the same.
class FarmFormField extends StatelessWidget {
  final AppThemeExtension ext;
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const FarmFormField({
    super.key,
    required this.ext,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, color: ext.cocoa),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: ext.cocoa50),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: AppSpacing.x1),
                child: Icon(prefixIcon, size: 18, color: ext.cocoa50),
              ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        filled: true,
        fillColor: ext.sand,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: ext.ember, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
