import 'package:flutter/material.dart';

/// Essane Global – Token architecture derived 1:1 from `styles.css`
///
/// Dark Theme:
/// --bg:#121417; --card:#1B1E23; --nav:#17191D; --text:#F2F3F5; --muted:#8F959E; --soft:#B4BAC3;
/// --line:rgba(255,255,255,.08); --line2:rgba(255,255,255,.12); --accent:#FF7E33; --on-accent:#121417;
/// --accent-soft:rgba(255,126,51,.14); --accent-glow:rgba(255,126,51,.16);
/// --green:#4ADE80; --green-soft:rgba(74,222,128,.14); --blue:#60A5FA; --red:#F87171; --red-soft:rgba(248,113,113,.14);
/// --chip-off:rgba(255,255,255,.08); color-scheme:dark;
///
/// Light Theme:
/// --bg:#FFFFFF; --card:#F4F5F7; --nav:#FFFFFF; --text:#14171A; --muted:#5B616B; --soft:#3F454D;
/// --line:rgba(18,20,23,.08); --line2:rgba(18,20,23,.12); --accent:#D94F00; --on-accent:#FFFFFF;
/// --accent-soft:rgba(217,79,0,.12); --accent-glow:rgba(217,79,0,.12);
/// --green:#15803D; --green-soft:rgba(21,128,61,.12); --blue:#1D6FD8; --red:#C62828; --red-soft:rgba(198,40,40,.1);
/// --chip-off:rgba(18,20,23,.07); color-scheme:light;
abstract class AppColors {
  // Brand Accents
  static const Color accentDark = Color(0xFFFF7E33);
  static const Color accentLight = Color(0xFFD94F00);
  static const Color primaryOrange = Color(0xFFFF7E33); // Shared alias
  static const Color primaryOrangeSoft = Color(0x24FF7E33); // rgba(255,126,51, 0.14)

  // On-Accent Colors
  static const Color onAccentDark = Color(0xFF121417);
  static const Color onAccentLight = Color(0xFFFFFFFF);

  // Dark Palette (html[data-theme="dark"])
  static const Color darkBackground = Color(0xFF121417);
  static const Color darkCard = Color(0xFF1B1E23);
  static const Color darkNav = Color(0xFF17191D);
  static const Color darkTextPrimary = Color(0xFFF2F3F5);
  static const Color darkMuted = Color(0xFF8F959E);
  static const Color darkSoft = Color(0xFFB4BAC3);
  static const Color darkLine = Color(0x14FFFFFF);      // rgba(255,255,255, 0.08)
  static const Color darkLine2 = Color(0x1FFFFFFF);     // rgba(255,255,255, 0.12)
  static const Color darkChipOff = Color(0x14FFFFFF);   // rgba(255,255,255, 0.08)
  static const Color darkAccentSoft = Color(0x24FF7E33); // rgba(255,126,51, 0.14)
  static const Color darkAccentGlow = Color(0x29FF7E33); // rgba(255,126,51, 0.16)

  // Dark Status Colors
  static const Color darkGreen = Color(0xFF4ADE80);
  static const Color darkGreenSoft = Color(0x244ADE80);  // rgba(74,222,128, 0.14)
  static const Color darkBlue = Color(0xFF60A5FA);
  static const Color darkRed = Color(0xFFF87171);
  static const Color darkRedSoft = Color(0x24F87171);    // rgba(248,113,113, 0.14)

