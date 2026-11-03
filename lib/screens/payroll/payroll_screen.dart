import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/payroll_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/common/segmented_control.dart';
import '../../widgets/layout/modal_sheet_wrapper.dart';
import 'submit_allowance_modal.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  PayrollDataBundle? _data;
  bool _isLoading = true;
  String _selectedTab = 'payslips'; // payslips, allowances, advances

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_data == null) setState(() => _isLoading = true);
    final data = await services.payrollService.getPayrollData();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  void _showPayslipDetails(PayslipItem item) {
    ModalSheetWrapper.show(
      context: context,
      title: 'Salary Slip: ${item.month}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleCard(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NET PAYOUT', style: AppTypography.caption2),
                    Text(
                      AppFormatters.currency(item.netPay),
                      style: AppTypography.title1.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                AppleChip(label: 'Disbursed', tone: ChipTone.green),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.p16),
          Text(
            'Earnings & Deductions',
            style: AppTypography.subhead.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.p8),
          ...item.breakdown.entries.map((entry) {
            final isDeduction = entry.key.contains('tax') || entry.key.contains('fund');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: AppTypography.footnote,
                  ),
                  Text(
                    '${isDeduction ? "- " : "+ "}${AppFormatters.currency(entry.value)}',
                    style: AppTypography.footnote.copyWith(
                      color: isDeduction ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppDimens.p20),
          AppleButton(
            label: 'Download PDF Receipt',
            icon: CupertinoIcons.arrow_down_doc_fill,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloaded ${item.id}.pdf to files')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (_isLoading || _data == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    final d = _data!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Payroll & Claims',
          style: AppTypography.title2.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 12),
            child: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.primaryOrange, size: 28),
            onPressed: () {
              SubmitAllowanceModal.show(context).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryOrange,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
          children: [
            // Net Salary Card
            AppleCard(
              hasGlow: true,
              padding: const EdgeInsets.all(AppDimens.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT MONTH TAKE-HOME',
                    style: AppTypography.caption2.copyWith(
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.currency(d.currentMonthNet),
                    style: AppTypography.largeTitle.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Processed and credited on 31 Oct 2026',
                    style: AppTypography.footnote.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Claims Approved', style: AppTypography.caption2.copyWith(color: textSecondary)),
                          Text(
                            AppFormatters.currency(d.allowanceApproved),
                            style: AppTypography.headline.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pending Reimbursement', style: AppTypography.caption2.copyWith(color: textSecondary)),
                          Text(
                            AppFormatters.currency(d.allowancePending),
                            style: AppTypography.headline.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.p20),

            // Tab Switcher
            AppleSegmentedControl<String>(
              children: const {
                'payslips': 'Payslips',
                'allowances': 'Allowances',
                'advances': 'Advances',
              },
              groupValue: _selectedTab,
              onValueChanged: (val) => setState(() => _selectedTab = val),
            ),
            const SizedBox(height: AppDimens.p16),

            if (_selectedTab == 'payslips') ...[
              ...d.payslips.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.p10),
                    child: AppleCard(
                      onTap: () => _showPayslipDetails(p),
                      padding: const EdgeInsets.all(AppDimens.p16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                ),
                                child: const Icon(CupertinoIcons.doc_text_fill, color: AppColors.primaryOrange, size: 20),
                              ),
                              const SizedBox(width: AppDimens.p12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.month,
                                    style: AppTypography.headline.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Disbursed • ${p.disbursementDate}',
                                    style: AppTypography.caption1.copyWith(color: textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatters.currency(p.netPay),
                                style: AppTypography.headline.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Tap to inspect',
                                style: AppTypography.caption2.copyWith(color: AppColors.primaryOrange),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ] else if (_selectedTab == 'allowances') ...[
              ...d.allowances.map((a) {
                final isApproved = a.status == 'approved';
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.p10),
                  child: AppleCard(
                    padding: const EdgeInsets.all(AppDimens.p16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.category,
                                style: AppTypography.headline.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a.description,
                                style: AppTypography.caption1.copyWith(color: textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submitted ${a.submittedDate}',
                                style: AppTypography.caption2.copyWith(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(a.amount),
                              style: AppTypography.headline.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppleChip(
                              label: isApproved ? 'Approved' : 'Pending',
                              tone: isApproved ? ChipTone.green : ChipTone.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              ...d.advances.map((adv) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.p10),
                    child: AppleCard(
                      padding: const EdgeInsets.all(AppDimens.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Salary Advance',
                                style: AppTypography.headline.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppleChip(
                                label: adv.status.toUpperCase(),
                                tone: ChipTone.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            adv.reason,
                            style: AppTypography.footnote.copyWith(color: textSecondary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Requested: ${AppFormatters.currency(adv.requestedAmount)}',
                                style: AppTypography.caption1.copyWith(color: textPrimary),
                              ),
                              Text(
                                'Remaining: ${AppFormatters.currency(adv.remainingBalance)}',
                                style: AppTypography.caption1.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

