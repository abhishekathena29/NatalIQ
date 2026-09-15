import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens and theme, ported 1:1 from the React app's `styles.css`
/// (oklch custom properties converted to sRGB).
class AppColors {
  AppColors._();

  static const background = Color(0xFFFFF9F2);
  static const foreground = Color(0xFF38221F);

  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF38221F);

  static const popover = Color(0xFFFFFDFA);
  static const popoverForeground = Color(0xFF38221F);

  static const primary = Color(0xFFBF525A);
  static const primaryForeground = Color(0xFFFEFBF8);

  static const secondary = Color(0xFFFDEBDF);
  static const secondaryForeground = Color(0xFF52302D);

  static const muted = Color(0xFFFAEEE3);
  static const mutedForeground = Color(0xFF7E615B);

  static const accent = Color(0xFFC0E3C0);
  static const accentForeground = Color(0xFF1D341E);

  static const blush = Color(0xFFFDC8CB);
  static const blushForeground = Color(0xFF61232B);

  static const peach = Color(0xFFFED4B9);
  static const peachForeground = Color(0xFF5C2B13);

  static const sage = Color(0xFFC0DABB);
  static const sageForeground = Color(0xFF223A23);

  static const destructive = Color(0xFFDF2225);
  static const destructiveForeground = Color(0xFFFEFBF8);

  static const border = Color(0xFFE9DBD2);
  static const input = Color(0xFFF6E8DF);
  static const ring = Color(0xFFC46668);

  // Gradient stops.
  static const gradientWarmStart = Color(0xFFFFEDE0);
  static const gradientWarmEnd = Color(0xFFFFDDD6);
  static const gradientBlushStart = Color(0xFFFEBAB4);
  static const gradientBlushEnd = Color(0xFFF59AA1);
  static const gradientSageStart = Color(0xFFC0DABB);
  static const gradientSageEnd = Color(0xFF9CC49C);

  static const shadowSoft = Color(0x26B45A3C); // rgba(180,90,60,0.15)
  static const shadowCard = Color(0x1A8C5E19);
}

const appGradientWarm = LinearGradient(
  begin: Alignment(-0.6, -1),
  end: Alignment(0.6, 1),
  colors: [AppColors.gradientWarmStart, AppColors.gradientWarmEnd],
);

const appGradientBlush = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.gradientBlushStart, AppColors.gradientBlushEnd],
);

const appGradientSage = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.gradientSageStart, AppColors.gradientSageEnd],
);

/// tone helper mirroring the repeated `blush | peach | sage` inline styles.
enum AppTone { blush, peach, sage }

extension AppToneColors on AppTone {
  Color get background => switch (this) {
        AppTone.blush => AppColors.blush,
        AppTone.peach => AppColors.peach,
        AppTone.sage => AppColors.sage,
      };

  Color get foreground => switch (this) {
        AppTone.blush => AppColors.blushForeground,
        AppTone.peach => AppColors.peachForeground,
        AppTone.sage => AppColors.sageForeground,
      };
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const x2l = 24.0;
  static const x3l = 28.0;
  static const x4l = 32.0;
}

TextStyle displayFont({
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.w600,
  Color? color,
  double? height,
}) {
  return GoogleFonts.fraunces(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.foreground,
    letterSpacing: -0.2,
    height: height,
  );
}

TextStyle sansFont({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.nunito(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.foreground,
    letterSpacing: letterSpacing,
    height: height,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
    ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme(),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  return base.copyWith(
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: Color(0x33BF525A),
      selectionHandleColor: AppColors.primary,
    ),
  );
}
