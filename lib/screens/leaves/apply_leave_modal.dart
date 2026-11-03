import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/service_locator.dart';
import 'leaves_screen.dart';

/// Apply Leave Dialog matching `<dialog id="dlg">` in leave.html & styles.css
class ApplyLeaveModal extends StatefulWidget {
  const ApplyLeaveModal({super.key});

  /// Shows the exact `<dialog>` modal with smooth scale & fade transition
  static Future<LeaveRequestItem?> show(BuildContext context) {
    return showGeneralDialog<LeaveRequestItem>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.55), // dialog::backdrop { background: rgba(0,0,0,.55) }
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, anim1, anim2) {
        return const Center(
          child: SingleChildScrollView(
            child: ApplyLeaveModal(),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ApplyLeaveModal> createState() => _ApplyLeaveModalState();
}

class _ApplyLeaveModalState extends State<ApplyLeaveModal> {
  String _selectedType = 'Casual leave';
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 2));

  final List<String> _leaveTypes = const [
    'Casual leave',
    'Sick leave',
    'Earned leave',
  ];

  String _formatEnGb(DateTime dt) {
    // leave.html: new Date(v + 'T00:00:00').toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
    return DateFormat('d MMM yyyy').format(dt);
  }

  String _formatRange(DateTime f, DateTime t, int days) {
    final dayStr = '$days day${days > 1 ? 's' : ''}';
    if (f.year == t.year && f.month == t.month && f.day == t.day) {
      return '${_formatEnGb(f)} · $dayStr';
    }
    // If same month and year: e.g. "20 – 21 Oct 2026 · 2 days"
    if (f.year == t.year && f.month == t.month) {
      return '${f.day} – ${t.day} ${DateFormat('MMM yyyy').format(t)} · $dayStr';
    }
    return '${_formatEnGb(f)} – ${_formatEnGb(t)} · $dayStr';
  }

  Future<void> _pickDate(bool isFrom) async {
    HapticFeedback.selectionClick();
    final initialDate = isFrom ? _fromDate : _toDate;
    final firstDate = DateTime(2025);
    final lastDate = DateTime(2030);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: accent,
                    surface: AppColors.darkCard,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: accent,
                    surface: AppColors.lightCard,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    // leave.html line 70: Math.max(1, Math.round((new Date(t) - new Date(f)) / 86400000) + 1)
    final days = max(1, _toDate.difference(_fromDate).inDays + 1);
    final formattedRange = _formatRange(_fromDate, _toDate, days);

    final newRequest = LeaveRequestItem(
      leaveType: _selectedType,
      dateRange: formattedRange,
      status: 'Pending',
    );

    // Call mock service in background to keep data consistent
    services.leaveService.applyLeave(
      leaveType: _selectedType,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: 'Applied via mobile dialog',
    );

    Navigator.of(context).pop(newRequest);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSoft = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        padding: const EdgeInsets.all(22), // styles.css: padding: 22px
        decoration: BoxDecoration(
          color: bg, // styles.css: background: var(--bg)
          borderRadius: BorderRadius.circular(20), // styles.css: border-radius: 20px
          border: Border.all(color: borderCol2, width: 1.0), // border: 1px solid var(--line2)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: <h2 id="dt" style="font-size:18px;font-weight:600">Apply for leave</h2>
            Text(
              'Apply for leave',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),

            // Field 1: Leave type
            // <div class="field"><label for="type">Leave type</label><select id="type">...
            Text(
              'Leave type',
              style: TextStyle(
                fontSize: 13,
                color: textSoft,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol2, width: 1.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: textSoft,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: textPrimary,
                    fontFamily: 'Poppins',
                  ),
                  items: _leaveTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedType = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field 2: From
            // <div class="field"><label for="from">From</label><input id="from" type="date" required></div>
            Text(
              'From',
              style: TextStyle(
                fontSize: 13,
                color: textSoft,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(true),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol2, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_fromDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Icon(
                      CupertinoIcons.calendar,
                      size: 18,
                      color: textSoft,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field 3: To
            // <div class="field"><label for="to">To</label><input id="to" type="date" required></div>
            Text(
              'To',
              style: TextStyle(
                fontSize: 13,
                color: textSoft,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(false),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol2, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_toDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Icon(
                      CupertinoIcons.calendar,
                      size: 18,
                      color: textSoft,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions row
            // <div class="row" style="gap:10px">
            // <button class="btn ghost" type="button" id="cancel" style="min-height:48px;font-size:15px">Cancel</button>
            // <button class="btn" type="submit" style="min-height:48px;font-size:15px">Submit</button>
            // </div>
            Row(
              children: [
                // Cancel button (.btn.ghost)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: accent,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Submit button (.btn)
                Expanded(
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
