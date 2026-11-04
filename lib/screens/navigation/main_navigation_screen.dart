import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../state/theme_state.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../dashboard/employee_dashboard_screen.dart';
import '../leaves/leaves_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/my_tasks_screen.dart';
import '../team/team_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AuthState authState;
  final ThemeState themeState;

  const MainNavigationScreen({
    super.key,
    required this.authState,
    required this.themeState,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? AppColors.darkNav.withValues(alpha: 0.92)
        : AppColors.lightNav.withValues(alpha: 0.92);
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final isAdmin = widget.authState.isAdmin;

    final screens = [
      isAdmin
          ? AdminDashboardScreen(authState: widget.authState)
          : EmployeeDashboardScreen(
              authState: widget.authState,
              onNavigateTab: _selectTab,
            ),
      MyTasksScreen(authState: widget.authState),
      const TeamScreen(),
      const LeavesScreen(),
      ProfileScreen(authState: widget.authState, themeState: widget.themeState),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderCol, width: 1.0)),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: CupertinoIcons.home,
                      activeIcon: CupertinoIcons.home,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => _selectTab(0),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.checkmark_square,
                      activeIcon: CupertinoIcons.checkmark_square_fill,
                      label: 'Tasks',
                      isSelected: _currentIndex == 1,
                      onTap: () => _selectTab(1),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.person_2,
                      activeIcon: CupertinoIcons.person_2_fill,
                      label: 'Team',
                      isSelected: _currentIndex == 2,
                      onTap: () => _selectTab(2),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.calendar,
                      activeIcon: CupertinoIcons.calendar,
                      label: 'Leave',
                      isSelected: _currentIndex == 3,
                      onTap: () => _selectTab(3),
                    ),
                    _NavItem(
                      icon: CupertinoIcons.person,
                      activeIcon: CupertinoIcons.person_fill,
                      label: 'Profile',
                      isSelected: _currentIndex == 4,
                      onTap: () => _selectTab(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedCol = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? accent : unselectedCol,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? accent : unselectedCol,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
