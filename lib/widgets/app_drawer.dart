import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../state/auth_state.dart';

enum SidebarItemKey {
  dashboard,
  blockers,
  myTasks,
  projectsAndBuilds,
  applyLeave,
  leaveHistory,
  myAllowance,
  salaryAdvance,
  gymCheckin,
  myCertificates,
  essanecalidraw,
  essaneKeep,
  essaneJsonCrack,
  upcomingHolidays,
}

/// Sidebar Drawer reproducing the exact workspace navigation from
/// https://essaneglobal.com/management/employee/dashboard and media_1793769007641_c7283757.png,
/// seamlessly styled to match both Light and Dark application themes:
/// - Header: Essane Global logo mark + typography
/// - Section: "WORKSPACE"
/// - 14 Navigation items with active indicator pill & orange highlight bar
/// - User footer with avatar, name, employee code, and logout button
class AppDrawer extends StatelessWidget {
  final SidebarItemKey currentItem;
  final AuthState authState;

  const AppDrawer({
    super.key,
    required this.currentItem,
    required this.authState,
  });

  void _navigateTo(BuildContext context, String route) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(); // Close drawer
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final borderCol2 = isDark ? AppColors.darkLine2 : AppColors.lightLine2;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final sectionLabelColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);

    final activeItemBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : accent.withValues(alpha: 0.10);
    final activeTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveTextColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF334155);

    final footerCardBg = isDark ? const Color(0xFF1A1D21) : const Color(0xFFF8FAFC);

    final userName = authState.currentUser?.name ?? 'Sarah Jenkins';
    final userParts = userName.trim().split(RegExp(r'\s+'));
    final userInitials = userParts.length >= 2
        ? '${userParts.first[0]}${userParts.last[0]}'.toUpperCase()
        : (userParts.isNotEmpty && userParts.first.isNotEmpty
            ? userParts.first[0].toUpperCase()
            : 'SJ');

    return Drawer(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
        side: BorderSide(color: borderCol, width: 1.0),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Drawer Header: Essane Global Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  // SVG Geometric Mark (width 26, height 50)
                  SizedBox(
                    width: 26,
                    height: 50,
                    child: CustomPaint(
                      painter: _DrawerLogoPainter(color: accent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Essane',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          fontFamily: 'Poppins',
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Global',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: accent,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: borderCol, height: 1),

            // 2. Section Header: "WORKSPACE"
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 18, bottom: 8),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: sectionLabelColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // 3. Navigation Items List (Scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: [
                  _DrawerItem(
                    icon: CupertinoIcons.square_grid_2x2,
                    label: 'Dashboard',
                    isActive: currentItem == SidebarItemKey.dashboard,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
                    },
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    label: 'Blockers',
                    isActive: currentItem == SidebarItemKey.blockers,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    badgeCount: 2,
                    onTap: () => _navigateTo(context, AppRoutes.blockers),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.checkmark_square,
                    label: 'My Tasks',
                    isActive: currentItem == SidebarItemKey.myTasks,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.tasks),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.folder,
                    label: 'Projects & Builds',
                    isActive: currentItem == SidebarItemKey.projectsAndBuilds,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.projects),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.bag,
                    label: 'Apply Leave',
                    isActive: currentItem == SidebarItemKey.applyLeave,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.applyLeave),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.clock,
                    label: 'Leave History',
                    isActive: currentItem == SidebarItemKey.leaveHistory,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.leaveHistory),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.creditcard,
                    label: 'My Allowance',
                    isActive: currentItem == SidebarItemKey.myAllowance,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.allowance),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.money_dollar,
                    label: 'Salary Advance',
                    isActive: currentItem == SidebarItemKey.salaryAdvance,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.advance),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.checkmark_circle,
                    label: 'Gym Check-in',
                    isActive: currentItem == SidebarItemKey.gymCheckin,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.gym),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.rosette,
                    label: 'My Certificates',
                    isActive: currentItem == SidebarItemKey.myCertificates,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.certificates),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.pencil_outline,
                    label: 'Essanecalidraw',
                    isActive: currentItem == SidebarItemKey.essanecalidraw,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.whiteboard),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.doc_plaintext,
                    label: 'Essane Keep',
                    isActive: currentItem == SidebarItemKey.essaneKeep,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.notes),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.chevron_left_slash_chevron_right,
                    label: 'Essane JSON Crack',
                    isActive: currentItem == SidebarItemKey.essaneJsonCrack,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.jsonCrack),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.calendar,
                    label: 'Upcoming Holidays',
                    isActive: currentItem == SidebarItemKey.upcomingHolidays,
                    accent: accent,
                    activeBg: activeItemBg,
                    activeTextColor: activeTextColor,
                    inactiveTextColor: inactiveTextColor,
                    onTap: () => _navigateTo(context, AppRoutes.holidays),
                  ),
                ],
              ),
            ),

            Divider(color: borderCol, height: 1),

            // 4. User profile pill at footer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: footerCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol2, width: 1.0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                    child: Text(
                      userInitials,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authState.currentUser?.employeeCode ?? 'ESS-0142',
                          style: TextStyle(
                            fontSize: 11,
                            color: textMuted,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.square_arrow_right, size: 18, color: textMuted),
                    tooltip: 'Logout',
                    onPressed: () {
                      authState.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badgeCount;
  final VoidCallback onTap;
  final Color accent;
  final Color activeBg;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.badgeCount,
    required this.onTap,
    required this.accent,
    required this.activeBg,
    required this.activeTextColor,
    required this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: accent.withValues(alpha: 0.05),
          splashColor: accent.withValues(alpha: 0.10),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Active Left Orange Bar indicator matching sidebar design
                Container(
                  width: 3.5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  icon,
                  size: 19,
                  color: isActive ? accent : accent.withValues(alpha: 0.82),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? activeTextColor : inactiveTextColor,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerLogoPainter extends CustomPainter {
  final Color color;

  _DrawerLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 160.0;
    final scaleY = size.height / 300.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);
    canvas.translate(-10.0, 0.0);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(116, 5, 46, 110), const Radius.circular(2)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(116, 195, 46, 100), const Radius.circular(2)),
      fillPaint,
    );

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 46.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(20, 80), const Offset(104, 128), strokePaint);
    canvas.drawLine(const Offset(20, 230), const Offset(104, 182), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrawerLogoPainter oldDelegate) => false;
}

