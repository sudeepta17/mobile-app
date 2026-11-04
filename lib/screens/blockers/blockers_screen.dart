import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

enum BlockerCategory { blocker, question, approvals, task, idea }

class BlockerAssignee {
  final int id;
  final String name;
  final String role;
  String status; // 'waiting', 'replied'
  int remindersSent;

  BlockerAssignee({
    required this.id,
    required this.name,
    required this.role,
    this.status = 'waiting',
    this.remindersSent = 0,
  });
}

class BlockerReply {
  final int id;
  final String authorName;
  final String authorRole;
  final String message;
  final DateTime createdAt;
  final List<String> attachments;

  BlockerReply({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
    this.attachments = const [],
  });
}

class BlockerItemData {
  final int id;
  final BlockerCategory category;
  final String title;
  final String description;
  final String projectTitle;
  String status; // 'waiting', 'replied', 'solved'
  final DateTime createdAt;
  final List<BlockerAssignee> assignees;
  final List<BlockerReply> replies;

  BlockerItemData({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.projectTitle,
    required this.status,
    required this.createdAt,
    required this.assignees,
    required this.replies,
  });

  String get categoryLabel {
    switch (category) {
      case BlockerCategory.blocker:
        return 'Blocker';
      case BlockerCategory.question:
        return 'Question';
      case BlockerCategory.approvals:
        return 'Approvals';
      case BlockerCategory.task:
        return 'Task';
      case BlockerCategory.idea:
        return 'Idea';
    }
  }

  Color get categoryColor {
    switch (category) {
      case BlockerCategory.blocker:
        return const Color(0xFFEF4444);
      case BlockerCategory.question:
        return const Color(0xFFF59E0B);
      case BlockerCategory.approvals:
        return const Color(0xFF10B981);
      case BlockerCategory.task:
        return const Color(0xFF3B82F6);
      case BlockerCategory.idea:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case BlockerCategory.blocker:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case BlockerCategory.question:
        return CupertinoIcons.question_circle_fill;
      case BlockerCategory.approvals:
        return CupertinoIcons.checkmark_seal_fill;
      case BlockerCategory.task:
        return CupertinoIcons.doc_text_fill;
      case BlockerCategory.idea:
        return CupertinoIcons.lightbulb_fill;
    }
  }
}

class BlockersScreen extends StatefulWidget {
  final AuthState? authState;

  const BlockersScreen({super.key, this.authState});

  @override
  State<BlockersScreen> createState() => _BlockersScreenState();
}

