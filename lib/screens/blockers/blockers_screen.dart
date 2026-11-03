import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/blocker_model.dart';
import '../../models/project_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/layout/apple_scaffold.dart';
import 'add_blocker_modal.dart';

class BlockersScreen extends StatefulWidget {
  const BlockersScreen({super.key});

  @override
  State<BlockersScreen> createState() => _BlockersScreenState();
}

class _BlockersScreenState extends State<BlockersScreen> {
  List<BlockerModel> _blockers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockers();
  }

  Future<void> _loadBlockers() async {
    setState(() => _isLoading = true);
    final list = await services.blockerService.getBlockers();
    if (mounted) {
      setState(() {
        _blockers = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveBlocker(int id) async {
    await services.blockerService.resolveBlocker(id, 'Marked as resolved from mobile app.');
    _loadBlockers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blocker marked as resolved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AppleScaffold(
      title: 'Blockers',
      subtitle: 'Technical & operational bottlenecks',
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.primaryOrange, size: 28),
          onPressed: () {
            AddBlockerModal.show(context).then((_) => _loadBlockers());
          },
        ),
      ],
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : RefreshIndicator(
              onRefresh: _loadBlockers,
              color: AppColors.primaryOrange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
                children: [
                  ..._blockers.map((b) {
                    final isResolved = b.status == 'resolved';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.p12),
                      child: AppleCard(
                        padding: const EdgeInsets.all(AppDimens.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    b.projectTitle,
                                    style: AppTypography.caption1.copyWith(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppleChip(
                                  label: isResolved
                                      ? 'Resolved'
                                      : (b.priority == Priority.critical ? 'Critical' : 'High Priority'),
                                  tone: isResolved
                                      ? ChipTone.green
                                      : (b.priority == Priority.critical ? ChipTone.red : ChipTone.orange),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimens.p8),
                            Text(
                              b.title,
                              style: AppTypography.headline.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppDimens.p4),
                            Text(
                              b.description,
                              style: AppTypography.footnote.copyWith(color: textSecondary),
                            ),
                            if (b.latestReply != null) ...[
                              const SizedBox(height: AppDimens.p12),
                              Container(
                                padding: const EdgeInsets.all(AppDimens.p10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(CupertinoIcons.chat_bubble_2, size: 14, color: AppColors.primaryOrange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        b.latestReply!,
                                        style: AppTypography.caption1.copyWith(color: textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppDimens.p12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By ${b.createdBy} • ${b.repliesCount} updates',
                                  style: AppTypography.caption2.copyWith(color: textSecondary),
                                ),
                                if (!isResolved)
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _resolveBlocker(b.id),
                                    child: Text(
                                      'Mark Resolved',
                                      style: AppTypography.caption1.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

