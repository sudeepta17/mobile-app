import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/apple_text_field.dart';
import '../../widgets/layout/modal_sheet_wrapper.dart';

class SubmitAllowanceModal extends StatefulWidget {
  const SubmitAllowanceModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalSheetWrapper.show(
      context: context,
      title: 'Claim Expense Allowance',
      child: const SubmitAllowanceModal(),
    );
  }

  @override
  State<SubmitAllowanceModal> createState() => _SubmitAllowanceModalState();
}

class _SubmitAllowanceModalState extends State<SubmitAllowanceModal> {
  String _category = 'Broadband & Mobile';
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _isLoading = true);

    await services.payrollService.submitAllowance(
      category: _category,
      amount: amount,
      description: _descController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allowance claim submitted for finance review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Expense Category',
          style: AppTypography.footnote.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimens.p8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              items: const [
                DropdownMenuItem(value: 'Broadband & Mobile', child: Text('Broadband & Mobile')),
                DropdownMenuItem(value: 'Client Dinners & Travel', child: Text('Client Dinners & Travel')),
                DropdownMenuItem(value: 'Software & Tools', child: Text('Software & Tools')),
                DropdownMenuItem(value: 'Hardware & Ergonomics', child: Text('Hardware & Ergonomics')),
              ],
              onChanged: (val) => setState(() => _category = val!),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.p16),

        AppleTextField(
          label: 'Amount (₹)',
          placeholder: 'e.g. 2500',
          controller: _amountController,
          keyboardType: TextInputType.number,
          prefixIcon: CupertinoIcons.money_dollar,
        ),
        const SizedBox(height: AppDimens.p16),

        AppleTextField(
          label: 'Description / Purpose',
          placeholder: 'Bill reference, project context or client event...',
          controller: _descController,
          maxLines: 3,
        ),
        const SizedBox(height: AppDimens.p24),

        AppleButton(
          label: 'Submit Claim',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppDimens.p16),
      ],
    );
  }
}