  // Light Palette (html[data-theme="light"])
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F5F7);
  static const Color lightNav = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF14171A);
  static const Color lightMuted = Color(0xFF5B616B);
  static const Color lightSoft = Color(0xFF3F454D);
  static const Color lightLine = Color(0x14121417);      // rgba(18,20,23, 0.08)
  static const Color lightLine2 = Color(0x1F121417);     // rgba(18,20,23, 0.12)
  static const Color lightChipOff = Color(0x12121417);   // rgba(18,20,23, 0.07)
  static const Color lightAccentSoft = Color(0x1FD94F00);// rgba(217,79,0, 0.12)
  static const Color lightAccentGlow = Color(0x1FD94F00);// rgba(217,79,0, 0.12)

  // Light Status Colors
  static const Color lightGreen = Color(0xFF15803D);
  static const Color lightGreenSoft = Color(0x1F15803D); // rgba(21,128,61, 0.12)
  static const Color lightBlue = Color(0xFF1D6FD8);
  static const Color lightRed = Color(0xFFC62828);
  static const Color lightRedSoft = Color(0x1AC62828);   // rgba(198,40,40, 0.1)

  // Status & Semantic Colors (defaults / shared)
  static const Color green = darkGreen;
  static const Color greenSoft = darkGreenSoft;
  static const Color blue = darkBlue;
  static const Color blueSoft = Color(0x2460A5FA);
  static const Color red = darkRed;
  static const Color redSoft = darkRedSoft;
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0x24F59E0B);

  // Dialog Backdrop
  static const Color dialogBackdrop = Color(0x8C000000); // rgba(0,0,0, 0.55)

  // Backward compatibility aliases
  static const Color lightSurface = lightCard;
  static const Color lightSurfaceSecondary = lightCard;
  static const Color lightBorder = lightLine;
  static const Color lightDivider = lightLine;
  static const Color lightTextSecondary = lightMuted;
  static const Color lightTextTertiary = lightSoft;

  static const Color darkSurface = darkCard;
  static const Color darkSurfaceSecondary = darkCard;
  static const Color darkBorder = darkLine;
  static const Color darkDivider = darkLine;
  static const Color darkTextSecondary = darkMuted;
  static const Color darkTextTertiary = darkSoft;

  static const Color success = green;
  static const Color successSoftLight = lightGreenSoft;
  static const Color successSoftDark = darkGreenSoft;

  static const Color error = red;
  static const Color errorSoftLight = lightRedSoft;
  static const Color errorSoftDark = darkRedSoft;

  static const Color info = blue;
  static const Color infoSoftLight = blueSoft;
  static const Color infoSoftDark = blueSoft;

  static const Color warningSoftLight = warningSoft;
  static const Color warningSoftDark = warningSoft;

  /// Helper to get current dynamic tokens based on Brightness
  static AppColorsBundle of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColorsBundle.dark : AppColorsBundle.light;
  }
}

/// Dynamic Token Bundle representing CSS variables for the active theme
class AppColorsBundle {
  final Color bg;
  final Color card;
  final Color nav;
  final Color text;
  final Color muted;
  final Color soft;
  final Color line;
  final Color line2;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color accentGlow;
  final Color green;
  final Color greenSoft;
  final Color blue;
  final Color red;
  final Color redSoft;
  final Color chipOff;

  const AppColorsBundle({
    required this.bg,
    required this.card,
    required this.nav,
    required this.text,
    required this.muted,
    required this.soft,
    required this.line,
    required this.line2,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.accentGlow,
    required this.green,
    required this.greenSoft,
    required this.blue,
    required this.red,
    required this.redSoft,
    required this.chipOff,
  });

  static const dark = AppColorsBundle(
    bg: AppColors.darkBackground,
    card: AppColors.darkCard,
    nav: AppColors.darkNav,
    text: AppColors.darkTextPrimary,
    muted: AppColors.darkMuted,
    soft: AppColors.darkSoft,
    line: AppColors.darkLine,
    line2: AppColors.darkLine2,
    accent: AppColors.accentDark,
    onAccent: AppColors.onAccentDark,
    accentSoft: AppColors.darkAccentSoft,
    accentGlow: AppColors.darkAccentGlow,
    green: AppColors.darkGreen,
    greenSoft: AppColors.darkGreenSoft,
    blue: AppColors.darkBlue,
    red: AppColors.darkRed,
    redSoft: AppColors.darkRedSoft,
    chipOff: AppColors.darkChipOff,
  );

  static const light = AppColorsBundle(
    bg: AppColors.lightBackground,
    card: AppColors.lightCard,
    nav: AppColors.lightNav,
    text: AppColors.lightTextPrimary,
    muted: AppColors.lightMuted,
    soft: AppColors.lightSoft,
    line: AppColors.lightLine,
    line2: AppColors.lightLine2,
    accent: AppColors.accentLight,
    onAccent: AppColors.onAccentLight,
    accentSoft: AppColors.lightAccentSoft,
    accentGlow: AppColors.lightAccentGlow,
    green: AppColors.lightGreen,
    greenSoft: AppColors.lightGreenSoft,
    blue: AppColors.lightBlue,
    red: AppColors.lightRed,
    redSoft: AppColors.lightRedSoft,
    chipOff: AppColors.lightChipOff,
  );
}
