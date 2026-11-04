import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/employee_shift_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_header_back_button.dart';

/// Attendance & Shift Reports Screen mirroring AttendanceShiftReports.tsx
/// from newmanagement & mmanagement
class AttendanceShiftReportsScreen extends StatefulWidget {
  const AttendanceShiftReportsScreen({super.key});

  @override
  State<AttendanceShiftReportsScreen> createState() => _AttendanceShiftReportsScreenState();
}

class _AttendanceShiftReportsScreenState extends State<AttendanceShiftReportsScreen> {
  Timer? _timer;
  String _activeFilter = 'All'; // 'All', 'Monthly', 'Outages', 'Overtime'

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return DateFormat('hh:mm a').format(dt);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('EEE, d MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final green = isDark ? AppColors.green : const Color(0xFF16A34A);
    final amber = const Color(0xFFF59E0B);
    final red = const Color(0xFFDC2626);

    final shiftService = services.shiftService;
    final activeShift = shiftService.activeShift;
    final history = shiftService.shiftHistory;

    // Filter shifts
    final filteredHistory = history.where((s) {
      if (_activeFilter == 'Outages') return s.outages.isNotEmpty;
      if (_activeFilter == 'Overtime') return s.overtimeMinutes > 0;
      return true;
    }).toList();

    // Summary calculations
    int totalShifts = history.length + (activeShift != null ? 1 : 0);
    int totalRegularMinutes = 0;
    int totalOvertimeMinutes = 0;
    int totalOutageIncidents = 0;

    for (final s in history) {
      totalRegularMinutes += s.regularMinutes;
      totalOvertimeMinutes += s.overtimeMinutes;
      totalOutageIncidents += s.outages.length;
    }
    if (activeShift != null) {
      totalRegularMinutes += activeShift.regularMinutes;
      totalOvertimeMinutes += activeShift.overtimeMinutes;
      totalOutageIncidents += activeShift.outages.length;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
            children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shift & Attendance',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Standard 11:00 AM – 08:00 PM IST',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    const AppHeaderBackButton(),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. Current Live Shift Card
                _buildLiveShiftCard(
                  context,
                  shift: activeShift,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  accent: accent,
                  green: green,
                  amber: amber,
                  red: red,
                ),

                const SizedBox(height: 20),

                // 2. Summary Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'TOTAL SHIFTS',
                        value: '$totalShifts',
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'REGULAR HOURS',
                        value: _formatDuration(totalRegularMinutes),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        accentColor: green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'OVERTIME',
                        value: _formatDuration(totalOvertimeMinutes),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        accentColor: amber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'POWER CUTS',
                        value: '$totalOutageIncidents incident${totalOutageIncidents == 1 ? "" : "s"}',
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        accentColor: red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Monthly', 'Outages', 'Overtime'].map((filter) {
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _activeFilter = filter);
                          },
                          selectedColor: accent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: cardBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Shift History List
                Text(
                  'Shift History (${filteredHistory.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),

                if (filteredHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    alignment: Alignment.center,
                    child: Text(
                      'No shift records match this filter.',
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  )
                else
                  ...filteredHistory.map((shift) {
                    return _buildHistoryCard(
                      shift,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      accent: accent,
                      green: green,
                      amber: amber,
                      red: red,
                    );
                  }),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildLiveShiftCard(
    BuildContext context, {
    required EmployeeShiftRecord? shift,
    required Color cardBg,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
    required Color accent,
    required Color green,
    required Color amber,
    required Color red,
  }) {
    if (shift == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SHIFT NOT STARTED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '11:00 AM – 08:00 PM',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'You are off the clock',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Benchmark shift starts at 11:00 AM IST. Punch in when you begin your workday.',
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(CupertinoIcons.play_fill, size: 16, color: Colors.white),
                label: const Text(
                  'Start Daily Shift (Punch In)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await services.shiftService.startShift();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      );
    }

    Color statusBadgeBg;
    Color statusBadgeText;
    if (shift.status == ShiftStatus.active) {
      statusBadgeBg = green.withValues(alpha: 0.15);
      statusBadgeText = green;
    } else if (shift.status == ShiftStatus.onBreak) {
      statusBadgeBg = amber.withValues(alpha: 0.15);
      statusBadgeText = amber;
    } else {
      statusBadgeBg = red.withValues(alpha: 0.15);
      statusBadgeText = red;
    }

    final elapsed = DateTime.now().difference(shift.loginAt).inMinutes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusBadgeText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      shift.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusBadgeText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Started at ${_formatTime(shift.loginAt)}',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ticking Elapsed Time
          Row(
            children: [
              Text(
                _formatDuration(elapsed),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'elapsed today',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
            ],
          ),

          if (shift.delayMinutes > 0) ...[
            const SizedBox(height: 6),
            Text(
              '⚠️ Late arrival: ${shift.delayMinutes}m past 11:00 AM benchmark',
              style: TextStyle(fontSize: 11, color: amber, fontWeight: FontWeight.w500),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons: Take Break / Resume, Power Cut / Restore, End Shift
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: shift.status == ShiftStatus.onBreak ? Colors.white : textPrimary,
                    backgroundColor: shift.status == ShiftStatus.onBreak ? amber : Colors.transparent,
                    side: BorderSide(color: shift.status == ShiftStatus.onBreak ? amber : borderCol),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    shift.status == ShiftStatus.onBreak ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
                    size: 14,
                  ),
                  label: Text(
                    shift.status == ShiftStatus.onBreak ? 'Resume' : 'Break',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await services.shiftService.toggleBreak();
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: shift.status == ShiftStatus.powerOut ? Colors.white : textPrimary,
                    backgroundColor: shift.status == ShiftStatus.powerOut ? red : Colors.transparent,
                    side: BorderSide(color: shift.status == ShiftStatus.powerOut ? red : borderCol),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(CupertinoIcons.bolt_fill, size: 14),
                  label: Text(
                    shift.status == ShiftStatus.powerOut ? 'Power OK' : 'Power Cut',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await services.shiftService.togglePower();
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(CupertinoIcons.square_arrow_right, size: 14, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await services.shiftService.endShift();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          // Undo button if within grace period
          if (shift.canUndo) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                await services.shiftService.undoLastAction();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.arrow_counterclockwise, size: 14, color: amber),
                    const SizedBox(width: 6),
                    Text(
                      'Undo last action (${shift.lastActionName})',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: amber),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color cardBg,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    EmployeeShiftRecord shift, {
    required Color cardBg,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
    required Color accent,
    required Color green,
    required Color amber,
    required Color red,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(shift.shiftDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatDuration(shift.regularMinutes),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(CupertinoIcons.clock, size: 14, color: textMuted),
              const SizedBox(width: 4),
              Text(
                '${_formatTime(shift.loginAt)} → ${_formatTime(shift.logoutAt)}',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
              if (shift.overtimeMinutes > 0) ...[
                const SizedBox(width: 10),
                Text(
                  '+${shift.overtimeMinutes}m OT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: amber),
                ),
              ],
            ],
          ),
          if (shift.breaks.isNotEmpty || shift.outages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (shift.totalBreakMinutes > 0)
                  Text(
                    '☕ ${shift.totalBreakMinutes}m break (${shift.breaks.length})',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                if (shift.outages.isNotEmpty)
                  Text(
                    '⚡ ${shift.totalOutageMinutes}m power cut (${shift.outages.length})',
                    style: TextStyle(fontSize: 11, color: red),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
