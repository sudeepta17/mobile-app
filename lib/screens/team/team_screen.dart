import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Team Member Model matching team.html line 24:
/// ['Team Member 1', 'Team Lead', 'Online']
class TeamMemberData {
  final String name;
  final String role;
  final String status; // 'Online', 'Away', 'On leave'
  final String initials;

  const TeamMemberData({
    required this.name,
    required this.role,
    required this.status,
    required this.initials,
  });
}

/// Team Screen mirroring team.html & styles.css
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';

  // Team members array matching team.html lines 24-31
  final List<TeamMemberData> _members = const [
    TeamMemberData(
      name: 'Team Member 1',
      role: 'Team Lead',
      status: 'Online',
      initials: 'TM',
    ),
    TeamMemberData(
      name: 'Team Member 2',
      role: 'Designer',
      status: 'Online',
      initials: 'TM',
    ),
    TeamMemberData(
      name: 'Team Member 3',
      role: 'Developer',
      status: 'Away',
      initials: 'TM',
    ),
    TeamMemberData(
      name: 'Team Member 4',
      role: 'Analyst',
      status: 'Online',
      initials: 'TM',
    ),
    TeamMemberData(
      name: 'Team Member 5',
      role: 'Accountant',
      status: 'On leave',
      initials: 'TM',
    ),
    TeamMemberData(
      name: 'Team Member 6',
      role: 'Coordinator',
      status: 'Away',
      initials: 'TM',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeamMemberData> get _filteredMembers {
    if (_searchTerm.trim().isEmpty) return _members;
    final term = _searchTerm.toLowerCase().trim();
    return _members.where((m) {
      return '${m.name} ${m.role}'.toLowerCase().contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final textSoft = isDark ? AppColors.darkSoft : AppColors.lightSoft;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final accentGlow = isDark ? AppColors.darkAccentGlow : AppColors.lightAccentSoft;
    final green = isDark ? AppColors.darkGreen : AppColors.lightGreen;

    // Status dot color matching var dot = { 'Online': 'var(--green)', 'Away': 'var(--accent)', 'On leave': 'var(--muted)' }
    Color getDotColor(String status) {
      switch (status) {
        case 'Online':
          return green;
        case 'Away':
          return accent;
        case 'On leave':
        default:
          return textMuted;
      }
    }

    final filtered = _filteredMembers;
    final countText = 'Team Alpha · ${filtered.length} member${filtered.length == 1 ? "" : "s"}';

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top Ambient Glow from styles.css: radial-gradient(circle at 85% 0, var(--accent-glow) 0%, transparent 65%)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 300,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -1.0),
                    radius: 0.85,
                    colors: [
                      accentGlow,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
          ),

          // Main Page Content (.app > .page in team.html)
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 104),
              children: [
                // 1. Header (team.html line 15: <header class="col" style="gap:2px"><h1>Team</h1><p class="sub" id="count">Team Alpha</p></header>)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        height: 1.2,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Search Bar (team.html line 16: <div class="search"><i data-icon="search"></i><input id="q" type="search"...>)
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderCol2, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        CupertinoIcons.search,
                        size: 18,
                        color: textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          cursorColor: accent,
                          style: TextStyle(
                            fontSize: 14,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'Search team members',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: textMuted,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          onChanged: (val) {
                            setState(() => _searchTerm = val);
                          },
                        ),
                      ),
                      if (_searchTerm.isNotEmpty)
                        IconButton(
                          icon: Icon(CupertinoIcons.clear_circled_solid, size: 16, color: textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchTerm = '');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Team Members List (.list in team.html line 17)
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No team members match your search.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final dotColor = getDotColor(item.status);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            // .avatar (styles.css: 44x44, radius 50%, color: var(--accent), background: var(--accent-soft))
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentSoft,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.initials,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // .grow (.t & .m)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // .t (font-size: 14px, font-weight: 500, line-height: 1.35)
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                      height: 1.35,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // .m (font-size: 12px, color: var(--muted))
                                  Text(
                                    item.role,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: textMuted,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status row (<div class="row" style="gap:6px;font-size:11px;color:var(--soft)"><span class="dot" style="width:8px;height:8px;background:...'></span>Status</div>)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: textSoft,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
