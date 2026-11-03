import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';
import '../../services/service_locator.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/common/segmented_control.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  List<ProjectModel> _allProjects = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, in_progress, completed
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (_allProjects.isEmpty) setState(() => _isLoading = true);
    final projects = await services.projectService.getProjects();
    if (mounted) {
      setState(() {
        _allProjects = projects;
        _isLoading = false;
      });
    }
  }

  List<ProjectModel> get _filteredProjects {
    return _allProjects.where((p) {
      final matchesFilter = _selectedFilter == 'all' || p.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Projects',
          style: AppTypography.title2.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? CupertinoIcons.clear_circled_solid : CupertinoIcons.search, size: 22),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : RefreshIndicator(
              onRefresh: _loadProjects,
              color: AppColors.primaryOrange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p8),
                children: [
                  if (_showSearch) ...[
                    CupertinoSearchTextField(
                      placeholder: 'Search projects or codes...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: AppDimens.p12),
                  ],
                  // Segmented Filter
                  AppleSegmentedControl<String>(
                    children: const {
                      'all': 'All Projects',
                      'in_progress': 'In Progress',
                      'completed': 'Completed',
                    },
                    groupValue: _selectedFilter,
                    onValueChanged: (val) => setState(() => _selectedFilter = val),
                  ),
                  const SizedBox(height: AppDimens.p16),

                  if (_filteredProjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.p32),
                      child: Center(
                        child: Text(
                          'No projects in this category',
                          style: AppTypography.callout.copyWith(color: textSecondary),
                        ),
                      ),
                    )
                  else
                    ..._filteredProjects.map((project) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.p12),
                          child: AppleCard(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.projectDetail,
                              arguments: project.id,
                            ),
                            padding: const EdgeInsets.all(AppDimens.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      project.code,
                                      style: AppTypography.caption1.copyWith(
                                        color: AppColors.primaryOrange,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    AppleChip(
                                      label: project.status == 'completed' ? 'Completed' : 'In Progress',
                                      tone: project.status == 'completed' ? ChipTone.green : ChipTone.orange,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.p8),
                                Text(
                                  project.title,
                                  style: AppTypography.headline.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.p4),
                                Text(
                                  project.description,
                                  style: AppTypography.footnote.copyWith(color: textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppDimens.p12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: project.tags
                                      .map((tag) => AppleChip(
                                            label: tag,
                                            tone: ChipTone.neutral,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: AppDimens.p16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: project.progress / 100,
                                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      project.status == 'completed'
                                          ? AppColors.success
                                          : AppColors.primaryOrange,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.p12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(CupertinoIcons.person_2, size: 14, color: textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${project.teamCount} members',
                                          style: AppTypography.caption1.copyWith(color: textSecondary),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${project.progress}% completed',
                                      style: AppTypography.caption1.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
