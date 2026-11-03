import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/layout/apple_scaffold.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectModel? _project;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    final p = await services.projectService.getProjectById(widget.projectId);
    if (mounted) {
      setState(() {
        _project = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTask(int taskId) async {
    HapticFeedback.lightImpact();
    await services.projectService.toggleTaskStatus(taskId);
    _loadProject();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (_isLoading || _project == null) {
      return AppleScaffold(
        title: 'Project Details',
        body: const Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    final p = _project!;

    return AppleScaffold(
      title: p.code,
      subtitle: p.client,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.title,
                    style: AppTypography.title2.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppleChip(
                  label: p.status == 'completed' ? 'Completed' : 'In Progress',
                  tone: p.status == 'completed' ? ChipTone.green : ChipTone.orange,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p8),
            Text(
              p.description,
              style: AppTypography.body.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppDimens.p16),

            // Progress Banner
            AppleCard(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Completion',
                        style: AppTypography.subhead.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${p.progress}%',
                        style: AppTypography.title3.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.progress / 100,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppDimens.p12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${p.tasksCompleted} of ${p.tasksTotal} tasks completed',
                        style: AppTypography.footnote.copyWith(color: textSecondary),
                      ),
                      Text(
                        'Due date: ${p.dueDate}',
                        style: AppTypography.footnote.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.p20),

            // Lead & Team Meta
            Row(
              children: [
                Expanded(
                  child: AppleCard(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROJECT LEAD',
                          style: AppTypography.caption2.copyWith(color: textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.leadName,
                          style: AppTypography.subhead.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                Expanded(
                  child: AppleCard(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TEAM ASSIGNED',
                          style: AppTypography.caption2.copyWith(color: textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.teamCount} Engineers',
                          style: AppTypography.subhead.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p24),

            // Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milestones & Tasks',
                  style: AppTypography.title3.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Tap to complete',
                  style: AppTypography.caption1.copyWith(color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p12),

            if (p.tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimens.p24),
                child: Center(
                  child: Text(
                    'No open tasks for this project',
                    style: AppTypography.callout.copyWith(color: textSecondary),
                  ),
                ),
              )
            else
              ...p.tasks.map((task) {
                final isDone = task.status == TaskStatus.completed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.p8),
                  child: AppleCard(
                    onTap: () => _toggleTask(task.id),
                    padding: const EdgeInsets.all(AppDimens.p14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isDone
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.circle,
                          color: isDone ? AppColors.success : textSecondary.withValues(alpha: 0.4),
                          size: 22,
                        ),
                        const SizedBox(width: AppDimens.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: AppTypography.subhead.copyWith(
                                  color: isDone ? textSecondary : textPrimary,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                task.description,
                                style: AppTypography.caption1.copyWith(color: textSecondary),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(CupertinoIcons.person, size: 12, color: textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.assignee,
                                    style: AppTypography.caption2.copyWith(color: textSecondary),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(CupertinoIcons.clock, size: 12, color: textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.dueDate,
                                    style: AppTypography.caption2.copyWith(color: textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: AppDimens.p32),
          ],
        ),
      ),
    );
  }
}

