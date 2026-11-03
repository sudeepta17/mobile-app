import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../state/auth_state.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/common/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AuthState authState;

  const AdminDashboardScreen({super.key, required this.authState});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingLeaves = 2;
  final int _pendingAllowances = 1;
  final int _openBlockers = 1;
  final int _teamPresenceCount = 42;

  Future<void> _loadAdminData() async {
    // Refresh handler
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: AppColors.primaryOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Executive Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive Command Center',
                      style: AppTypography.footnote.copyWith(color: textSecondary),
                    ),
                    Text(
                      'Marcus Vance',
                      style: AppTypography.title2.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AppleChip(
                  label: 'Director Mode',
                  tone: ChipTone.orange,
                  icon: CupertinoIcons.shield_fill,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p20),

            // Operational Metric Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimens.p12,
              mainAxisSpacing: AppDimens.p12,
              childAspectRatio: 1.35,
              children: [
                StatCard(
                  title: 'Team Presence',
                  value: '$_teamPresenceCount / 45',
                  subtitle: '93% Present Today',
                  icon: CupertinoIcons.person_2_fill,
                  iconColor: AppColors.success,
                  iconBg: AppColors.success.withValues(alpha: 0.15),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.attendance),
                ),
                StatCard(
                  title: 'Pending Leaves',
                  value: '$_pendingLeaves Requests',
                  subtitle: 'Requires approval',
                  icon: CupertinoIcons.calendar,
                  iconColor: const Color(0xFF3B82F6),
                  iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.leaves),
                ),
                StatCard(
                  title: 'Allowance Claims',
                  value: '₹14,200',
                  subtitle: '$_pendingAllowances claims pending',
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  iconColor: AppColors.warning,
                  iconBg: AppColors.warning.withValues(alpha: 0.15),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.payroll),
                ),
                StatCard(
                  title: 'Open Blockers',
                  value: '$_openBlockers High Priority',
                  subtitle: 'Action needed',
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  iconColor: AppColors.error,
                  iconBg: AppColors.error.withValues(alpha: 0.15),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.blockers),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p24),

            // Pending Approvals Section
            Text(
              'Pending Approvals',
              style: AppTypography.title3.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.p12),

            AppleCard(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        ),
                        child: const Icon(CupertinoIcons.calendar, color: AppColors.primaryOrange, size: 20),
                      ),
                      const SizedBox(width: AppDimens.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Jenkins (ESS-0142)',
                              style: AppTypography.headline.copyWith(color: textPrimary),
                            ),
                            Text(
                              'Casual Leave • 2 days (24 Nov - 25 Nov)',
                              style: AppTypography.footnote.copyWith(color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reason: "Family gathering & personal appointment"',
                              style: AppTypography.caption1.copyWith(
                                color: textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p16),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          onPressed: () {
                            setState(() => _pendingLeaves = (_pendingLeaves > 0 ? _pendingLeaves - 1 : 0));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Leave rejected')),
                            );
                          },
                          child: Text(
                            'Reject',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.p12),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          onPressed: () {
                            setState(() => _pendingLeaves = (_pendingLeaves > 0 ? _pendingLeaves - 1 : 0));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Leave approved successfully')),
                            );
                          },
                          child: Text(
                            'Approve',
                            style: AppTypography.caption1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.p24),

            // Quick Operations
            Text(
              'Company Directories',
              style: AppTypography.title3.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.p12),
            _AdminNavRow(
              icon: CupertinoIcons.folder_fill,
              title: 'Active Projects & Milestones',
              subtitle: 'Track sprint velocities and client deliverables',
              onTap: () => Navigator.pushNamed(context, AppRoutes.projects),
            ),
            const SizedBox(height: AppDimens.p8),
            _AdminNavRow(
              icon: CupertinoIcons.time_solid,
              title: 'Shift Timings & Attendance Reports',
              subtitle: 'Biometric punches, late logs, overtime calculations',
              onTap: () => Navigator.pushNamed(context, AppRoutes.attendance),
            ),
            const SizedBox(height: AppDimens.p8),
            _AdminNavRow(
              icon: CupertinoIcons.creditcard_fill,
              title: 'Payroll & Expense Claims',
              subtitle: 'Disbursement ledgers and allowance claims',
              onTap: () => Navigator.pushNamed(context, AppRoutes.payroll),
            ),
            const SizedBox(height: AppDimens.p32),
          ],
        ),
      ),
    );
  }
}

class _AdminNavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminNavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryOrange),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headline.copyWith(color: textPrimary),
                ),
                Text(
                  subtitle,
                  style: AppTypography.footnote.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
