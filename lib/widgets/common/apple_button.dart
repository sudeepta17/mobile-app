import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

enum AppleButtonVariant { primary, secondary, outline, destructive }

class AppleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppleButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppleButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppleButtonVariant.primary:
        bg = AppColors.primaryOrange;
        fg = Colors.white;
        break;
      case AppleButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case AppleButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        );
        break;
      case AppleButtonVariant.destructive:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        color: bg,
        disabledColor: bg.withValues(alpha: 0.5),
        onPressed: (isLoading || onPressed == null)
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: border,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: fg),
                      const SizedBox(width: AppDimens.p8),
                    ],
                    Text(
                      label,
                      style: AppTypography.subhead.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

