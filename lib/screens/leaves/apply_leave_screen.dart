import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final AuthState? authState;

  const ApplyLeaveScreen({super.key, this.authState});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();

  String _selectedLeaveType = 'Casual Leave';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  final Map<String, int> _balances = {
    'Casual Leave': 12,
    'Sick Leave': 6,
    'Earned Leave': 8,
    'Unpaid Leave': 30,
  };

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  int get _selectedDaysCount {
    if (_endDate.isBefore(_startDate)) return 1;
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _selectDateRange() async {
    HapticFeedback.selectionClick();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8590C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submitLeave() async {
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason for your leave')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (_balances.containsKey(_selectedLeaveType)) {
          _balances[_selectedLeaveType] =
              (_balances[_selectedLeaveType]! - _selectedDaysCount).clamp(0, 999);
        }
      });
      _reasonCtrl.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Application Submitted'),
            ],
          ),
          content: Text(
            'Your $_selectedLeaveType request for $_selectedDaysCount day(s) from '
            '${DateFormat('d MMM').format(_startDate)} to ${DateFormat('d MMM yyyy').format(_endDate)} '
            'has been sent to your manager for approval.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.leaveHistory);
              },
              child: const Text('View History', style: TextStyle(color: Color(0xFFE8590C), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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
              currentItem: SidebarItemKey.applyLeave,
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
          'Apply Leave',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Balances Carousel
            Text(
              'Your Leave Balances',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _BalanceCard(
                    title: 'Casual',
                    days: _balances['Casual Leave'] ?? 12,
                    color: const Color(0xFFE8590C),
                    cardBg: cardBg,
                    borderCol: borderCol,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BalanceCard(
                    title: 'Sick',
                    days: _balances['Sick Leave'] ?? 6,
                    color: const Color(0xFF10B981),
                    cardBg: cardBg,
                    borderCol: borderCol,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BalanceCard(
                    title: 'Earned',
                    days: _balances['Earned Leave'] ?? 8,
                    color: const Color(0xFF3B82F6),
                    cardBg: cardBg,
                    borderCol: borderCol,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLeaveType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderCol),
                      ),
                    ),
                    items: _balances.keys.map((k) {
                      return DropdownMenuItem(
                        value: k,
                        child: Text('$k (${_balances[k]} available)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLeaveType = val);
                    },
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Duration & Dates',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar, size: 20, color: accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('EEE, d MMM').format(_startDate)}  →  ${DateFormat('EEE, d MMM yyyy').format(_endDate)}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_selectedDaysCount day(s) requested',
                                  style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_down, size: 16, color: textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Reason for Leave *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Please detail reason for absence, handover notes, or emergency contacts...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderCol),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8590C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSubmitting ? null : _submitLeave,
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text(
                              'Submit Leave Application',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final int days;
  final Color color;
  final Color cardBg;
  final Color borderCol;

  const _BalanceCard({
    required this.title,
    required this.days,
    required this.color,
    required this.cardBg,
    required this.borderCol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$days',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
              ),
              const SizedBox(width: 4),
              const Text('days', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

