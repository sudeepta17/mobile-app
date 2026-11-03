import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../models/project_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/apple_text_field.dart';
import '../../widgets/layout/modal_sheet_wrapper.dart';

class AddBlockerModal extends StatefulWidget {
  const AddBlockerModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalSheetWrapper.show(
      context: context,
      title: 'Report New Blocker',
      child: const AddBlockerModal(),
    );
  }

  @override
  State<AddBlockerModal> createState() => _AddBlockerModalState();
}

class _AddBlockerModalState extends State<AddBlockerModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Priority _selectedPriority = Priority.high;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    await services.blockerService.reportBlocker(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      projectId: 101,
      priority: _selectedPriority,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blocker escalated to tech leads successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppleTextField(
          label: 'Blocker Title',
          placeholder: 'e.g. Gateway 504 on check-in sync',
          controller: _titleController,
          autofocus: true,
        ),
        const SizedBox(height: AppDimens.p16),

        AppleTextField(
          label: 'Details & Impact',
          placeholder: 'Describe what is blocked and which teams are affected...',
          controller: _descController,
          maxLines: 4,
        ),
        const SizedBox(height: AppDimens.p16),

        // Priority selector
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: _selectedPriority == Priority.medium
                    ? AppColors.warning
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                onPressed: () => setState(() => _selectedPriority = Priority.medium),
                child: Text(
                  'Medium',
                  style: TextStyle(
                    color: _selectedPriority == Priority.medium ? Colors.white : null,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: _selectedPriority == Priority.high
                    ? AppColors.primaryOrange
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                onPressed: () => setState(() => _selectedPriority = Priority.high),
                child: Text(
                  'High',
                  style: TextStyle(
                    color: _selectedPriority == Priority.high ? Colors.white : null,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: _selectedPriority == Priority.critical
                    ? AppColors.error
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                onPressed: () => setState(() => _selectedPriority = Priority.critical),
                child: Text(
                  'Critical',
                  style: TextStyle(
                    color: _selectedPriority == Priority.critical ? Colors.white : null,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p24),

        AppleButton(
          label: 'Escalate Blocker',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppDimens.p16),
      ],
    );
  }
}
