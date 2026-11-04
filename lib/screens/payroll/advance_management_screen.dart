import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

class AdvanceRecord {
  final int id;
  final double amount;
  final DateTime requiredDate;
  String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  AdvanceRecord({
    required this.id,
    required this.amount,
    required this.requiredDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
}

class AdvanceManagementScreen extends StatefulWidget {
  final AuthState? authState;

  const AdvanceManagementScreen({super.key, this.authState});

  @override
  State<AdvanceManagementScreen> createState() => _AdvanceManagementScreenState();
}

class _AdvanceManagementScreenState extends State<AdvanceManagementScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  DateTime _requiredDate = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  List<AdvanceRecord> _advances = [];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _advances = [
      AdvanceRecord(
        id: 1,
        amount: 25000,
        requiredDate: DateTime(2026, 11, 10),
        reason: 'Emergency family medical expense and hospital deposit.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdvanceRecord(
        id: 2,
        amount: 20000,
        requiredDate: DateTime(2026, 8, 15),
        reason: 'Home relocation advance payment and security deposit.',
        status: 'approved',
        createdAt: DateTime(2026, 8, 10),
      ),
    ];
  }

  void _submitAdvance() async {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid advance amount')),
      );
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for the advance')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _advances.insert(
          0,
          AdvanceRecord(
            id: DateTime.now().millisecondsSinceEpoch,
            amount: amt,
            requiredDate: _requiredDate,
            reason: _reasonCtrl.text.trim(),
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
        _isSubmitting = false;
        _amountCtrl.clear();
        _reasonCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary advance request submitted!')),
      );
    }
  }

  void _editReason(AdvanceRecord record) {
    final ctrl = TextEditingController(text: record.reason);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Advance Reason'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8590C)),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => record.reason = ctrl.text.trim());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason updated successfully')),
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

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.salaryAdvance,
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
          'Salary Advance',
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Outstanding Advance Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8590C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Color(0xFFE8590C), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Outstanding', style: TextStyle(fontSize: 12, color: textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          '₹0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text('All previous advances settled', style: TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Request Form
            Text(
              'Request Salary Advance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requested Amount (₹) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.money_dollar, color: Color(0xFFE8590C)),
                      hintText: 'e.g. 20000',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Required by Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _requiredDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _requiredDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar, size: 18, color: accent),
                          const SizedBox(width: 10),
                          Text(DateFormat('dd MMMM yyyy').format(_requiredDate), style: TextStyle(color: textPrimary, fontSize: 14)),
                          const Spacer(),
                          Icon(CupertinoIcons.chevron_down, size: 14, color: textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Reason / Purpose *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe purpose of emergency advance...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
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
                      onPressed: _isSubmitting ? null : _submitAdvance,
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Advance History
            Text(
              'Advance Requests History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            ..._advances.map((rec) {
              Color stCol = Colors.amber;
              if (rec.status == 'approved') stCol = Colors.green;
              if (rec.status == 'rejected') stCol = Colors.red;

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
                          _currencyFormat.format(rec.amount),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stCol.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rec.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stCol),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Needed by: ${DateFormat('d MMM yyyy').format(rec.requiredDate)}',
                      style: TextStyle(fontSize: 12, color: textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(rec.reason, style: TextStyle(fontSize: 13, color: textPrimary)),
                    if (rec.status == 'pending') ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(CupertinoIcons.pencil, size: 14),
                          label: const Text('Edit Reason', style: TextStyle(fontSize: 12)),
                          onPressed: () => _editReason(rec),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

