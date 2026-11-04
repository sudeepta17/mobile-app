import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

class LeaveHistoryItem {
  final int id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? adminComment;
  final DateTime createdAt;

  LeaveHistoryItem({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.adminComment,
    required this.createdAt,
  });
}

class LeaveHistoryScreen extends StatefulWidget {
  final AuthState? authState;

  const LeaveHistoryScreen({super.key, this.authState});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String _selectedFilter = 'all';
  String _searchQuery = '';
  List<LeaveHistoryItem> _leaves = [];

  @override
  void initState() {
    super.initState();
    _leaves = [
      LeaveHistoryItem(
        id: 1,
        leaveType: 'Casual Leave',
        startDate: DateTime.now().add(const Duration(days: 4)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        days: 2,
        reason: 'Family wedding ceremony and personal commitments in hometown.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      LeaveHistoryItem(
        id: 2,
        leaveType: 'Casual Leave',
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now().subtract(const Duration(days: 13)),
        days: 2,
        reason: 'Festival travel and Diwali holiday extension.',
        status: 'approved',
        adminComment: 'Approved. Enjoy the festive break!',
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
      ),
      LeaveHistoryItem(
        id: 3,
        leaveType: 'Sick Leave',
        startDate: DateTime.now().subtract(const Duration(days: 28)),
        endDate: DateTime.now().subtract(const Duration(days: 28)),
        days: 1,
        reason: 'High fever and doctor-prescribed rest.',
        status: 'approved',
        adminComment: 'Medical certificate verified.',
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
      ),
      LeaveHistoryItem(
        id: 4,
        leaveType: 'Earned Leave',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().subtract(const Duration(days: 42)),
        days: 4,
        reason: 'Annual vacation trip.',
        status: 'rejected',
        adminComment: 'Overlaps with critical Q3 release cycle milestone. Please reschedule.',
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
    ];
  }

  List<LeaveHistoryItem> get _filteredLeaves {
    final filter = _selectedFilter;
    final query = _searchQuery;
    return _leaves.where((item) {
      if (filter != 'all' && item.status != filter) return false;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesType = item.leaveType.toLowerCase().contains(q);
        final matchesReason = item.reason.toLowerCase().contains(q);
        if (!matchesType && !matchesReason) return false;
      }
      return true;
    }).toList();
  }

  void _editReason(LeaveHistoryItem item) {
    final reasonCtrl = TextEditingController(text: item.reason);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Leave Reason'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8590C)),
            onPressed: () {
              if (reasonCtrl.text.trim().isNotEmpty) {
                setState(() => item.reason = reasonCtrl.text.trim());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave reason updated successfully')),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

    final filtered = _filteredLeaves;

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.leaveHistory,
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
          'Leave History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle, color: Color(0xFFE8590C)),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.applyLeave);
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppHeaderBackButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CupertinoSearchTextField(
                placeholder: 'Search history by type, reason...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['all', 'pending', 'approved', 'rejected'].map((f) {
                  final isSel = _selectedFilter == f;
                  final label = f[0].toUpperCase() + f.substring(1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSel,
                      label: Text(label),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : textPrimary,
                      ),
                      selectedColor: accent,
                      backgroundColor: cardBg,
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // History List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.calendar_today, size: 48, color: textMuted),
                          const SizedBox(height: 12),
                          Text('No leave records found', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final item = filtered[idx];
                        Color statusColor = Colors.amber;
                        if (item.status == 'approved') statusColor = Colors.green;
                        if (item.status == 'rejected') statusColor = Colors.red;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.leaveType,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(CupertinoIcons.calendar, size: 14, color: textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${DateFormat('d MMM').format(item.startDate)} – ${DateFormat('d MMM yyyy').format(item.endDate)}',
                                    style: TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item.days} day(s)',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.reason,
                                style: TextStyle(fontSize: 13, color: textMuted, height: 1.35),
                              ),
                              if (item.adminComment != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF23262B) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(CupertinoIcons.chat_bubble_2, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Admin: ${item.adminComment}',
                                          style: TextStyle(fontSize: 12, color: textPrimary, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (item.status == 'pending') ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Icon(CupertinoIcons.pencil, size: 14),
                                    label: const Text('Edit Reason', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _editReason(item),
                                  ),
                                ),
                              ],
                            ],
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

