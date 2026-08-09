import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---- Radius scale (DESIGN.md §Tokens > Radius) ----
class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 9999;
}

/// ---- Spacing scale (DESIGN.md §9) ----
class AppSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 24;
  static const double x6 = 32;
  static const double x7 = 48;
  static const double x8 = 64;
  static const double x9 = 96;
  static const double x10 = 128;
}

/// ---- Motion (DESIGN.md §Pro tokens > Motion) ----
class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 380);
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);
}

/// ---- Color primitives ----
/// Ember / Pumpkin / Marigold are identical in light & dark — they're the
/// gradient's signature hues and don't change with brightness.
/// Everything else under "Dark mode" is NOT in DESIGN.md — it's my
/// extrapolation (inverted surface/ink). Confirm/adjust as needed.
class AppColors {
  static const Color ember = Color(0xFFD4451F);
  static const Color pumpkin = Color(0xFFFF7A2E);
  static const Color marigold = Color(0xFFFFD24A);

  // Light mode — straight from DESIGN.md §3
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);
  static const Color creamLight = Color(0xFFFFFAF2); // surface
  static const Color sandLight = Color(0xFFF7F1E8); // neutral / inputs
  static const Color cocoaLight = Color(0xFF241813); // primary / text
  static const Color cocoa50Light = Color(0xFF7A6C63); // secondary text
  static const Color hairlineLight = Color(0x12241813); // rgba(36,24,19,.07)

  // Dark mode — extrapolated, not in DESIGN.md
  static const Color cardSurfaceDark = Color(0xFF2A1D17);
  static const Color creamDark = Color(0xFF1A1210); // canvas
  static const Color sandDark = Color(
    0xFF241813,
  ); // card surface (reuses cocoa)
  static const Color cocoaDark = Color(0xFFFFFAF2); // primary text (inverted)
  static const Color cocoa50Dark = Color(0xFFA89A8F); // muted text, lightened
  static const Color hairlineDark = Color(0x14FFFAF2); // light hairline on dark
}

/// ---- Gradient (DESIGN.md §2) ----
/// This is the 3-stop linear base only. The radial blooms + SVG grain
/// aren't reproducible via BoxDecoration alone — we'll build a dedicated
/// GrainyGradientContainer widget (CustomPaint/noise shader) when we get
/// to the actual button/hero components.
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFB53412), // linear stop 0
      Color(0xFFFF7A2E), // linear mid
      Color(0xFFFFC14A), // linear stop end
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

/// ---- Shadows (DESIGN.md §Tokens > Shadows) ----
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D241813), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x12241813),
      offset: Offset(0, 16),
      blurRadius: 40,
      spreadRadius: -18,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x52D4451F),
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x38FF8A3D),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -8,
    ),
  ];
}

/// ---- Typography (DESIGN.md §4) ----
class AppTypography {
  static TextTheme textTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      displayLarge: GoogleFonts.interTight(
        // Hero — 80/0.98/800/-0.045em
        fontSize: 80,
        fontWeight: FontWeight.w800,
        height: 0.98,
        letterSpacing: -0.045 * 80,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.interTight(
        // H1 — 48/1.05/800/-0.035em
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -0.035 * 48,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.interTight(
        // H2 — 28/1.18/700/-0.02em
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.02 * 28,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.interTight(
        // H3 — 22/1.2/700/-0.015em
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.015 * 22,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        // Body — 17/1.58/400/-0.005em
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.58,
        letterSpacing: -0.005 * 17,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(fontSize: 15, color: mutedColor),
      labelLarge: GoogleFonts.interTight(
        // UI/Button — 15/1.4/800/-0.01em
        fontSize: 15,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: -0.01 * 15,
        color: textColor,
      ),
    );
  }

  /// Number — JetBrains Mono, 13/1.0/500/0 — not a standard TextTheme slot,
  /// use directly: Text('₱12,450', style: AppTypography.number(color))
  static TextStyle number(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: color,
  );
}

/// ---- Custom design-token bag, attached to ThemeData via extensions ----
/// Access anywhere with: Theme.of(context).extension<AppThemeExtension>()!
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color cream;
  final Color sand;
  final Color cocoa;
  final Color cocoa50;
  final Color hairline;
  final Color ember;
  final Color pumpkin;
  final Color marigold;
  final Color cardSurface;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> buttonShadow;
  final Gradient primaryGradient;

  const AppThemeExtension({
    required this.cream,
    required this.sand,
    required this.cocoa,
    required this.cocoa50,
    required this.hairline,
    required this.ember,
    required this.pumpkin,
    required this.marigold,
    required this.cardSurface,
    required this.cardShadow,
    required this.buttonShadow,
    required this.primaryGradient,
  });

  @override
  AppThemeExtension copyWith({
    Color? cream,
    Color? sand,
    Color? cocoa,
    Color? cocoa50,
    Color? hairline,
    Color? ember,
    Color? pumpkin,
    Color? marigold,
    Color? cardSurface,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? buttonShadow,
    Gradient? primaryGradient,
  }) {
    return AppThemeExtension(
      cream: cream ?? this.cream,
      sand: sand ?? this.sand,
      cocoa: cocoa ?? this.cocoa,
      cocoa50: cocoa50 ?? this.cocoa50,
      hairline: hairline ?? this.hairline,
      ember: ember ?? this.ember,
      pumpkin: pumpkin ?? this.pumpkin,
      marigold: marigold ?? this.marigold,
      cardSurface: cardSurface ?? this.cardSurface,
      cardShadow: cardShadow ?? this.cardShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      primaryGradient: primaryGradient ?? this.primaryGradient,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cream: Color.lerp(cream, other.cream, t)!,
      sand: Color.lerp(sand, other.sand, t)!,
      cocoa: Color.lerp(cocoa, other.cocoa, t)!,
      cocoa50: Color.lerp(cocoa50, other.cocoa50, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      ember: ember,
      pumpkin: pumpkin,
      marigold: marigold,
      cardShadow: cardShadow,
      buttonShadow: buttonShadow,
      primaryGradient: primaryGradient,
    );
  }
}

/// ---- Button styles (shared so every screen inherits the same shape) ----
class AppButtonStyles {
  static final BorderRadius _radius =
      BorderRadius.circular(AppRadius.sm);

  static final ButtonStyle filled = FilledButton.styleFrom(
    backgroundColor: AppColors.ember,
    foregroundColor: AppColors.creamLight,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x4,
      vertical: AppSpacing.x3,
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: _radius),
  );

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.cocoa50Light,
    side: const BorderSide(color: AppColors.hairlineLight),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x4,
      vertical: AppSpacing.x3,
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: _radius),
  );

  static final ButtonStyle outlinedDark = OutlinedButton.styleFrom(
    foregroundColor: AppColors.cocoa50Dark,
    side: const BorderSide(color: AppColors.hairlineDark),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x4,
      vertical: AppSpacing.x3,
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: _radius),
  );

  static final ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.ember,
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );
}

