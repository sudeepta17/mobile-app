import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final AuthState authState;
  final ValueChanged<int>? onNavigateTab;

  const EmployeeDashboardScreen({
    super.key,
    required this.authState,
    this.onNavigateTab,
  });

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  bool _isCheckedIn = false;
  String _checkInTimeStr = '';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final attendance = await services.attendanceService.getAttendanceData();
      if (mounted) {
        setState(() {
          _isCheckedIn = attendance.today.isCheckedIn;
          _checkInTimeStr = attendance.today.checkInTime ?? '09:28 AM';
        });
      }
    } catch (_) {}
  }

  void _toggleCheckIn() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      if (_isCheckedIn) {
        _checkInTimeStr = DateFormat('hh:mm a').format(DateTime.now());
      }
    });
    services.attendanceService.punchAttendance();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getTodayFormatted() {
    final now = DateTime.now();
    return 'Today · ${DateFormat('EEE, d MMM').format(now)}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'EN';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final textSoft = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;
    final chipOff = isDark ? AppColors.darkChipOff : AppColors.lightChipOff;

    final user = widget.authState.currentUser;
    final userName = user?.name ?? 'Sarah Jenkins';
    final userInitials = _getInitials(userName);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top Ambient Glow from styles.css: radial-gradient(circle at 85% 0, var(--accent-glow) 0%, transparent 65%)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 300,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -1.0),
                    radius: 0.85,
                    colors: [
                      accentGlow,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
          ),

          // Main Page Content
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
              children: [
                // 1. Header (dashboard.html line 22)
                Row(
                  children: [
                    // Avatar circle with initials
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userInitials,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accent,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Greeting and Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 12,
                              color: textMuted,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notifications Icon Button with badge dot
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol2, width: 1.0),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(CupertinoIcons.bell, size: 20, color: textPrimary),
                            // Orange notification badge dot
                            Positioned(
                              top: 10,
                              right: 11,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bg, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Check-in Section (dashboard.html line 28)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTodayFormatted(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isCheckedIn
                                    ? 'Checked in at $_checkInTimeStr'
                                    : 'You are not checked in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          // Chip pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isCheckedIn ? AppColors.greenSoft : chipOff,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _isCheckedIn ? 'Working' : 'Off the clock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _isCheckedIn ? AppColors.green : textSoft,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Check in / Check out Action Button
                      GestureDetector(
                        onTap: _toggleCheckIn,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(
                            color: _isCheckedIn ? Colors.transparent : accent,
                            borderRadius: BorderRadius.circular(14),
                            border: _isCheckedIn
                                ? Border.all(color: accent, width: 1.5)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _isCheckedIn ? 'Check out' : 'Check in',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _isCheckedIn ? accent : (isDark ? const Color(0xFF121417) : Colors.white),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Summary Grid 2x2 (dashboard.html line 36)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricTile(
                      icon: CupertinoIcons.calendar,
                      label: 'Attendance',
                      value: '96%',
                      onTap: () => widget.onNavigateTab?.call(3), // Leave tab
                    ),
                    _MetricTile(
                      icon: CupertinoIcons.clock,
                      label: 'Hours this week',
                      value: '32.5',
                      unit: 'h',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.attendance),
                    ),
                    _MetricTile(
                      icon: CupertinoIcons.briefcase,
                      label: 'Leave balance',
                      value: '12',
                      unit: 'days',
                      onTap: () => widget.onNavigateTab?.call(3), // Leave tab
                    ),
                    _MetricTile(
                      icon: CupertinoIcons.checkmark_square,
                      label: 'Tasks due',
                      value: '3',
                      onTap: () => widget.onNavigateTab?.call(1), // Tasks tab
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Today's Tasks Section (dashboard.html line 43)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's tasks",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(1); // Go to Tasks tab
                            } else {
                              Navigator.pushNamed(context, AppRoutes.tasks);
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.centerRight,
                            child: Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 12,
                                color: accent,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Tasks List
                    _TaskRowItem(
                      dotColor: accent,
                      title: 'Submit weekly timesheet',
                      subtitle: 'Due today, 5:00 PM',
                      status: 'Pending',
                      statusColor: accent,
                    ),
                    const SizedBox(height: 10),
                    _TaskRowItem(
                      dotColor: AppColors.blue,
                      title: 'Review project brief',
                      subtitle: 'Team Alpha',
                      status: 'In progress',
                      statusColor: AppColors.blue,
                    ),
                    const SizedBox(height: 10),
                    _TaskRowItem(
                      dotColor: textMuted,
                      title: 'Update client records',
                      subtitle: 'Due tomorrow',
                      status: 'Upcoming',
                      statusColor: textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    color: textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: textMuted,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRowItem extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _TaskRowItem({
    required this.dotColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                    height: 1.35,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
