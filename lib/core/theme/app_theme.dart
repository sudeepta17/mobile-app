import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Essane Global – ThemeData mirroring styles.css directly
abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accentLight,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight,
        onPrimary: AppColors.onAccentLight,
        secondary: AppColors.lightTextPrimary,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightRed,
        onError: Colors.white,
        outline: AppColors.lightLine,
      ),
      fontFamily: AppTypography.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.lightLine, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightLine,
        thickness: 1.0,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.input.copyWith(color: AppColors.lightMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.lightLine2, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.lightLine2, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.accentLight, width: 2.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.dialogRadius),
          side: const BorderSide(color: AppColors.lightLine2, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightBackground,
        modalBackgroundColor: AppColors.lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.dialogRadius)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.lightLine2,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accentDark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark,
        onPrimary: AppColors.onAccentDark,
        secondary: AppColors.darkTextPrimary,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkRed,
        onError: Colors.white,
        outline: AppColors.darkLine,
      ),
      fontFamily: AppTypography.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.darkLine, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkLine,
        thickness: 1.0,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.input.copyWith(color: AppColors.darkMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.darkLine2, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.darkLine2, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusBtn),
          borderSide: const BorderSide(color: AppColors.accentDark, width: 2.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.dialogRadius),
          side: const BorderSide(color: AppColors.darkLine2, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBackground,
        modalBackgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.dialogRadius)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.darkLine2,
      ),
    );
  }
}
