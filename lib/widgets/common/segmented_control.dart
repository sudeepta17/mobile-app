import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';

class AppleSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;

  const AppleSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final activeBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: children.entries.map((entry) {
          final isSelected = entry.key == groupValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(entry.key),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  style: AppTypography.footnote.copyWith(
                    color: isSelected ? textPrimary : textPrimary.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
