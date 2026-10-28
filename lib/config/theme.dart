import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand + semantic color tokens (see DESIGN.md §2).
class AppColors {
  // Brand Primary (Emerald)
  static const Color primary = Color(0xFF006C49);
  static const Color primaryContainer = Color(0xFF10B981);
  static const Color primaryFixed = Color(0xFF6FFBBE);
  static const Color primaryFixedDim = Color(0xFF4EDEA3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF00422B);

  // Secondary (Mint / Teal)
  static const Color secondary = Color(0xFF006B5F);
  static const Color secondaryContainer = Color(0xFF6DF5E1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF006F64);

  // Tertiary (Indigo)
  static const Color tertiary = Color(0xFF005AC2);
  static const Color tertiaryContainer = Color(0xFF71A1FF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF00367A);

  // Surface & Neutrals (Light Mode)
  static const Color surface = Color(0xFFFAF8FF);
  static const Color background = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF3C4A42);
  static const Color outline = Color(0xFF6C7A71);
  static const Color outlineVariant = Color(0xFFBBCABF);

  // Semantic Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);
  static const Color success = Color(0xFF10B981);

  // Category accents (group icons)
  static const Color foodAccent = Color(0xFFEA580C);
  static const Color foodContainer = Color(0xFFFFEDD5);
  static const Color travelAccent = Color(0xFF0E7490);
  static const Color travelContainer = Color(0xFFCFFAFE);
  static const Color homeAccent = Color(0xFF4338CA);
  static const Color homeContainer = Color(0xFFE0E7FF);
  static const Color workAccent = Color(0xFF7E22CE);
  static const Color workContainer = Color(0xFFF3E8FF);

  // Dark Mode Overrides
  static const Color darkSurface = Color(0xFF10141D);
  static const Color darkBackground = Color(0xFF10141D);
  static const Color darkSurfaceContainerLowest = Color(0xFF171C26);
  static const Color darkSurfaceContainerLow = Color(0xFF1E2430);
  static const Color darkSurfaceContainer = Color(0xFF242B38);
  static const Color darkSurfaceContainerHigh = Color(0xFF2C3443);
  static const Color darkOnSurface = Color(0xFFE2E7FF);
  static const Color darkOnSurfaceVariant = Color(0xFFA5B0BF);
  static const Color darkOutline = Color(0xFF7D8896);
  static const Color darkOutlineVariant = Color(0xFF3A4352);
}

/// Neutral surface palette that flips between light and dark mode.
/// Brand colors stay in [AppColors]; neutrals must come from here.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color card;
  final Color cardBorder;
  final Color surfaceLow;
  final Color surfaceContainer;
  final Color surfaceHigh;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color mintTint;
  final Color errorTint;
  final Color warningTint;

  const AppPalette({
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.surfaceLow,
    required this.surfaceContainer,
    required this.surfaceHigh,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.mintTint,
    required this.errorTint,
    required this.warningTint,
  });

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    card: AppColors.surfaceContainerLowest,
    cardBorder: AppColors.surfaceContainer,
    surfaceLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceHigh: AppColors.surfaceContainerHigh,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    mintTint: Color(0xFFE7FBF3),
    errorTint: Color(0xFFFFF1EF),
    warningTint: Color(0xFFFFF8E6),
  );

  static const AppPalette dark = AppPalette(
    background: AppColors.darkBackground,
    card: AppColors.darkSurfaceContainerLowest,
    cardBorder: AppColors.darkSurfaceContainer,
    surfaceLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceHigh: AppColors.darkSurfaceContainerHigh,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    mintTint: Color(0xFF0F2E25),
    errorTint: Color(0xFF3A1B1B),
    warningTint: Color(0xFF3A2E12),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? cardBorder,
    Color? surfaceLow,
    Color? surfaceContainer,
    Color? surfaceHigh,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? mintTint,
    Color? errorTint,
    Color? warningTint,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      mintTint: mintTint ?? this.mintTint,
      errorTint: errorTint ?? this.errorTint,
      warningTint: warningTint ?? this.warningTint,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      mintTint: Color.lerp(mintTint, other.mintTint, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Typography tokens (DESIGN.md §3). Colors are applied at call-site.
class AppText {
  static TextStyle headlineXl = AppTheme.font(fontSize: 36, height: 44 / 36, fontWeight: FontWeight.w700, letterSpacing: -0.72);
  static TextStyle headlineXlMobile = AppTheme.font(fontSize: 30, height: 38 / 30, fontWeight: FontWeight.w700, letterSpacing: -0.6);
  static TextStyle headlineLg = AppTheme.font(fontSize: 26, height: 34 / 26, fontWeight: FontWeight.w700, letterSpacing: -0.39);
  static TextStyle headlineLarge = headlineLg;
  static TextStyle headlineMd = AppTheme.font(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.2);
  static TextStyle headlineMedium = headlineMd;
  static TextStyle headlineSm = AppTheme.font(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600);
  static TextStyle headlineSmall = headlineSm;
  static TextStyle amountDisplay = AppTheme.font(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w800, letterSpacing: -0.56);
  static TextStyle amountInline = AppTheme.font(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w700);
  static TextStyle titleLarge = AppTheme.font(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w700);
  static TextStyle titleMedium = AppTheme.font(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700);
  static TextStyle titleSmall = AppTheme.font(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600);
  static TextStyle bodyLg = AppTheme.font(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400);
  static TextStyle bodyLarge = bodyLg;
  static TextStyle bodyMd = AppTheme.font(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static TextStyle bodyMedium = bodyMd;
  static TextStyle bodySm = AppTheme.font(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static TextStyle bodySmall = bodySm;
  static TextStyle labelLg = AppTheme.font(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, letterSpacing: 0.14);
  static TextStyle labelLarge = labelLg;
  static TextStyle labelMd = AppTheme.font(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, letterSpacing: 0.24);
  static TextStyle labelMedium = labelMd;
  static TextStyle labelSm = AppTheme.font(fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, letterSpacing: 0.33);
  static TextStyle labelSmall = labelSm;
}

/// Elevation tokens (DESIGN.md §4).
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A0F172A), offset: Offset(0, 2), blurRadius: 8, spreadRadius: -2),
    BoxShadow(color: Color(0x080F172A), offset: Offset(0, 8), blurRadius: 16, spreadRadius: -4),
  ];
  static const List<BoxShadow> badge = [
    BoxShadow(color: Color(0x1F10B981), offset: Offset(0, 12), blurRadius: 24, spreadRadius: -6),
    BoxShadow(color: Color(0x0F0F172A), offset: Offset(0, 4), blurRadius: 12, spreadRadius: -2),
  ];
  static const List<BoxShadow> buttonGlow = [
    BoxShadow(color: Color(0x4D10B981), offset: Offset(0, 4), blurRadius: 12),
  ];
}

