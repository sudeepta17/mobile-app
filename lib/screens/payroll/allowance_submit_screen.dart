import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

class AllowanceClaim {
  final int id;
  final String type; // 'electric', 'wifi', 'gym'
  final DateTime date;
  final double amount;
  final String remarks;
  final String status; // 'pending', 'approved', 'rejected'
  final String? attachmentName;

  AllowanceClaim({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.remarks,
    required this.status,
    this.attachmentName,
  });

  String get typeLabel {
    switch (type) {
      case 'electric':
        return 'Electric Allowance';
      case 'wifi':
        return 'WiFi Internet Allowance';
      case 'gym':
        return 'Gym & Fitness Membership';
      default:
        return 'Allowance';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'electric':
        return CupertinoIcons.bolt_fill;
      case 'wifi':
        return CupertinoIcons.wifi;
      case 'gym':
        return CupertinoIcons.flame_fill;
      default:
        return CupertinoIcons.creditcard_fill;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'electric':
        return const Color(0xFFF59E0B);
      case 'wifi':
        return const Color(0xFF06B6D4);
      case 'gym':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFE8590C);
    }
  }
}

class AllowanceSubmitScreen extends StatefulWidget {
  final AuthState? authState;

  const AllowanceSubmitScreen({super.key, this.authState});

  @override
  State<AllowanceSubmitScreen> createState() => _AllowanceSubmitScreenState();
}

class _AllowanceSubmitScreenState extends State<AllowanceSubmitScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String _selectedType = 'wifi';
  DateTime _expenseDate = DateTime.now();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  String? _attachedFileName;
  bool _isSubmitting = false;

  List<AllowanceClaim> _claims = [];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
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
    _claims = [
      AllowanceClaim(
        id: 1,
        type: 'wifi',
        date: DateTime(2026, 10, 28),
        amount: 1199,
        remarks: 'Airtel Xstream Fiber broadband 200 Mbps monthly bill',
        status: 'approved',
        attachmentName: 'airtel_bill_oct.pdf',
      ),
      AllowanceClaim(
        id: 2,
        type: 'electric',
        date: DateTime(2026, 10, 25),
        amount: 1850,
        remarks: 'Home office power utility consumption',
        status: 'approved',
        attachmentName: 'tneb_power_bill.pdf',
      ),
      AllowanceClaim(
        id: 3,
        type: 'gym',
        date: DateTime(2026, 11, 1),
        amount: 2500,
        remarks: 'Cult.fit fitness membership subscription renewal',
        status: 'pending',
        attachmentName: 'cultfit_receipt.png',
      ),
    ];
  }

  void _submitClaim() async {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _claims.insert(
          0,
          AllowanceClaim(
            id: DateTime.now().millisecondsSinceEpoch,
            type: _selectedType,
            date: _expenseDate,
            amount: amt,
            remarks: _remarksCtrl.text.trim().isEmpty ? 'Monthly reimbursement' : _remarksCtrl.text.trim(),
            status: 'pending',
            attachmentName: _attachedFileName ?? 'receipt_upload.pdf',
          ),
        );
        _isSubmitting = false;
        _amountCtrl.clear();
        _remarksCtrl.clear();
        _attachedFileName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allowance claim submitted for review!')),
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

    final totalApproved = _claims.where((c) => c.status == 'approved').fold(0.0, (sum, c) => sum + c.amount);

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.myAllowance,
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
          'My Allowance',
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
            // Allowance Overview Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8590C), Color(0xFFF97316)],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reimbursed This Quarter',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currencyFormat.format(totalApproved),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(CupertinoIcons.checkmark_shield_fill, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Direct deposit to salary bank account',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Claim Submission Form
            Text(
              'Submit Allowance Claim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),

            // Allowance Type Selector Cards
            Row(
              children: [
                _TypeSelectorCard(
                  title: 'WiFi',
                  sub: 'Internet bill',
                  icon: CupertinoIcons.wifi,
                  color: const Color(0xFF06B6D4),
                  isSelected: _selectedType == 'wifi',
                  cardBg: cardBg,
                  onTap: () => setState(() => _selectedType = 'wifi'),
                ),
                const SizedBox(width: 10),
                _TypeSelectorCard(
                  title: 'Electric',
                  sub: 'Power bill',
                  icon: CupertinoIcons.bolt_fill,
                  color: const Color(0xFFF59E0B),
                  isSelected: _selectedType == 'electric',
                  cardBg: cardBg,
                  onTap: () => setState(() => _selectedType = 'electric'),
                ),
                const SizedBox(width: 10),
                _TypeSelectorCard(
                  title: 'Gym',
                  sub: 'Fitness',
                  icon: CupertinoIcons.flame_fill,
                  color: const Color(0xFF10B981),
                  isSelected: _selectedType == 'gym',
                  cardBg: cardBg,
                  onTap: () => setState(() => _selectedType = 'gym'),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                  Text('Claim Amount (₹) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.money_dollar, color: Color(0xFFE8590C)),
                      hintText: 'e.g. 1499',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Expense Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expenseDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _expenseDate = picked);
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
                          Text(DateFormat('dd MMMM yyyy').format(_expenseDate), style: TextStyle(color: textPrimary, fontSize: 14)),
                          const Spacer(),
                          Icon(CupertinoIcons.chevron_down, size: 14, color: textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Remarks / Bill Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _remarksCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Broadband invoice for October',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderCol)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Receipt Upload Picker Simulation
                  Text('Proof of Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _attachedFileName = 'receipt_invoice_${DateFormat("yyyyMM").format(_expenseDate)}.pdf');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt document attached')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withValues(alpha: 0.4), style: BorderStyle.solid),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.cloud_upload, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _attachedFileName ?? 'Upload Receipt / Bill PDF',
                            style: TextStyle(
                              color: _attachedFileName != null ? accent : textMuted,
                              fontWeight: _attachedFileName != null ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
                      onPressed: _isSubmitting ? null : _submitClaim,
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text(
                              'Submit Claim',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Claims History
            Text(
              'Claims History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            ..._claims.map((claim) {
              Color stCol = Colors.amber;
              if (claim.status == 'approved') stCol = Colors.green;
              if (claim.status == 'rejected') stCol = Colors.red;

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
                        color: claim.typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(claim.typeIcon, color: claim.typeColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                claim.typeLabel,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const Spacer(),
                              Text(
                                _currencyFormat.format(claim.amount),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                DateFormat('d MMM yyyy').format(claim.date),
                                style: TextStyle(fontSize: 12, color: textMuted),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stCol.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  claim.status.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stCol),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _TypeSelectorCard extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final Color cardBg;
  final VoidCallback onTap;

  const _TypeSelectorCard({
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFE8590C) : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFE8590C) : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

