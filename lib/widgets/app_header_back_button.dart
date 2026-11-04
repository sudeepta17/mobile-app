import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';

/// Reusable header back button placed on the right side of page headers,
/// matching the exact dimensions, border radius, and card styling of the
/// left hamburger button.
class AppHeaderBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppHeaderBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (onPressed != null) {
          onPressed!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.main);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          CupertinoIcons.arrow_left,
          size: 20,
          color: textPrimary,
        ),
      ),
    );
  }
}

