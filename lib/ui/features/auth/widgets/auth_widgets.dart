import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class CaKoBeanLogoHeader extends StatelessWidget {
  final String assetPath;
  final double size;

  const CaKoBeanLogoHeader({
    super.key,
    this.assetPath = 'assets/images/cakobean_icon.png',
    this.size = 56,
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
  final TextAlign? textAlign;
  final double? letterSpacing;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    this.verticalPadding = AppSpacing.x3,
    this.fontSize = 14,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.textAlign,
    this.letterSpacing,
    this.inputFormatters,
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
      textAlign: textAlign ?? TextAlign.start,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        color: ext.cocoa,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      ),
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
    this.verticalPadding = AppSpacing.x3, // was hardcoded to x4
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

/// Modern per-digit OTP input: one box per code digit with auto-advance,
/// paste support, and inline error text. Participates in `Form` validation as
/// a [FormField] whose value is the full code.
class OtpInputField extends StatefulWidget {
  final int length;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCompleted;
  final FormFieldValidator<String>? validator;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
    this.validator,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      enabled: widget.enabled,
      initialValue: '',
      validator: widget.validator,
      builder: (fieldState) => _OtpBoxes(
        length: widget.length,
        enabled: widget.enabled,
        errorText: fieldState.errorText,
        onChanged: (value) {
          fieldState.didChange(value);
          widget.onChanged?.call(value);
        },
        onCompleted: widget.onCompleted,
      ),
    );
  }
}

class _OtpBoxes extends StatefulWidget {
  final int length;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;

  const _OtpBoxes({
    required this.length,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onChanged(String value) {
    _submitted = false;
    widget.onChanged(value);
    if (value.length == widget.length) {
      _focusNode.unfocus();
      _complete();
    }
  }

  void _complete() {
    if (_submitted || !widget.enabled) return;
    _submitted = true;
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final focused = _focusNode.hasFocus;
    final activeIndex = code.length.clamp(0, widget.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  for (var i = 0; i < widget.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : AppSpacing.x1,
                          right: i == widget.length - 1 ? 0 : AppSpacing.x1,
                        ),
                        child: _OtpBox(
                          digit: i < code.length ? code[i] : null,
                          active: focused && i == activeIndex,
                          hasError: widget.errorText != null,
                        ),
                      ),
                    ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !widget.enabled,
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(widget.length),
                      ],
                      style: const TextStyle(fontSize: 1, height: 1),
                      cursorWidth: 0,
                      showCursor: false,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _complete(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.x2),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String? digit;
  final bool active;
  final bool hasError;

  const _OtpBox({
    required this.digit,
    required this.active,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final errorColor = Theme.of(context).colorScheme.error;

    final Color borderColor;
    final double borderWidth;
    if (hasError) {
      borderColor = errorColor;
      borderWidth = 1.6;
    } else if (active) {
      borderColor = ext.ember;
      borderWidth = 1.6;
    } else {
      borderColor = ext.hairline;
      borderWidth = 1;
    }

    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: digit == null
          ? null
          : Text(
              digit!,
              style: TextStyle(
                color: ext.cocoa,
                fontSize: 22,
                fontWeight: FontWeight.w700,
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