class AppRadius {
  static const double pill = 999;
  static const double card = 18;
  static const double input = 14;
}

class AppTheme {
  /// Disable in tests so Google Fonts doesn't attempt network fetches.
  static bool useGoogleFonts = true;

  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useGoogleFonts) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? AppPalette.dark : AppPalette.light;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.primaryFixedDim,
            onPrimary: AppColors.onPrimaryContainer,
            primaryContainer: AppColors.primary,
            onPrimaryContainer: AppColors.primaryFixed,
            secondary: AppColors.secondaryContainer,
            onSecondary: AppColors.onSecondaryContainer,
            tertiary: AppColors.tertiaryContainer,
            error: Color(0xFFFFB4AB),
            onError: Color(0xFF690005),
            errorContainer: Color(0xFF93000A),
            onErrorContainer: AppColors.errorContainer,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkOnSurface,
            onSurfaceVariant: AppColors.darkOnSurfaceVariant,
            outline: AppColors.darkOutline,
            outlineVariant: AppColors.darkOutlineVariant,
          )
        : const ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            primaryContainer: AppColors.primaryContainer,
            onPrimaryContainer: AppColors.onPrimaryContainer,
            secondary: AppColors.secondary,
            onSecondary: AppColors.onSecondary,
            secondaryContainer: AppColors.secondaryContainer,
            onSecondaryContainer: AppColors.onSecondaryContainer,
            tertiary: AppColors.tertiary,
            onTertiary: AppColors.onTertiary,
            error: AppColors.error,
            onError: AppColors.onError,
            errorContainer: AppColors.errorContainer,
            onErrorContainer: AppColors.onErrorContainer,
            surface: AppColors.surface,
            onSurface: AppColors.onSurface,
            onSurfaceVariant: AppColors.onSurfaceVariant,
            outline: AppColors.outline,
            outlineVariant: AppColors.outlineVariant,
          );

    TextStyle t(double size, FontWeight w, {double ls = 0, Color? c}) =>
        font(fontSize: size, fontWeight: w, letterSpacing: ls, color: c ?? p.onSurface);

    final textTheme = TextTheme(
      displayLarge: t(36, FontWeight.w700, ls: -0.8),
      displayMedium: t(30, FontWeight.w700, ls: -0.6),
      headlineLarge: t(26, FontWeight.w700, ls: -0.4),
      headlineMedium: t(20, FontWeight.w600, ls: -0.2),
      headlineSmall: t(18, FontWeight.w600),
      titleLarge: t(16, FontWeight.w600),
      titleMedium: t(15, FontWeight.w600),
      titleSmall: t(14, FontWeight.w600),
      bodyLarge: t(16, FontWeight.w400),
      bodyMedium: t(14, FontWeight.w400, c: p.onSurfaceVariant),
      bodySmall: t(12, FontWeight.w400, c: p.onSurfaceVariant),
      labelLarge: t(14, FontWeight.w600, ls: 0.1),
      labelMedium: t(12, FontWeight.w600, ls: 0.2, c: p.onSurfaceVariant),
      labelSmall: t(11, FontWeight.w600, ls: 0.3, c: p.outline),
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: t(18, FontWeight.w700),
        iconTheme: IconThemeData(color: p.onSurface),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.cardBorder, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceLow : AppColors.surfaceContainerLowest,
        hintStyle: t(15, FontWeight.w400, c: p.outline),
        labelStyle: t(14, FontWeight.w500, c: p.onSurfaceVariant),
        prefixIconColor: p.outline,
        suffixIconColor: p.outline,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(p.outlineVariant),
        enabledBorder: border(p.outlineVariant),
        focusedBorder: border(AppColors.primaryContainer, 1.6),
        errorBorder: border(colorScheme.error),
        focusedErrorBorder: border(colorScheme.error, 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: font(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryFixedDim : AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: isDark ? AppColors.primary : const Color(0xFFA7EBD0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: font(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryFixedDim : AppColors.primary,
          textStyle: font(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryContainer : p.surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryContainer : Colors.transparent,
        ),
        side: BorderSide(color: p.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.onSurface,
        contentTextStyle: font(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
