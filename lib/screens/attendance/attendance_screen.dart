import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/attendance_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/common/stat_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceDataBundle? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_data == null) setState(() => _isLoading = true);
    final data = await services.attendanceService.getAttendanceData();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePunch() async {
    HapticFeedback.mediumImpact();
    await services.attendanceService.punchAttendance();
    _loadData();
  }

  Future<void> _toggleGym() async {
    HapticFeedback.lightImpact();
    await services.attendanceService.gymCheckIn();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (_isLoading || _data == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    final d = _data!;
    final today = d.today;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Attendance & Shifts',
          style: AppTypography.title2.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryOrange,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
          children: [
            // Live Punch Clock Card
            AppleCard(
              hasGlow: today.isCheckedIn,
              padding: const EdgeInsets.all(AppDimens.p20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY • 02 NOV 2026',
                            style: AppTypography.caption2.copyWith(
                              color: textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            today.isCheckedIn ? 'Currently Working' : 'Off the Clock',
                            style: AppTypography.headline.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      AppleChip(
                        label: today.isCheckedIn ? 'Checked In' : 'Punched Out',
                        tone: today.isCheckedIn ? ChipTone.green : ChipTone.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p20),

                  // Digital Clock representation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          today.workedHours,
                          style: AppTypography.largeTitle.copyWith(
                            color: textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Text(
                          today.shift,
                          style: AppTypography.footnote.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.p20),

                  Row(
                    children: [
                      Expanded(
                        child: AppleButton(
                          label: today.isCheckedIn ? 'Swipe to Punch Out' : 'Punch In Now',
                          icon: today.isCheckedIn ? CupertinoIcons.square : CupertinoIcons.play_fill,
                          variant: today.isCheckedIn
                              ? AppleButtonVariant.secondary
                              : AppleButtonVariant.primary,
                          onPressed: _togglePunch,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.p20),

            // Gym Buddy Check-in
            AppleCard(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF5722), size: 24),
                  ),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Gym Entry',
                          style: AppTypography.headline.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          today.gymCheckedIn
                              ? 'Logged at ${today.gymCheckInTime ?? "07:15 AM"} • Streak: ${today.gymStreak} days'
                              : 'Log your session today to maintain streak',
                          style: AppTypography.caption1.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: today.gymCheckedIn,
                    activeTrackColor: AppColors.primaryOrange,
                    onChanged: (_) => _toggleGym(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.p20),

            // Monthly Summary Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimens.p12,
              mainAxisSpacing: AppDimens.p12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: 'Present Days',
                  value: '${d.presentDays} / ${d.workingDays}',
                  subtitle: '95% presence',
                  icon: CupertinoIcons.checkmark_seal_fill,
                  iconColor: AppColors.success,
                  iconBg: AppColors.success.withValues(alpha: 0.15),
                ),
                StatCard(
                  title: 'Overtime Logged',
                  value: d.overtimeHours,
                  subtitle: 'Approved for payout',
                  icon: CupertinoIcons.timer,
                  iconColor: AppColors.primaryOrange,
                  iconBg: AppColors.primaryOrange.withValues(alpha: 0.15),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p24),

            // Recent Punch Logs
            Text(
              'Past Shift Logs',
              style: AppTypography.title3.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.p12),

            ...d.recentLogs.map((log) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.p8),
                child: AppleCard(
                  padding: const EdgeInsets.all(AppDimens.p14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.day}, ${log.date}',
                            style: AppTypography.subhead.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'In: ${log.checkIn} • Out: ${log.checkOut}',
                            style: AppTypography.caption1.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (log.gym)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(CupertinoIcons.flame_fill, size: 12, color: Color(0xFFFF5722)),
                            ),
                          AppleChip(
                            label: log.hours,
                            tone: ChipTone.neutral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

