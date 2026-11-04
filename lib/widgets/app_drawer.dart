import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/navigation/app_routes.dart';
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

/// Sidebar Drawer reproducing the exact dark workspace navigation from
/// https://essaneglobal.com/management/employee/dashboard and media_1793769007641_c7283757.png:
/// - Header: Orange "Essane Global" mark + typography
/// - Section: "WORKSPACE"
/// - 14 Navigation items with active indicator pill & orange highlight bar
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
    const bg = Color(0xFF121417);
    const borderCol = Color(0x1FFFFFFF);
    const accent = Color(0xFFE8590C);

    return Drawer(
      backgroundColor: bg,
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
                    children: const [
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
                      SizedBox(height: 2),
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

            const Divider(color: borderCol, height: 1),

            // 2. Section Header: "WORKSPACE"
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 18, bottom: 8),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF6B7280),
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
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
                    },
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    label: 'Blockers',
                    isActive: currentItem == SidebarItemKey.blockers,
                    badgeCount: 2,
                    onTap: () => _navigateTo(context, AppRoutes.blockers),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.checkmark_square,
                    label: 'My Tasks',
                    isActive: currentItem == SidebarItemKey.myTasks,
                    onTap: () => _navigateTo(context, AppRoutes.tasks),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.folder,
                    label: 'Projects & Builds',
                    isActive: currentItem == SidebarItemKey.projectsAndBuilds,
                    onTap: () => _navigateTo(context, AppRoutes.projects),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.bag,
                    label: 'Apply Leave',
                    isActive: currentItem == SidebarItemKey.applyLeave,
                    onTap: () => _navigateTo(context, AppRoutes.applyLeave),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.clock,
                    label: 'Leave History',
                    isActive: currentItem == SidebarItemKey.leaveHistory,
                    onTap: () => _navigateTo(context, AppRoutes.leaveHistory),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.creditcard,
                    label: 'My Allowance',
                    isActive: currentItem == SidebarItemKey.myAllowance,
                    onTap: () => _navigateTo(context, AppRoutes.allowance),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.money_dollar,
                    label: 'Salary Advance',
                    isActive: currentItem == SidebarItemKey.salaryAdvance,
                    onTap: () => _navigateTo(context, AppRoutes.advance),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.checkmark_circle,
                    label: 'Gym Check-in',
                    isActive: currentItem == SidebarItemKey.gymCheckin,
                    onTap: () => _navigateTo(context, AppRoutes.gym),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.rosette,
                    label: 'My Certificates',
                    isActive: currentItem == SidebarItemKey.myCertificates,
                    onTap: () => _navigateTo(context, AppRoutes.certificates),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.pencil_outline,
                    label: 'Essanecalidraw',
                    isActive: currentItem == SidebarItemKey.essanecalidraw,
                    onTap: () => _navigateTo(context, AppRoutes.whiteboard),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.doc_plaintext,
                    label: 'Essane Keep',
                    isActive: currentItem == SidebarItemKey.essaneKeep,
                    onTap: () => _navigateTo(context, AppRoutes.notes),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.chevron_left_slash_chevron_right,
                    label: 'Essane JSON Crack',
                    isActive: currentItem == SidebarItemKey.essaneJsonCrack,
                    onTap: () => _navigateTo(context, AppRoutes.jsonCrack),
                  ),
                  _DrawerItem(
                    icon: CupertinoIcons.calendar,
                    label: 'Upcoming Holidays',
                    isActive: currentItem == SidebarItemKey.upcomingHolidays,
                    onTap: () => _navigateTo(context, AppRoutes.holidays),
                  ),
                ],
              ),
            ),

            const Divider(color: borderCol, height: 1),

            // 4. User profile pill at footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: accent.withValues(alpha: 0.2),
                    child: const Text(
                      'SJ',
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
                          authState.currentUser?.name ?? 'Sarah Jenkins',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authState.currentUser?.employeeCode ?? 'ESS-0142',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.square_arrow_right, size: 18, color: Color(0xFF9CA3AF)),
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

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8590C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
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
                  color: isActive ? accent : const Color(0xFFEA580C).withValues(alpha: 0.8),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : const Color(0xFFD1D5DB),
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
                      color: const Color(0xFFD97706),
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

