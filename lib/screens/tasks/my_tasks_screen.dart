import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

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
  final AuthState? authState;

  const MyTasksScreen({super.key, this.authState});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String? _searchQuery = '';
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
  String? _currentFilter = 'All';

  List<TaskItem> get _filteredTasks {
    final query = _searchQuery ?? '';
    final filter = _currentFilter ?? 'All';
    return _tasks.where((t) {
      if (filter != 'All' && t.status != filter) return false;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        return t.title.toLowerCase().contains(q) || t.meta.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void _showAddTaskModal() {
    HapticFeedback.mediumImpact();
    final titleCtrl = TextEditingController();
    final metaCtrl = TextEditingController(text: 'Due today, 6:00 PM');
    String status = 'Pending';

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
                          'Create New Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 24, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Task Title *',
                        hintText: 'e.g. Complete sprint backlog review',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: metaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Due Date / Context *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: 'Initial Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'In progress', child: Text('In progress')),
                        DropdownMenuItem(value: 'Done', child: Text('Done')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => status = val);
                      },
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
                          if (titleCtrl.text.trim().isEmpty) return;
                          setState(() {
                            _tasks.insert(
                              0,
                              TaskItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleCtrl.text.trim(),
                                meta: metaCtrl.text.trim(),
                                status: status,
                              ),
                            );
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task added successfully!')),
                          );
                        },
                        child: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.myTasks,
              authState: widget.authState!,
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: _showAddTaskModal,
        child: const Icon(CupertinoIcons.plus, color: Colors.white),
      ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.authState != null) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _effectiveScaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          alignment: Alignment.center,
                          child: Icon(CupertinoIcons.bars, size: 20, color: textPrimary),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
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
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search field
                CupertinoSearchTextField(
                  placeholder: 'Search tasks...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 14),

                // 2. Filter chips (.chips in tasks.html line 16)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = f == (_currentFilter ?? 'All');
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
