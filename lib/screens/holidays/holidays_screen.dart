import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/holiday_model.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';

class HolidaysScreen extends StatefulWidget {
  final AuthState? authState;

  const HolidaysScreen({super.key, this.authState});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final nextHoliday = _holidays.isNotEmpty ? _holidays.first : null;
    final nextHolidayDate = nextHoliday != null ? (DateTime.tryParse(nextHoliday.date) ?? DateTime.now()) : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.upcomingHolidays,
              authState: widget.authState!,
            )
          : null,
      appBar: AppBar(
        leading: widget.authState != null
            ? IconButton(
                icon: const Icon(CupertinoIcons.bars),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: Text(
          'Upcoming Holidays',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : RefreshIndicator(
              onRefresh: _loadHolidays,
              color: AppColors.primaryOrange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
                children: [
                  // Next Holiday Hero Banner
                  if (nextHoliday != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8590C), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8590C).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(CupertinoIcons.sparkles, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'NEXT UPCOMING HOLIDAY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nextHoliday.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (nextHolidayDate != null)
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(nextHolidayDate),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              nextHoliday.daysRemaining == 0
                                  ? 'Today!'
                                  : 'in ${nextHoliday.daysRemaining} day${nextHoliday.daysRemaining > 1 ? "s" : ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Text(
                    '2026 Holiday Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),

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
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (h.type.toLowerCase().contains('optional'))
                                        const AppleChip(
                                          label: 'Optional',
                                          tone: ChipTone.neutral,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimens.p4),
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.tryParse(h.date) ?? DateTime.now()),
                                    style: AppTypography.subhead.copyWith(color: textSecondary),
                                  ),
                                  const SizedBox(height: AppDimens.p8),
                                  Text(
                                    h.daysRemaining == 0
                                        ? 'Today!'
                                        : 'in ${h.daysRemaining} day${h.daysRemaining > 1 ? "s" : ""}',
                                    style: AppTypography.caption1.copyWith(
                                      color: isImminent ? AppColors.primaryOrange : textSecondary,
                                      fontWeight: isImminent ? FontWeight.w700 : FontWeight.w500,
                                    ),
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
