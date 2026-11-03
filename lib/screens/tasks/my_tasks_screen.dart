import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Task Item Data Model matching tasks.html line 23:
/// { t: 'Submit weekly timesheet', m: 'Due today, 5:00 PM', s: 'Pending' }
class TaskItem {
  final String id;
  final String title;
  final String meta;
  String status; // 'Pending', 'In progress', 'Done'

  TaskItem({
    required this.id,
    required this.title,
    required this.meta,
    required this.status,
  });
}

/// Tasks Screen mirroring tasks.html & styles.css
class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  // Tasks array matching tasks.html lines 23-29
  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'Submit weekly timesheet',
      meta: 'Due today, 5:00 PM',
      status: 'Pending',
    ),
    TaskItem(
      id: '2',
      title: 'Review project brief',
      meta: 'Team Alpha · Due tomorrow',
      status: 'In progress',
    ),
    TaskItem(
      id: '3',
      title: 'Update client records',
      meta: 'Due Wed, 4 Nov',
      status: 'Pending',
    ),
    TaskItem(
      id: '4',
      title: 'Prepare monthly report',
      meta: 'Due Fri, 6 Nov',
      status: 'In progress',
    ),
    TaskItem(
      id: '5',
      title: 'Attend onboarding session',
      meta: 'Completed Mon, 2 Nov',
      status: 'Done',
    ),
  ];

  // Filter categories matching tasks.html line 31
  final List<String> _filters = const ['All', 'Pending', 'In progress', 'Done'];
  String _currentFilter = 'All';

  List<TaskItem> get _filteredTasks {
    if (_currentFilter == 'All') return _tasks;
    return _tasks.where((t) => t.status == _currentFilter).toList();
  }

  void _cycleTaskStatus(TaskItem task) {
    HapticFeedback.selectionClick();
    setState(() {
      if (task.status == 'Pending') {
        task.status = 'In progress';
      } else if (task.status == 'In progress') {
        task.status = 'Done';
      } else {
        task.status = 'Pending';
      }
    });
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
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;
    final blue = isDark ? AppColors.darkBlue : AppColors.lightBlue;
    final green = isDark ? AppColors.darkGreen : AppColors.lightGreen;

    // Status colors matching var color = { 'Pending': 'var(--accent)', 'In progress': 'var(--blue)', 'Done': 'var(--green)' }
    Color getStatusColor(String status) {
      switch (status) {
        case 'In progress':
          return blue;
        case 'Done':
          return green;
        case 'Pending':
        default:
          return accent;
      }
    }

    final filtered = _filteredTasks;
    final summaryText = '${filtered.length} shown · ${_tasks.length} total';

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

          // Main Page Content (.app > .page in tasks.html)
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
              children: [
                // 1. Header (tasks.html line 15: <header class="col" style="gap:2px"><h1>Tasks</h1><p class="sub" id="summary"></p></header>)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks',
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
                      summaryText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Filter chips (.chips in tasks.html line 16)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = f == _currentFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _currentFilter = f);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected ? accent : borderCol2,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? onAccent : textSoft,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Tasks List (.list in tasks.html line 17)
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No tasks match the selected filter.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isDone = item.status == 'Done';
                      final statusColor = getStatusColor(item.status);

                      return GestureDetector(
                        onTap: () => _cycleTaskStatus(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              // .dot (width: 9px, height: 9px, border-radius: 50%, background: color[x.s])
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // .grow (with opacity .6 if Done)
                              Expanded(
                                child: Opacity(
                                  opacity: isDone ? 0.6 : 1.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // .t (font-size: 14px, font-weight: 500, line-height: 1.35)
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                          height: 1.35,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 2),

                                      // .m (font-size: 12px, color: var(--muted))
                                      Text(
                                        item.meta,
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
                              ),
                              const SizedBox(width: 8),

                              // .status (font-size: 11px, font-weight: 500, color: color[x.s])
                              Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
