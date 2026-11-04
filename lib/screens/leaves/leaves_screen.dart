import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../services/service_locator.dart';
import '../../widgets/app_header_back_button.dart';
import 'apply_leave_modal.dart';

/// Data structure matching reqs = [['Casual leave', '20 – 21 Oct 2026 · 2 days', 'Approved'], ...] in leave.html
class LeaveRequestItem {
  final String leaveType;
  final String dateRange;
  final String status; // 'Approved', 'Pending', 'Rejected'

  const LeaveRequestItem({
    required this.leaveType,
    required this.dateRange,
    required this.status,
  });
}

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  // Balance numbers matching leave.html (Casual: 12, Sick: 6, Earned: 8)
  int _casualDays = 12;
  int _sickDays = 6;
  int _earnedDays = 8;

  // Recent requests list matching reqs array in leave.html line 48
  final List<LeaveRequestItem> _requests = [
    const LeaveRequestItem(
      leaveType: 'Casual leave',
      dateRange: '20 – 21 Oct 2026 · 2 days',
      status: 'Approved',
    ),
    const LeaveRequestItem(
      leaveType: 'Sick leave',
      dateRange: '5 Nov 2026 · 1 day',
      status: 'Pending',
    ),
    const LeaveRequestItem(
      leaveType: 'Earned leave',
      dateRange: '1 – 3 Sep 2026 · 3 days',
      status: 'Rejected',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    try {
      final bundle = await services.leaveService.getLeaveData();
      if (!mounted) return;

      int casual = _casualDays;
      int sick = _sickDays;
      int earned = _earnedDays;

      for (final type in bundle.types) {
        final lower = type.name.toLowerCase();
        if (lower.contains('casual')) {
          casual = type.remaining;
        } else if (lower.contains('sick')) {
          sick = type.remaining;
        } else if (lower.contains('earned') || lower.contains('paid') || lower.contains('privilege')) {
          earned = type.remaining;
        }
      }

      setState(() {
        _casualDays = casual;
        _sickDays = sick;
        _earnedDays = earned;
      });
    } catch (_) {}
  }

  void _openApplyDialog() {
    HapticFeedback.lightImpact();
    ApplyLeaveModal.show(context).then((newRequest) {
      if (newRequest != null && mounted) {
        setState(() {
          _requests.insert(0, newRequest);
          // Deduct from local balance if applicable
          final lower = newRequest.leaveType.toLowerCase();
          if (lower.contains('casual') && _casualDays > 0) {
            _casualDays = max(0, _casualDays - 1);
          } else if (lower.contains('sick') && _sickDays > 0) {
            _sickDays = max(0, _sickDays - 1);
          } else if (lower.contains('earned') && _earnedDays > 0) {
            _earnedDays = max(0, _earnedDays - 1);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;

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

          // Main Page Content (.app > .page in leave.html)
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
              children: [
                // 1. Header (leave.html line 15: <header class="col" style="gap:2px"><h1>Leave</h1><p class="sub">Balance and requests</p></header>)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              height: 1.2,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Balance and requests',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: textMuted,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const AppHeaderBackButton(),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Leave Balance Grid (.grid3 in leave.html line 17)
                Row(
                  children: [
                    // Casual Leave
                    Expanded(
                      child: _LeaveTile(
                        label: 'Casual',
                        value: '$_casualDays',
                        valueColor: accent,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textMuted: textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Sick Leave
                    Expanded(
                      child: _LeaveTile(
                        label: 'Sick',
                        value: '$_sickDays',
                        valueColor: isDark ? AppColors.blue : const Color(0xFF1D6FD8),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textMuted: textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Earned Leave
                    Expanded(
                      child: _LeaveTile(
                        label: 'Earned',
                        value: '$_earnedDays',
                        valueColor: isDark ? AppColors.green : const Color(0xFF15803D),
                        cardBg: cardBg,
                        borderCol: borderCol,
                        textMuted: textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. Apply for leave Button (.btn#apply in leave.html line 23)
                GestureDetector(
                  onTap: _openApplyDialog,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(CupertinoIcons.plus, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Apply for leave',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Recent Requests Section (leave.html line 25: <section class="col" style="gap:10px"><h2>Recent requests</h2>...)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent requests',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Request items list (.list in leave.html line 27)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _requests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final req = _requests[index];
                        return _LeaveRequestCard(
                          request: req,
                          cardBg: cardBg,
                          borderCol: borderCol,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          accent: accent,
                          isDark: isDark,
                        );
                      },
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

/// Leave Tile Component (.card .tile in leave.html line 18)
class _LeaveTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color cardBg;
  final Color borderCol;
  final Color textMuted;

  const _LeaveTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.cardBg,
    required this.borderCol,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textMuted,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                  height: 1.0,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'days',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
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

/// Request Item Card (.item in leave.html line 62)
class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequestItem request;
  final Color cardBg;
  final Color borderCol;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;
  final bool isDark;

  const _LeaveRequestCard({
    required this.request,
    required this.cardBg,
    required this.borderCol,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color chipBg;
    Color chipText;

    if (request.status == 'Approved') {
      chipBg = isDark ? AppColors.greenSoft : const Color(0x1F15803D);
      chipText = isDark ? AppColors.green : const Color(0xFF15803D);
    } else if (request.status == 'Rejected') {
      chipBg = isDark ? AppColors.redSoft : const Color(0x1AC62828);
      chipText = isDark ? AppColors.red : const Color(0xFFC62828);
    } else {
      // Pending
      chipBg = isDark ? AppColors.darkAccentSoft : const Color(0x1FD94F00);
      chipText = accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // .grow (.t & .m in leave.html line 62)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.leaveType,
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
                  request.dateRange,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // .chip in leave.html line 62
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              request.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: chipText,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
