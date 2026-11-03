import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:essane_management/main.dart';
import 'package:essane_management/screens/auth/login_screen.dart';
import 'package:essane_management/screens/leaves/leaves_screen.dart';
import 'package:essane_management/screens/notifications/notifications_screen.dart';
import 'package:essane_management/screens/profile/profile_screen.dart';
import 'package:essane_management/screens/tasks/my_tasks_screen.dart';
import 'package:essane_management/screens/team/team_screen.dart';
import 'package:essane_management/state/auth_state.dart';
import 'package:essane_management/state/theme_state.dart';

void main() {
  testWidgets('Essane Mobile App smoke test', (WidgetTester tester) async {
    final authState = AuthState();
    final themeState = ThemeState();

    await tester.pumpWidget(EssaneMobileApp(
      authState: authState,
      themeState: themeState,
    ));

    expect(find.byType(EssaneMobileApp), findsOneWidget);
  });

  testWidgets('LeavesScreen renders exact leave.html structure', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LeavesScreen(),
      ),
    );
    await tester.pump();

    // 1. Header
    expect(find.text('Leave'), findsOneWidget);
    expect(find.text('Balance and requests'), findsOneWidget);

    // 2. Balance Tiles (.grid3)
    expect(find.text('Casual'), findsOneWidget);
    expect(find.text('Sick'), findsOneWidget);
    expect(find.text('Earned'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);

    // 3. Apply Button
    expect(find.text('Apply for leave'), findsOneWidget);

    // 4. Recent Requests
    expect(find.text('Recent requests'), findsOneWidget);
    expect(find.text('Casual leave'), findsOneWidget);
    expect(find.text('Sick leave'), findsOneWidget);
    expect(find.text('Earned leave'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('LoginScreen renders exact login.html structure', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authState: authState),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Brand Row
    expect(find.text('Essane'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);

    // 2. Heading
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to your workspace to continue.'), findsOneWidget);

    // 3. Form Fields
    expect(find.text('Work email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    // 4. Sign in button
    expect(find.text('Sign in'), findsOneWidget);

    // 5. Copyright
    expect(find.text('© 2026 Essane Global'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders exact notifications.html structure', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    await tester.pump();

    // 1. Header with back button & title
    expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    // 2. List of notifications matching notifications.html
    expect(find.text('Leave request approved'), findsOneWidget);
    expect(find.text('Your casual leave for 20 – 21 Oct was approved.'), findsOneWidget);
    expect(find.text('2 hours ago'), findsOneWidget);

    expect(find.text('New task assigned'), findsOneWidget);
    expect(find.text('Review project brief has been assigned to you.'), findsOneWidget);
    expect(find.text('5 hours ago'), findsOneWidget);

    expect(find.text('Timesheet reminder'), findsOneWidget);
    expect(find.text('Submit your weekly timesheet before 5:00 PM today.'), findsOneWidget);

    expect(find.text('Task completed'), findsOneWidget);
    expect(find.text('Attend onboarding session was marked as done.'), findsOneWidget);

    expect(find.text('Leave request rejected'), findsOneWidget);
    expect(find.text('Your earned leave for 1 – 3 Sep was not approved.'), findsOneWidget);
    expect(find.text('2 days ago'), findsOneWidget);

    // 3. Test tapping unread notification
    await tester.tap(find.text('Leave request approved'));
    await tester.pump();
  });

  testWidgets('ProfileScreen renders exact profile.html structure', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authState = AuthState();
    final themeState = ThemeState();

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          authState: authState,
          themeState: themeState,
        ),
      ),
    );
    await tester.pump();

    // 1. Header (Avatar & titles)
    expect(find.text('Sarah Jenkins'), findsOneWidget);
    expect(find.text('Senior Fullstack Engineer · Engineering'), findsOneWidget);

    // 2. Details Section (.card.rows aria-label="Details")
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Joined'), findsOneWidget);

    // 3. Settings Section (.card.rows aria-label="Settings")
    expect(find.text('White theme'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Help and support'), findsOneWidget);

    // 4. Sign out button (.btn.danger)
    expect(find.text('Sign out'), findsOneWidget);

    // 5. Test toggling white theme switch
    await tester.tap(find.text('White theme'));
    await tester.pump();
  });

  testWidgets('MyTasksScreen renders exact tasks.html structure and filters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyTasksScreen(),
      ),
    );
    await tester.pump();

    // 1. Header & Summary
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('5 shown · 5 total'), findsOneWidget);

    // 2. Filter chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsNWidgets(3)); // 1 chip + 2 task status badges
    expect(find.text('In progress'), findsNWidgets(3)); // 1 chip + 2 task status badges
    expect(find.text('Done'), findsNWidgets(2)); // 1 chip + 1 task status badge

    // 3. Tasks list
    expect(find.text('Submit weekly timesheet'), findsOneWidget);
    expect(find.text('Review project brief'), findsOneWidget);
    expect(find.text('Update client records'), findsOneWidget);
    expect(find.text('Prepare monthly report'), findsOneWidget);
    expect(find.text('Attend onboarding session'), findsOneWidget);

    // 4. Filter interaction (tap the Pending chip)
    await tester.tap(find.text('Pending').first);
    await tester.pump();
    expect(find.text('2 shown · 5 total'), findsOneWidget);
  });

  testWidgets('TeamScreen renders exact team.html structure and search', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TeamScreen(),
      ),
    );
    await tester.pump();

    // 1. Header & Count
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Team Alpha · 6 members'), findsOneWidget);

    // 2. Search Box
    expect(find.byType(TextField), findsOneWidget);

    // 3. Team Members
    expect(find.text('Team Member 1'), findsOneWidget);
    expect(find.text('Team Lead'), findsOneWidget);
    expect(find.text('Designer'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('Analyst'), findsOneWidget);
    expect(find.text('Accountant'), findsOneWidget);
    expect(find.text('Coordinator'), findsOneWidget);

    // 4. Search Filter
    await tester.enterText(find.byType(TextField), 'Designer');
    await tester.pump();
    expect(find.text('Team Alpha · 1 member'), findsOneWidget);
    expect(find.text('Team Member 2'), findsOneWidget);
    expect(find.text('Team Member 1'), findsNothing);
  });
}
