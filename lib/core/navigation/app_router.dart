import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../screens/attendance/attendance_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/blockers/blockers_screen.dart';
import '../../screens/holidays/holidays_screen.dart';
import '../../screens/leaves/leaves_screen.dart';
import '../../screens/navigation/main_navigation_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/payroll/payroll_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/projects/project_detail_screen.dart';
import '../../screens/projects/projects_list_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/tasks/my_tasks_screen.dart';
import '../../screens/team/team_screen.dart';
import '../../state/auth_state.dart';
import '../../state/theme_state.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthState authState;
  final ThemeState themeState;

  AppRouter({required this.authState, required this.themeState});

  Route<dynamic> buildSplashRoute({String? targetRoute}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          SplashScreen(authState: authState, targetRoute: targetRoute),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
      settings: const RouteSettings(name: AppRoutes.splash),
    );
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.splash:
        final target = settings.arguments as String?;
        return buildSplashRoute(targetRoute: target);

      case AppRoutes.main:
        return CupertinoPageRoute(
          builder: (_) => MainNavigationScreen(
            authState: authState,
            themeState: themeState,
          ),
          settings: settings,
        );

      case AppRoutes.login:
        return CupertinoPageRoute(
          builder: (_) => LoginScreen(authState: authState),
          settings: settings,
        );

      case AppRoutes.projects:
        return CupertinoPageRoute(
          builder: (_) => const ProjectsListScreen(),
          settings: settings,
        );

      case AppRoutes.projectDetail:
        final id = settings.arguments as int? ?? 101;
        return CupertinoPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: id),
          settings: settings,
        );

      case AppRoutes.tasks:
        return CupertinoPageRoute(
          builder: (_) => const MyTasksScreen(),
          settings: settings,
        );

      case AppRoutes.team:
        return CupertinoPageRoute(
          builder: (_) => const TeamScreen(),
          settings: settings,
        );

      case AppRoutes.notifications:
        return CupertinoPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      case AppRoutes.blockers:
        return CupertinoPageRoute(
          builder: (_) => const BlockersScreen(),
          settings: settings,
        );

      case AppRoutes.leaves:
        return CupertinoPageRoute(
          builder: (_) => const LeavesScreen(),
          settings: settings,
        );

      case AppRoutes.attendance:
        return CupertinoPageRoute(
          builder: (_) => const AttendanceScreen(),
          settings: settings,
        );

      case AppRoutes.payroll:
        return CupertinoPageRoute(
          builder: (_) => const PayrollScreen(),
          settings: settings,
        );

      case AppRoutes.holidays:
        return CupertinoPageRoute(
          builder: (_) => const HolidaysScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return CupertinoPageRoute(
          builder: (_) => ProfileScreen(
            authState: authState,
            themeState: themeState,
          ),
          settings: settings,
        );

      default:
        return CupertinoPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}

