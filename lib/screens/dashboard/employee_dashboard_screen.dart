import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/employee_shift_model.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

/// Employee Dashboard Screen mirroring https://essaneglobal.com/management/employee/dashboard
/// from mmanagement & newmanagement:
/// - Workspace greeting with Refresh & View history actions
/// - Today's Shift & Live Punch Attendance Card
/// - Pending Blockers Alert Banner with "Respond Now"
/// - Annual Progress Timeline with ticking live clock and countdown metrics
/// - 4 Key Insight Metric Cards (Total requests, Pending, Approved, Rejected)
/// - Request Status Donut Chart & Leave Overview breakdown
/// - Personal Pulse (Allowance, Salary Advance, Gym Streak, Next Holiday countdown)
/// - Quick Actions Hub (Blockers, Apply Leave, Allowance, Advance, Shift, Gym Check-in)
/// - Recent Activity Feed with status badges
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardSummaryModel? _summary;
  bool _isLoading = true;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  DateTime get _now => _currentTime;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initTimer();
    _loadDashboardData();
  }

  void _initTimer() {
    _clockTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final summary = await services.dashboardService.getDashboardSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGymCheckIn() async {
    HapticFeedback.selectionClick();
    await services.dashboardService.punchGymCheckIn();
    await _loadDashboardData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym check-in logged! Streak updated.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
    _initTimer();
    final now = _now;

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

    final user = widget.authState.currentUser;
    final userName = _summary?.profile.name ?? user?.name ?? 'Sarah Jenkins';
    final userInitials = _getInitials(userName);
    final employeeCode = _summary?.profile.employeeCode ?? user?.employeeCode ?? 'ESS-0142';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentItem: SidebarItemKey.dashboard,
        authState: widget.authState,
      ),
      backgroundColor: bg,
      body: Stack(
        children: [
          // Fluid ribbon wallpaper in light mode
          if (!isDark)
            Positioned.fill(
              child: Opacity(
                opacity: 0.65,
                child: Image.asset(
                  'assets/images/app_background.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Top ambient glow
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 320,
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

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: accent,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
                children: [
                  // 1. Header (Menu Hamburger, Avatar, Workspace Greeting, Refresh, Notifications)
                  Row(
                    children: [
                      // Sidebar Drawer Toggle Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.bars,
                            size: 22,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accentSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          userInitials,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: TextStyle(
                                fontSize: 12,
                                color: textMuted,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh button
                      GestureDetector(
                        onTap: _loadDashboardData,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: borderCol2, width: 1.0),
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accent,
                                  ),
                                )
                              : Icon(CupertinoIcons.arrow_clockwise, size: 18, color: textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notifications button
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: borderCol2, width: 1.0),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(CupertinoIcons.bell, size: 20, color: textPrimary),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: bg, width: 1.5),
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

                  // 2. Shift & Live Punch Attendance Card mirroring EmployeeShiftService.php & AttendanceShiftReports.tsx
                  Builder(
                    builder: (ctx) {
                      final shift = services.shiftService.activeShift;
                      final isWorking = shift != null && shift.status == ShiftStatus.active;
                      final isOnBreak = shift != null && shift.status == ShiftStatus.onBreak;
                      final isPowerOut = shift != null && shift.status == ShiftStatus.powerOut;
                      final isOff = shift == null;

                      Color statusBadgeBg;
                      Color statusBadgeText;
                      String statusLabel;

                      if (isWorking) {
                        statusBadgeBg = AppColors.greenSoft;
                        statusBadgeText = AppColors.green;
                        statusLabel = 'WORKING';
                      } else if (isOnBreak) {
                        statusBadgeBg = const Color(0x26F59E0B);
                        statusBadgeText = const Color(0xFFF59E0B);
                        statusLabel = 'ON BREAK';
                      } else if (isPowerOut) {
                        statusBadgeBg = const Color(0x26DC2626);
                        statusBadgeText = const Color(0xFFDC2626);
                        statusLabel = 'POWER CUT';
                      } else {
                        statusBadgeBg = isDark ? const Color(0xFF26292E) : const Color(0xFFE2E8F0);
                        statusBadgeText = textMuted;
                        statusLabel = 'OFF THE CLOCK';
                      }

                      final elapsedMinutes = shift != null
                          ? now.difference(shift.loginAt).inMinutes
                          : 0;
                      final elapsedHours = elapsedMinutes ~/ 60;
                      final elapsedMins = elapsedMinutes % 60;
                      final elapsedStr = elapsedHours > 0
                          ? '${elapsedHours}h ${elapsedMins}m'
                          : '${elapsedMins}m';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.clock, size: 14, color: textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Shift: 11:00 AM – 08:00 PM IST',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: statusBadgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: statusBadgeText,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: statusBadgeText,
                                          letterSpacing: 0.4,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isOff
                                          ? 'You are off the clock'
                                          : '$elapsedStr elapsed today',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isOff
                                          ? 'Punch in when starting your daily shift'
                                          : 'Logged in at ${DateFormat('hh:mm a').format(shift.loginAt)}${shift.delayMinutes > 0 ? " (${shift.delayMinutes}m late)" : " (on time)"}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isOff ? textMuted : (shift.delayMinutes > 0 ? const Color(0xFFF59E0B) : textMuted),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.attendanceReports),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Reports',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: accent,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(CupertinoIcons.chevron_right, size: 10, color: accent),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Controls
                            if (isOff)
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(CupertinoIcons.play_fill, size: 15, color: Colors.white),
                                  label: const Text(
                                    'Start Daily Shift (Punch In)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    await services.shiftService.startShift();
                                    if (mounted) setState(() {});
                                  },
                                ),
                              )
                            else ...[
                              Row(
                                children: [
                                  // Break toggle
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isOnBreak ? Colors.white : textPrimary,
                                        backgroundColor: isOnBreak ? const Color(0xFFF59E0B) : Colors.transparent,
                                        side: BorderSide(color: isOnBreak ? const Color(0xFFF59E0B) : borderCol),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      icon: Icon(
                                        isOnBreak ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
                                        size: 13,
                                      ),
                                      label: Text(
                                        isOnBreak ? 'Resume' : 'Break',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.selectionClick();
                                        await services.shiftService.toggleBreak();
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Power cut toggle
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isPowerOut ? Colors.white : textPrimary,
                                        backgroundColor: isPowerOut ? const Color(0xFFDC2626) : Colors.transparent,
                                        side: BorderSide(color: isPowerOut ? const Color(0xFFDC2626) : borderCol),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      icon: const Icon(CupertinoIcons.bolt_fill, size: 13),
                                      label: Text(
                                        isPowerOut ? 'Power OK' : 'Power Cut',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.selectionClick();
                                        await services.shiftService.togglePower();
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Clock Out button
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      icon: const Icon(CupertinoIcons.square_arrow_right, size: 13, color: Colors.white),
                                      label: const Text(
                                        'Clock Out',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        await services.shiftService.endShift();
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // Undo action button if within 2 minutes
                              if (shift.canUndo) ...[
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    await services.shiftService.undoLastAction();
                                    if (mounted) setState(() {});
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0x1AF59E0B),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0x40F59E0B)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(CupertinoIcons.arrow_counterclockwise, size: 12, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Undo last action (${shift.lastActionName ?? ""})',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  // 3. Pending Blockers Alert Banner (if pending blockers exist)
                  if ((_summary?.blockers.pendingCount ?? 0) > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x1DF59E0B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x4DF59E0B), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0x33F59E0B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.exclamationmark_triangle_fill,
                              size: 18,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_summary!.blockers.pendingCount} pending blocker${_summary!.blockers.pendingCount > 1 ? 's' : ''} awaiting you',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Colleagues need urgent unblocking help.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.blockers),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Respond',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 4. Annual Progress Timeline (YearProgressCard from newmanagement)
                  _YearProgressWidget(
                    currentTime: now,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    accent: accent,
                  ),

                  const SizedBox(height: 20),

                  // 5. Four Insight Metric Cards (Total requests, Pending, Approved, Rejected)
                  Row(
                    children: [
                      Expanded(
                        child: _InsightTile(
                          label: 'TOTAL REQUESTS',
                          value: '${_summary?.requests.total ?? 18}',
                          detail: 'This year',
                          icon: CupertinoIcons.doc_text,
                          color: accent,
                          cardBg: cardBg,
                          borderCol: borderCol,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InsightTile(
                          label: 'PENDING',
                          value: '${_summary?.requests.pending ?? 3}',
                          detail: 'Awaiting review',
                          icon: CupertinoIcons.clock,
                          color: const Color(0xFFD97706),
                          cardBg: cardBg,
                          borderCol: borderCol,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InsightTile(
                          label: 'APPROVED',
                          value: '${_summary?.requests.approved ?? 13}',
                          detail: 'Moving forward',
                          icon: CupertinoIcons.checkmark_circle,
                          color: AppColors.green,
                          cardBg: cardBg,
                          borderCol: borderCol,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InsightTile(
                          label: 'REJECTED',
                          value: '${_summary?.requests.rejected ?? 2}',
                          detail: 'Needs attention',
                          icon: CupertinoIcons.xmark_circle,
                          color: const Color(0xFFDC2626),
                          cardBg: cardBg,
                          borderCol: borderCol,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 6. Request Status Donut & Leave Overview
                  _RequestAndLeaveOverview(
                    summary: _summary,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    textSoft: textSoft,
                    accent: accent,
                    onTapLeaveHistory: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(3); // Leave tab
                      } else {
                        Navigator.pushNamed(context, AppRoutes.leaves);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // 7. Personal Pulse (Money & Wellness Activity)
                  _PersonalPulseSection(
                    summary: _summary,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    accent: accent,
                    currencyFormat: _currencyFormat,
                    onGymCheckIn: _handleGymCheckIn,
                  ),

                  const SizedBox(height: 24),

                  // 8. Quick Actions Grid
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [
                      _QuickActionTile(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        label: 'Blockers',
                        detail: 'Resolve obstacles',
                        color: const Color(0xFFD97706),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.blockers),
                      ),
                      _QuickActionTile(
                        icon: CupertinoIcons.calendar_badge_plus,
                        label: 'Apply Leave',
                        detail: 'Plan time away',
                        color: accent,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(3);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.leaves);
                          }
                        },
                      ),
                      _QuickActionTile(
                        icon: CupertinoIcons.money_dollar,
                        label: 'Allowance',
                        detail: 'Upload claim',
                        color: const Color(0xFF2563EB),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.payroll),
                      ),
                      _QuickActionTile(
                        icon: CupertinoIcons.creditcard,
                        label: 'Salary Advance',
                        detail: 'Request support',
                        color: const Color(0xFF7C3AED),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.payroll),
                      ),
                      _QuickActionTile(
                        icon: CupertinoIcons.clock,
                        label: 'Attendance & Shift',
                        detail: 'Review shift activity',
                        color: const Color(0xFF0D9488),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.attendanceReports),
                      ),
                      _QuickActionTile(
                        icon: CupertinoIcons.heart_fill,
                        label: 'Gym Check-in',
                        detail: 'Log workout',
                        color: AppColors.green,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        onTap: _handleGymCheckIn,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 9. Recent Activity Feed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Last updates',
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_summary?.recentActivity.isNotEmpty ?? false)
                    ..._summary!.recentActivity.map((activity) => _ActivityRowItem(
                          item: activity,
                          cardBg: cardBg,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          accent: accent,
                        ))
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol, width: 1.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No recent activity recorded.',
                        style: TextStyle(fontSize: 13, color: textMuted, fontFamily: 'Poppins'),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 10. Footer with Employee ID
                  Center(
                    child: Text(
                      'Employee ID: $employeeCode · Last updated just now',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Year Progress Card reproducing YearProgressCard.tsx
class _YearProgressWidget extends StatelessWidget {
  final DateTime? currentTime;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;

  const _YearProgressWidget({
    this.currentTime,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final time = currentTime ?? DateTime.now();
    final year = time.year;
    final yearStart = DateTime(year, 1, 1);
    final yearEnd = DateTime(year, 12, 31, 23, 59, 59);
    final totalDays = DateTime(year, 12, 31).difference(yearStart).inDays + 1;
    final dayOfYear = time.difference(yearStart).inDays + 1;
    final daysRemaining = totalDays - dayOfYear;
    final yearPercent = ((time.millisecondsSinceEpoch - yearStart.millisecondsSinceEpoch) /
            (yearEnd.millisecondsSinceEpoch - yearStart.millisecondsSinceEpoch))
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONAL TIMELINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: accent,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Annual Progress $year',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('hh:mm:ss a').format(time),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      fontFamily: 'Courier',
                    ),
                  ),
                  Text(
                    DateFormat('EEE, d MMM').format(time),
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Completion Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(yearPercent * 100).toStringAsFixed(1)}% complete',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                '$daysRemaining days remaining',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: yearPercent,
              minHeight: 8,
              backgroundColor: const Color(0x1AE8590C),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),

          // Sub-metrics (Day of year & Month progress)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $dayOfYear of $totalDays',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Month: ${DateFormat('MMMM').format(time)} (${time.day}/${DateUtils.getDaysInMonth(year, time.month)})',
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Insight Card for Top Metrics
class _InsightTile extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final Color cardBg;
  final Color borderCol;

  const _InsightTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    required this.cardBg,
    required this.borderCol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

/// Request Status Donut Chart & Leave Overview
class _RequestAndLeaveOverview extends StatelessWidget {
  final DashboardSummaryModel? summary;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final Color textSoft;
  final Color accent;
  final VoidCallback onTapLeaveHistory;

  const _RequestAndLeaveOverview({
    required this.summary,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.textSoft,
    required this.accent,
    required this.onTapLeaveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final approved = summary?.requests.approved ?? 13;
    final pending = summary?.requests.pending ?? 3;
    final rejected = summary?.requests.rejected ?? 2;
    final total = summary?.requests.total ?? (approved + pending + rejected);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.chart_pie, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    'Leave & Requests Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onTapLeaveHistory,
                child: Text(
                  'View history',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Donut and Summary Row
          Row(
            children: [
              // Custom Donut Ring
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    approved: approved,
                    pending: pending,
                    rejected: rejected,
                    total: total,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 9,
                            color: textMuted,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _ChartLegendRow(
                      label: 'Approved',
                      count: approved,
                      color: AppColors.green,
                    ),
                    const SizedBox(height: 6),
                    _ChartLegendRow(
                      label: 'Pending',
                      count: pending,
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 6),
                    _ChartLegendRow(
                      label: 'Rejected',
                      count: rejected,
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Leave Days Split (Approved days / Pending days)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'APPROVED DAYS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.green,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary?.leave.approvedDays ?? 14}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x1DF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PENDING DAYS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Color(0xFFD97706),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary?.leave.pendingDays ?? 2}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Leave By Type Breakdown
          if (summary?.leave.byType.isNotEmpty ?? false)
            ...summary!.leave.byType.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x0A121417),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${type.usedDays} used · ${type.remainingDays ?? 0} left',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _ChartLegendRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ChartLegendRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

/// Custom Donut Painter for Requests Breakdown
class _DonutChartPainter extends CustomPainter {
  final int approved;
  final int pending;
  final int rejected;
  final int total;

  _DonutChartPainter({
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = Colors.grey.withValues(alpha: 0.2);
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    const startAngle = -1.5708; // -90 degrees (top)
    final approvedAngle = (approved / total) * 6.28319;
    final pendingAngle = (pending / total) * 6.28319;
    final rejectedAngle = (rejected / total) * 6.28319;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Draw Approved
    paint.color = AppColors.green;
    canvas.drawArc(rect, startAngle, approvedAngle, false, paint);

    // Draw Pending
    paint.color = const Color(0xFFD97706);
    canvas.drawArc(rect, startAngle + approvedAngle, pendingAngle, false, paint);

    // Draw Rejected
    paint.color = const Color(0xFFDC2626);
    canvas.drawArc(rect, startAngle + approvedAngle + pendingAngle, rejectedAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.approved != approved ||
        oldDelegate.pending != pending ||
        oldDelegate.rejected != rejected ||
        oldDelegate.total != total;
  }
}

/// Personal Pulse Section (Allowance, Salary Advance, Gym Streak, Next Holiday)
class _PersonalPulseSection extends StatelessWidget {
  final DashboardSummaryModel? summary;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;
  final NumberFormat currencyFormat;
  final VoidCallback onGymCheckIn;

  const _PersonalPulseSection({
    required this.summary,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.currencyFormat,
    required this.onGymCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final allowanceApproved = summary?.allowance.approvedAmount ?? 14200.0;
    final allowancePending = summary?.allowance.pendingAmount ?? 4300.0;
    final advanceBalance = summary?.advance.outstandingBalance ?? 12500.0;
    final gymMonth = summary?.gym.monthCount ?? 14;
    final gymStreak = summary?.gym.currentStreak ?? 5;
    final nextHoliday = summary?.nextHoliday;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.waveform_path_badge_plus, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                'Personal Pulse',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Allowance Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x0A121417),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allowance approved',
                      style: TextStyle(fontSize: 11, color: textMuted, fontFamily: 'Poppins'),
                    ),
                    Text(
                      '${currencyFormat.format(allowancePending)} pending claim',
                      style: TextStyle(fontSize: 10, color: textMuted, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(allowanceApproved),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. Salary Advance Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x0A121417),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advance outstanding',
                      style: TextStyle(fontSize: 11, color: textMuted, fontFamily: 'Poppins'),
                    ),
                    Text(
                      'Principal to recover',
                      style: TextStyle(fontSize: 10, color: textMuted, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(advanceBalance),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Gym Check-in Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x0A121417),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gym check-ins this month',
                      style: TextStyle(fontSize: 11, color: textMuted, fontFamily: 'Poppins'),
                    ),
                    Text(
                      '$gymStreak-day continuous streak 🔥',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onGymCheckIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$gymMonth entries',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Next Holiday Countdown
          if (nextHoliday != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1AE8590C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x33E8590C), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT HOLIDAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextHoliday.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateTime.tryParse(nextHoliday.date) != null
                              ? DateFormat('dd MMMM yyyy').format(DateTime.parse(nextHoliday.date))
                              : nextHoliday.date,
                          style: TextStyle(fontSize: 11, color: textMuted, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${nextHoliday.daysRemaining}d left',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick Action Tile
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final Color cardBg;
  final Color borderCol;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.cardBg,
    required this.borderCol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Row Item
class _ActivityRowItem extends StatelessWidget {
  final DashboardActivityItem item;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;

  const _ActivityRowItem({
    required this.item,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    if (item.status == 'approved') {
      statusColor = AppColors.green;
      statusBg = AppColors.greenSoft;
    } else if (item.status == 'rejected') {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0x1ADC2626);
    } else {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0x1AD97706);
    }

    IconData typeIcon;
    if (item.type == 'leave') {
      typeIcon = CupertinoIcons.calendar;
    } else if (item.type == 'allowance') {
      typeIcon = CupertinoIcons.money_dollar;
    } else {
      typeIcon = CupertinoIcons.creditcard;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(typeIcon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
