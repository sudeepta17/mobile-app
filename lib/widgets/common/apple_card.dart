import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

class AppleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;
  final bool hasGlow;

  const AppleCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final radius = borderRadius ?? AppDimens.radiusLg;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppDimens.p16),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: defaultBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: AppDimens.blurCard,
            offset: const Offset(0, 4),
          ),
          if (hasGlow)
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primaryOrange.withValues(alpha: 0.1),
          highlightColor: AppColors.primaryOrange.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}

