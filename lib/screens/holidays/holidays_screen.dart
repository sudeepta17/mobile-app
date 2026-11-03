import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/holiday_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/layout/apple_scaffold.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  List<HolidayModel> _holidays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    setState(() => _isLoading = true);
    final list = await services.holidayService.getUpcomingHolidays();
    if (mounted) {
      setState(() {
        _holidays = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AppleScaffold(
      title: 'Company Holidays',
      subtitle: 'Official calendar & festive schedule',
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : RefreshIndicator(
              onRefresh: _loadHolidays,
              color: AppColors.primaryOrange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
                children: [
                  ..._holidays.map((h) {
                    final isImminent = h.daysRemaining <= 7;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.p12),
                      child: AppleCard(
                        hasGlow: isImminent,
                        padding: const EdgeInsets.all(AppDimens.p16),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isImminent
                                    ? AppColors.primaryOrange.withValues(alpha: 0.15)
                                    : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary),
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.sparkles,
                                  size: 26,
                                  color: isImminent ? AppColors.primaryOrange : textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.p16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          h.name,
                                          style: AppTypography.headline.copyWith(
                                            color: textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      AppleChip(
                                        label: h.daysRemaining == 0
                                            ? 'Today!'
                                            : 'In ${h.daysRemaining} days',
                                        tone: isImminent ? ChipTone.orange : ChipTone.neutral,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${h.day}, ${h.date}',
                                    style: AppTypography.subhead.copyWith(
                                      color: isImminent ? AppColors.primaryOrange : textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    h.type,
                                    style: AppTypography.caption2.copyWith(color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

