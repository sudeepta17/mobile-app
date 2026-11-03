import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

enum ChipTone { orange, green, red, amber, blue, neutral }

class AppleChip extends StatelessWidget {
  final String label;
  final ChipTone tone;
  final IconData? icon;
  final VoidCallback? onTap;

  const AppleChip({
    super.key,
    required this.label,
    this.tone = ChipTone.orange,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    switch (tone) {
      case ChipTone.orange:
        bg = isDark ? const Color(0xFF381B09) : AppColors.primaryOrangeSoft;
        fg = AppColors.primaryOrange;
        break;
      case ChipTone.green:
        bg = isDark ? AppColors.successSoftDark : AppColors.successSoftLight;
        fg = AppColors.success;
        break;
      case ChipTone.red:
        bg = isDark ? AppColors.errorSoftDark : AppColors.errorSoftLight;
        fg = AppColors.error;
        break;
      case ChipTone.amber:
        bg = isDark ? AppColors.warningSoftDark : AppColors.warningSoftLight;
        fg = AppColors.warning;
        break;
      case ChipTone.blue:
        bg = isDark ? AppColors.infoSoftDark : AppColors.infoSoftLight;
        fg = AppColors.info;
        break;
      case ChipTone.neutral:
        bg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        break;
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

