import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';
import '../../services/service_locator.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';
import '../../widgets/common/apple_card.dart';
import '../../widgets/common/apple_chip.dart';
import '../../widgets/common/segmented_control.dart';

class BuildArtifact {
  final String version;
  final String buildNumber;
  final String platform; // 'Android APK', 'iOS IPA', 'Web Bundle'
  final String date;
  final String size;
  final String downloadUrl;

  const BuildArtifact({
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.date,
    required this.size,
    required this.downloadUrl,
  });
}

class ProjectsListScreen extends StatefulWidget {
  final AuthState? authState;

  const ProjectsListScreen({super.key, this.authState});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  List<ProjectModel> _allProjects = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _showSearch = false;

  final List<BuildArtifact> _builds = const [
    BuildArtifact(
      version: 'v2.4.1 (Build 142)',
      buildNumber: '142',
      platform: 'Android APK',
      date: 'Today, 11:20 AM',
      size: '34.8 MB',
      downloadUrl: 'https://essaneglobal.com/builds/essane-v2.4.1.apk',
    ),
    BuildArtifact(
      version: 'v2.4.1 (Build 142)',
      buildNumber: '142',
      platform: 'iOS IPA (Ad-Hoc)',
      date: 'Today, 11:45 AM',
      size: '52.1 MB',
      downloadUrl: 'https://essaneglobal.com/builds/essane-v2.4.1.ipa',
    ),
    BuildArtifact(
      version: 'v2.4.0 (Build 141)',
      buildNumber: '141',
      platform: 'Web Production',
      date: 'Yesterday, 6:00 PM',
      size: '18.2 MB',
      downloadUrl: 'https://essaneglobal.com/management',
    ),
  ];

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
    final filter = _selectedFilter;
    final query = _searchQuery;
    return _allProjects.where((p) {
      final matchesFilter = filter == 'all' || p.status == filter;
      final matchesSearch = query.isEmpty ||
          p.title.toLowerCase().contains(query.toLowerCase()) ||
          p.code.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showQrCodeModal(BuildArtifact build) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E2024) : Colors.white;
        final textPri = isDark ? Colors.white : const Color(0xFF1E293B);

        return Dialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Download on Device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.qrcode, size: 120, color: const Color(0xFF121417)),
                        Text(
                          build.platform,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  build.version,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPri),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan with phone camera or QR scanner',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8590C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(CupertinoIcons.cloud_download, color: Colors.white, size: 18),
                    label: const Text('Direct Download', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading ${build.platform} (${build.size})...')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.projectsAndBuilds,
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
          'Projects & Builds',
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
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppHeaderBackButton(),
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
                      placeholder: 'Search projects, codes, leads...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: AppDimens.p12),
                  ],
                  // Segmented Filter
                  AppleSegmentedControl<String>(
                    children: const {
                      'all': 'All Projects',
                      'in_progress': 'Active',
                      'completed': 'Done',
                      'builds': 'Builds',
                    },
                    groupValue: _selectedFilter,
                    onValueChanged: (val) => setState(() => _selectedFilter = val),
                  ),
                  const SizedBox(height: AppDimens.p16),

                  if (_selectedFilter == 'builds') ...[
                    // Builds tab
                    ..._builds.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.p12),
                        child: AppleCard(
                          padding: const EdgeInsets.all(AppDimens.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8590C).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      b.platform.contains('Android')
                                          ? CupertinoIcons.device_phone_portrait
                                          : b.platform.contains('iOS')
                                              ? CupertinoIcons.device_phone_portrait
                                              : CupertinoIcons.globe,
                                      color: const Color(0xFFE8590C),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.platform,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          '${b.version} · ${b.size}',
                                          style: TextStyle(fontSize: 12, color: textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(CupertinoIcons.qrcode, color: Color(0xFFE8590C)),
                                    onPressed: () => _showQrCodeModal(b),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(CupertinoIcons.clock, size: 12, color: textSecondary),
                                  const SizedBox(width: 4),
                                  Text(b.date, style: TextStyle(fontSize: 11, color: textSecondary)),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Starting download for ${b.platform}...')),
                                      );
                                    },
                                    icon: const Icon(CupertinoIcons.arrow_down_to_line, size: 14),
                                    label: const Text('Download', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    // Projects List
                    if (_filteredProjects.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text('No projects found', style: TextStyle(color: textSecondary)),
                        ),
                      )
                    else
                      ..._filteredProjects.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.p12),
                          child: AppleCard(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.projectDetail, arguments: p.id);
                            },
                            padding: const EdgeInsets.all(AppDimens.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppleChip(
                                      label: p.code,
                                      tone: ChipTone.neutral,
                                    ),
                                    AppleChip(
                                      label: p.status == 'in_progress' ? 'In Progress' : 'Completed',
                                      tone: p.status == 'in_progress'
                                          ? ChipTone.amber
                                          : ChipTone.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.p12),
                                Text(
                                  p.title,
                                  style: AppTypography.headline.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.p4),
                                Text(
                                  p.client,
                                  style: AppTypography.subhead.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.p16),
                                // Progress bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress',
                                      style: AppTypography.caption1.copyWith(color: textSecondary),
                                    ),
                                    Text(
                                      '${p.progress}%',
                                      style: AppTypography.caption1.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.p4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                  child: LinearProgressIndicator(
                                    value: p.progress / 100,
                                    backgroundColor: isDark
                                        ? AppColors.darkSurfaceSecondary
                                        : AppColors.lightSurfaceSecondary,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      p.progress == 100 ? AppColors.darkGreen : AppColors.primaryOrange,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
    );
  }
}