/// ---- Public entry point ----
class AppTheme {
  static ThemeData get light {
    const ext = AppThemeExtension(
      cream: AppColors.creamLight,
      sand: AppColors.sandLight,
      cocoa: AppColors.cocoaLight,
      cocoa50: AppColors.cocoa50Light,
      hairline: AppColors.hairlineLight,
      ember: AppColors.ember,
      pumpkin: AppColors.pumpkin,
      marigold: AppColors.marigold,
      cardSurface: AppColors.cardSurfaceLight,
      cardShadow: AppShadows.card,
      buttonShadow: AppShadows.button,
      primaryGradient: AppGradients.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.creamLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ember,
        onPrimary: AppColors.creamLight,
        secondary: AppColors.cocoa50Light,
        onSecondary: AppColors.creamLight,
        tertiary: AppColors.pumpkin,
        surface: AppColors.creamLight,
        onSurface: AppColors.cocoaLight,
        surfaceContainerHighest: AppColors.sandLight,
        error: Color(0xFFDC2626),
      ),
      textTheme: AppTypography.textTheme(
        AppColors.cocoaLight,
        AppColors.cocoa50Light,
      ),
      dividerColor: AppColors.hairlineLight,
      filledButtonTheme: FilledButtonThemeData(style: AppButtonStyles.filled),
      outlinedButtonTheme:
          OutlinedButtonThemeData(style: AppButtonStyles.outlined),
      textButtonTheme: TextButtonThemeData(style: AppButtonStyles.text),
      extensions: const [ext],
    );
  }

  static ThemeData get dark {
    const ext = AppThemeExtension(
      cream: AppColors.creamDark,
      sand: AppColors.sandDark,
      cocoa: AppColors.cocoaDark,
      cocoa50: AppColors.cocoa50Dark,
      hairline: AppColors.hairlineDark,
      ember: AppColors.ember,
      pumpkin: AppColors.pumpkin,
      marigold: AppColors.marigold,
      cardSurface: AppColors.cardSurfaceDark,
      cardShadow: AppShadows.card,
      buttonShadow: AppShadows.button,
      primaryGradient: AppGradients.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.creamDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.ember,
        onPrimary: AppColors.creamLight,
        secondary: AppColors.cocoa50Dark,
        onSecondary: AppColors.cocoaDark,
        tertiary: AppColors.pumpkin,
        surface: AppColors.sandDark,
        onSurface: AppColors.cocoaDark,
        surfaceContainerHighest: AppColors.sandDark,
        error: Color(0xFFEF5350),
      ),
      textTheme: AppTypography.textTheme(
        AppColors.cocoaDark,
        AppColors.cocoa50Dark,
      ),
      dividerColor: AppColors.hairlineDark,
      filledButtonTheme: FilledButtonThemeData(style: AppButtonStyles.filled),
      outlinedButtonTheme:
          OutlinedButtonThemeData(style: AppButtonStyles.outlinedDark),
      textButtonTheme: TextButtonThemeData(style: AppButtonStyles.text),
      extensions: const [ext],
    );
  }
}
