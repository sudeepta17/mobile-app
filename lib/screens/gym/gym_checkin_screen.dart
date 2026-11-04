import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

class GymEntry {
  final int id;
  final DateTime date;
  final String remarks;
  final bool isRestDay;
  final String? workoutType;
  final String? proofPhoto;

  GymEntry({
    required this.id,
    required this.date,
    required this.remarks,
    this.isRestDay = false,
    this.workoutType,
    this.proofPhoto,
  });
}

class GymCheckinScreen extends StatefulWidget {
  final AuthState? authState;

  const GymCheckinScreen({super.key, this.authState});

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

class _GymCheckinScreenState extends State<GymCheckinScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  final DateTime _currentMonth = DateTime.now();

  int _streakCount = 14;
  int _monthlyCheckins = 18;

  List<GymEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _entries = [
      GymEntry(
        id: 1,
        date: now.subtract(const Duration(days: 0)),
        remarks: 'Upper body hypertrophy + 20 min inclined treadmill sprint',
        workoutType: 'Chest & Arms',
      ),
      GymEntry(
        id: 2,
        date: now.subtract(const Duration(days: 1)),
        remarks: 'Squats, Romanian deadlifts & calf raises',
        workoutType: 'Leg Day',
      ),
      GymEntry(
        id: 3,
        date: now.subtract(const Duration(days: 2)),
        remarks: 'Active recovery and mobility stretching',
        isRestDay: true,
        workoutType: 'Rest Day',
      ),
      GymEntry(
        id: 4,
        date: now.subtract(const Duration(days: 3)),
        remarks: 'Deadlifts, pull-ups, barbell rows',
        workoutType: 'Back & Core',
      ),
    ];
  }

  void _showPunchModal() {
    HapticFeedback.mediumImpact();
    final remarksCtrl = TextEditingController();
    String workoutType = 'Full Body Workout';
    bool isRest = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E2024) : Colors.white;
        final textPri = isDark ? Colors.white : const Color(0xFF1E293B);

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Punch Gym Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isRest,
                          activeColor: const Color(0xFFE8590C),
                          onChanged: (val) {
                            setModalState(() => isRest = val ?? false);
                          },
                        ),
                        const Text('Mark as scheduled Rest / Recovery Day'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!isRest) ...[
                      DropdownButtonFormField<String>(
                        initialValue: workoutType,
                        decoration: InputDecoration(
                          labelText: 'Workout Routine',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Chest & Arms', child: Text('Chest & Arms')),
                          DropdownMenuItem(value: 'Back & Core', child: Text('Back & Core')),
                          DropdownMenuItem(value: 'Leg Day', child: Text('Leg Day')),
                          DropdownMenuItem(value: 'Cardio & HIIT', child: Text('Cardio & HIIT')),
                          DropdownMenuItem(value: 'Full Body Workout', child: Text('Full Body Workout')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => workoutType = val);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: remarksCtrl,
                      decoration: InputDecoration(
                        labelText: 'Workout Notes / Exercises',
                        hintText: 'e.g. 5x5 squats, 3km jog...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8590C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _entries.insert(
                              0,
                              GymEntry(
                                id: DateTime.now().millisecondsSinceEpoch,
                                date: DateTime.now(),
                                remarks: remarksCtrl.text.trim().isEmpty ? 'Completed daily workout' : remarksCtrl.text.trim(),
                                isRestDay: isRest,
                                workoutType: isRest ? 'Rest Day' : workoutType,
                              ),
                            );
                            _streakCount += 1;
                            _monthlyCheckins += 1;
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gym check-in logged! Keep the streak burning! 🔥')),
                          );
                        },
                        child: const Text('Log Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.gymCheckin,
              authState: widget.authState!,
            )
          : null,
      appBar: AppBar(
        leading: widget.authState != null
            ? IconButton(
                icon: const Icon(CupertinoIcons.bars),
                onPressed: () => _effectiveScaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: Text(
          'Gym Check-in',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppHeaderBackButton(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: _showPunchModal,
        icon: const Icon(CupertinoIcons.flame_fill, color: Colors.white),
        label: const Text('Punch Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Streak Header Card
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
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🔥', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_streakCount Days Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_monthlyCheckins check-ins this month · Keep going!',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Calendar Grid Preview
            Text(
              '${DateFormat('MMMM yyyy').format(_currentMonth)} Attendance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                      return Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted));
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Simple calendar matrix representation
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 28,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (ctx, i) {
                      final dayNum = i + 1;
                      final isAttended = dayNum <= 18 && dayNum % 5 != 0;
                      final isRest = dayNum <= 18 && dayNum % 5 == 0;
                      final isToday = dayNum == 18;

                      return Container(
                        decoration: BoxDecoration(
                          color: isAttended
                              ? Colors.green.withValues(alpha: 0.18)
                              : isRest
                                  ? Colors.grey.withValues(alpha: 0.15)
                                  : isToday
                                      ? accent.withValues(alpha: 0.25)
                                      : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday ? Border.all(color: accent, width: 2) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isAttended
                                ? Colors.green
                                : isRest
                                    ? Colors.grey
                                    : textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendPill(color: Colors.green, label: 'Attended'),
                      const SizedBox(width: 14),
                      _LegendPill(color: Colors.grey, label: 'Rest Day'),
                      const SizedBox(width: 14),
                      _LegendPill(color: Colors.red, label: 'Missed'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Workout Log
            Text(
              'Recent Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            ..._entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: entry.isRestDay
                            ? Colors.grey.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        entry.isRestDay ? CupertinoIcons.moon_zzz_fill : CupertinoIcons.flame_fill,
                        color: entry.isRestDay ? Colors.grey : Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.workoutType ?? 'Workout',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('d MMM').format(entry.date),
                                style: TextStyle(fontSize: 12, color: textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(entry.remarks, style: TextStyle(fontSize: 12, color: textMuted)),
                        ],
                      ),
                    ),
                  ],
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

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendPill({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