class _BlockersScreenState extends State<BlockersScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String _selectedTab = 'All';
  String _searchQuery = '';
  BlockerCategory? _categoryFilter;

  List<BlockerItemData> _blockers = [];

  @override
  void initState() {
    super.initState();
    _blockers = [
      BlockerItemData(
        id: 1,
        category: BlockerCategory.blocker,
        title: 'App Store signing certificate expired in production pipeline',
        description:
            'CI/CD builds for iOS are failing with Exit code 65. The distribution provisioning profile needs urgent renewal from Apple Dev account.',
        projectTitle: 'Essane Mobile v2.4',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
        assignees: [
          BlockerAssignee(id: 101, name: 'Marcus Vance', role: 'DevOps Lead', status: 'waiting', remindersSent: 1),
          BlockerAssignee(id: 102, name: 'David Miller', role: 'Engineering Director', status: 'waiting'),
        ],
        replies: [],
      ),
      BlockerItemData(
        id: 2,
        category: BlockerCategory.approvals,
        title: 'Need database schema migration approval for v2 audit logs',
        description:
            'Added new partitioned tables for user activity logs. Requires DBA signoff before deployment to staging database cluster.',
        projectTitle: 'Core Backend Platform',
        status: 'replied',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        assignees: [
          BlockerAssignee(id: 103, name: 'Sarah Jenkins', role: 'Senior Architect', status: 'replied'),
        ],
        replies: [
          BlockerReply(
            id: 201,
            authorName: 'Sarah Jenkins',
            authorRole: 'Senior Architect',
            message: 'Reviewed migration script. Added an index on tenant_id, otherwise looks clean. Approved for staging!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          ),
        ],
      ),
      BlockerItemData(
        id: 3,
        category: BlockerCategory.question,
        title: 'Razorpay webhook signature verification algorithm discrepancy',
        description:
            'The docs mention HMAC-SHA256, but callback payloads from sandbox use custom header tokens. Clarification needed.',
        projectTitle: 'Fintech Gateway',
        status: 'solved',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        assignees: [
          BlockerAssignee(id: 104, name: 'Alex Rivera', role: 'Fintech Lead', status: 'replied'),
        ],
        replies: [
          BlockerReply(
            id: 301,
            authorName: 'Alex Rivera',
            authorRole: 'Fintech Lead',
            message: 'Sandbox credentials were set to legacy mode. Switched to v2 keys and webhook verified successfully.',
            createdAt: DateTime.now().subtract(const Duration(hours: 22)),
          ),
        ],
      ),
      BlockerItemData(
        id: 4,
        category: BlockerCategory.task,
        title: 'Provide staging API credentials for QA automation run',
        description: 'Automated Playwright regression suite needs dedicated auth credentials with 2FA disabled.',
        projectTitle: 'QA Automation',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        assignees: [
          BlockerAssignee(id: 105, name: 'Marcus Vance', role: 'DevOps Lead', status: 'waiting'),
        ],
        replies: [],
      ),
    ];
  }

  List<BlockerItemData> get _filteredBlockers {
    final query = _searchQuery;
    final tab = _selectedTab;
    return _blockers.where((item) {
      if (tab == 'Waiting' && item.status != 'waiting') return false;
      if (tab == 'Replied' && item.status != 'replied') return false;
      if (tab == 'Solved' && item.status != 'solved') return false;

      if (_categoryFilter != null && item.category != _categoryFilter) return false;

      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesDesc = item.description.toLowerCase().contains(q);
        final matchesProj = item.projectTitle.toLowerCase().contains(q);
        if (!matchesTitle && !matchesDesc && !matchesProj) return false;
      }

      return true;
    }).toList();
  }

  void _showCreateBlockerModal() {
    HapticFeedback.mediumImpact();
    BlockerCategory selectedCat = BlockerCategory.blocker;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final projectCtrl = TextEditingController(text: 'Essane Mobile v2.4');
    String assigneeName = 'Marcus Vance';

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
                child: SingleChildScrollView(
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
                            'Create New Blocker',
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
                      const Text(
                        'Category',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: BlockerCategory.values.map((cat) {
                          final isSelected = selectedCat == cat;
                          return ChoiceChip(
                            label: Text(
                              cat.name[0].toUpperCase() + cat.name.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : textPri,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFE8590C),
                            onSelected: (val) {
                              if (val) setModalState(() => selectedCat = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Title / Subject *',
                          hintText: 'What is blocking you?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Detailed Explanation *',
                          hintText: 'Provide logs, error codes, or context...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: projectCtrl,
                        decoration: InputDecoration(
                          labelText: 'Project',
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
                            if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill all required fields')),
                              );
                              return;
                            }
                            setState(() {
                              _blockers.insert(
                                0,
                                BlockerItemData(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  category: selectedCat,
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  projectTitle: projectCtrl.text.trim(),
                                  status: 'waiting',
                                  createdAt: DateTime.now(),
                                  assignees: [
                                    BlockerAssignee(
                                      id: 999,
                                      name: assigneeName,
                                      role: 'Lead',
                                      status: 'waiting',
                                    ),
                                  ],
                                  replies: [],
                                ),
                              );
                            });
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Blocker created successfully!')),
                            );
                          },
                          child: const Text(
                            'Post Blocker',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openBlockerDetail(BlockerItemData item) {
    HapticFeedback.selectionClick();
    final replyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E2024) : Colors.white;
        final textPri = isDark ? Colors.white : const Color(0xFF1E293B);
        final cardBg = isDark ? const Color(0xFF2A2D32) : const Color(0xFFF8FAFC);
        final borderCol = isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0);

        return StatefulBuilder(
          builder: (ctx, setDetailState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.categoryIcon, size: 14, color: item.categoryColor),
                              const SizedBox(width: 6),
                              Text(
                                item.categoryLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: item.categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.status == 'solved'
                                ? Colors.green.withValues(alpha: 0.15)
                                : item.status == 'replied'
                                    ? Colors.blue.withValues(alpha: 0.15)
                                    : Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item.status == 'solved'
                                  ? Colors.green
                                  : item.status == 'replied'
                                      ? Colors.blue
                                      : Colors.amber,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 24, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.projectTitle} · Created ${DateFormat('d MMM, h:mm a').format(item.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                      ),
                      child: Text(
                        item.description,
                        style: TextStyle(fontSize: 13, color: textPri, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Assignees (${item.assignees.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: item.assignees.map((a) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: const Color(0xFFE8590C).withValues(alpha: 0.2),
                            child: Text(
                              a.name[0],
                              style: const TextStyle(color: Color(0xFFE8590C), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          label: Text('${a.name} (${a.status})', style: const TextStyle(fontSize: 11)),
                          backgroundColor: cardBg,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discussion (${item.replies.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: item.replies.isEmpty
                          ? Center(
                              child: Text(
                                'No replies yet. Awaiting response.',
                                style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 13),
                              ),
                            )
                          : ListView.builder(
                              itemCount: item.replies.length,
                              itemBuilder: (ctx, idx) {
                                final r = item.replies[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderCol),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            r.authorName,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPri),
                                          ),
                                          Text(
                                            DateFormat('h:mm a').format(r.createdAt),
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(r.message, style: TextStyle(fontSize: 13, color: textPri)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    // Action footer: Mark solved & reply
                    if (item.status != 'solved')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                            icon: const Icon(CupertinoIcons.checkmark_circle, size: 18),
                            label: const Text('Mark Blocker as Solved'),
                            onPressed: () {
                              setState(() {
                                item.status = 'solved';
                              });
                              setDetailState(() {});
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Blocker marked as Solved!')),
                              );
                            },
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: replyCtrl,
                            decoration: InputDecoration(
                              hintText: 'Type a reply...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(CupertinoIcons.paperplane_fill, color: Color(0xFFE8590C)),
                          onPressed: () {
                            final text = replyCtrl.text.trim();
                            if (text.isEmpty) return;
                            setState(() {
                              item.replies.add(
                                BlockerReply(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  authorName: widget.authState?.currentUser?.name ?? 'Sarah Jenkins',
                                  authorRole: 'Software Engineer',
                                  message: text,
                                  createdAt: DateTime.now(),
                                ),
                              );
                              if (item.status == 'waiting') item.status = 'replied';
                            });
                            replyCtrl.clear();
                            setDetailState(() {});
                          },
                        ),
                      ],
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

    final filtered = _filteredBlockers;

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.blockers,
              authState: widget.authState!,
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: _showCreateBlockerModal,
        icon: const Icon(CupertinoIcons.plus, color: Colors.white),
        label: const Text('New Blocker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_effectiveScaffoldKey.currentState?.hasDrawer ?? false) {
                        _effectiveScaffoldKey.currentState?.openDrawer();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol),
                      ),
                      alignment: Alignment.center,
                      child: Icon(CupertinoIcons.bars, size: 20, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blockers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '${_blockers.where((b) => b.status == "waiting").length} waiting on replies',
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CupertinoSearchTextField(
                placeholder: 'Search blockers, projects...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Status Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Waiting', 'Replied', 'Solved'].map((tab) {
                    final isSel = _selectedTab == tab;
                    int count = 0;
                    if (tab == 'All') count = _blockers.length;
                    if (tab == 'Waiting') count = _blockers.where((b) => b.status == 'waiting').length;
                    if (tab == 'Replied') count = _blockers.where((b) => b.status == 'replied').length;
                    if (tab == 'Solved') count = _blockers.where((b) => b.status == 'solved').length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text('$tab ($count)'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : textPrimary,
                        ),
                        selectedColor: accent,
                        backgroundColor: cardBg,
                        onSelected: (val) {
                          if (val) setState(() => _selectedTab = tab);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Blockers List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.checkmark_shield_fill, size: 48, color: Colors.green.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          Text(
                            'No blockers in this view',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text('All team streams are flowing smoothly.', style: TextStyle(fontSize: 12, color: textMuted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88, top: 4),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final b = filtered[idx];
                        return GestureDetector(
                          onTap: () => _openBlockerDetail(b),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderCol),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Category badge + Status + Elapsed time
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: b.categoryColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(b.categoryIcon, size: 12, color: b.categoryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            b.categoryLabel,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: b.categoryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      b.projectTitle,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: b.status == 'solved'
                                            ? Colors.green.withValues(alpha: 0.15)
                                            : b.status == 'replied'
                                                ? Colors.blue.withValues(alpha: 0.15)
                                                : Colors.amber.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        b.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: b.status == 'solved'
                                              ? Colors.green
                                              : b.status == 'replied'
                                                  ? Colors.blue
                                                  : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  b.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: textMuted, height: 1.35),
                                ),
                                const SizedBox(height: 12),
                                // Bottom row: Assignees & Reply count
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.person_2, size: 14, color: textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${b.assignees.length} assigned',
                                      style: TextStyle(fontSize: 12, color: textMuted),
                                    ),
                                    const SizedBox(width: 14),
                                    Icon(CupertinoIcons.chat_bubble, size: 14, color: textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${b.replies.length} replies',
                                      style: TextStyle(fontSize: 12, color: textMuted),
                                    ),
                                    const Spacer(),
                                    Icon(CupertinoIcons.chevron_right, size: 14, color: textMuted),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
