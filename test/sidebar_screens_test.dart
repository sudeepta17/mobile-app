import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:essane_management/core/navigation/app_routes.dart';
import 'package:essane_management/screens/blockers/blockers_screen.dart';
import 'package:essane_management/screens/certificates/employee_certificates_screen.dart';
import 'package:essane_management/screens/gym/gym_checkin_screen.dart';
import 'package:essane_management/screens/holidays/holidays_screen.dart';
import 'package:essane_management/screens/leaves/apply_leave_screen.dart';
import 'package:essane_management/screens/leaves/leave_history_screen.dart';
import 'package:essane_management/screens/payroll/advance_management_screen.dart';
import 'package:essane_management/screens/payroll/allowance_submit_screen.dart';
import 'package:essane_management/screens/projects/projects_list_screen.dart';
import 'package:essane_management/screens/tasks/my_tasks_screen.dart';
import 'package:essane_management/screens/tools/json_crack_screen.dart';
import 'package:essane_management/screens/tools/notes_screen.dart';
import 'package:essane_management/screens/tools/whiteboard_screen.dart';
import 'package:essane_management/state/auth_state.dart';
import 'package:essane_management/widgets/app_drawer.dart';

void main() {
  Widget createTestWidget(Widget child, {AuthState? authState}) {
    final state = authState ?? AuthState();
    return MaterialApp(
      home: child,
      routes: {
        AppRoutes.main: (_) => const Scaffold(body: Text('Main Screen')),
        AppRoutes.blockers: (_) => BlockersScreen(authState: state),
        AppRoutes.tasks: (_) => MyTasksScreen(authState: state),
        AppRoutes.projects: (_) => ProjectsListScreen(authState: state),
        AppRoutes.applyLeave: (_) => ApplyLeaveScreen(authState: state),
        AppRoutes.leaveHistory: (_) => LeaveHistoryScreen(authState: state),
        AppRoutes.allowance: (_) => AllowanceSubmitScreen(authState: state),
        AppRoutes.advance: (_) => AdvanceManagementScreen(authState: state),
        AppRoutes.gym: (_) => GymCheckinScreen(authState: state),
        AppRoutes.certificates: (_) => EmployeeCertificatesScreen(authState: state),
        AppRoutes.whiteboard: (_) => WhiteboardScreen(authState: state),
        AppRoutes.notes: (_) => NotesScreen(authState: state),
        AppRoutes.jsonCrack: (_) => JsonCrackScreen(authState: state),
        AppRoutes.holidays: (_) => HolidaysScreen(authState: state),
      },
    );
  }

  testWidgets('AppDrawer renders all 14 workspace items from sidebar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authState = AuthState();

    await tester.pumpWidget(
      createTestWidget(
        Scaffold(
          drawer: AppDrawer(
            currentItem: SidebarItemKey.dashboard,
            authState: authState,
          ),
          body: const Text('Home'),
        ),
        authState: authState,
      ),
    );

    // Open drawer
    final scaffoldFinder = find.byType(Scaffold);
    final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder);
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Verify Essane Global Header
    expect(find.text('Essane'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);
    expect(find.text('WORKSPACE'), findsOneWidget);

    // Verify all 14 sidebar items exist in the drawer
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Projects & Builds'), findsOneWidget);
    expect(find.text('Apply Leave'), findsOneWidget);
    expect(find.text('Leave History'), findsOneWidget);
    expect(find.text('My Allowance'), findsOneWidget);
    expect(find.text('Salary Advance'), findsOneWidget);
    expect(find.text('Gym Check-in'), findsOneWidget);
    expect(find.text('My Certificates'), findsOneWidget);
    expect(find.text('Essanecalidraw'), findsOneWidget);
    expect(find.text('Essane Keep'), findsOneWidget);
    expect(find.text('Essane JSON Crack'), findsOneWidget);
    expect(find.text('Upcoming Holidays'), findsOneWidget);

    // Verify User Footer info
    expect(find.text('Sarah Jenkins'), findsOneWidget);
    expect(find.text('ESS-0142'), findsOneWidget);
  });

  testWidgets('BlockersScreen renders tabs and lists blockers', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(BlockersScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('New Blocker'), findsOneWidget);
    expect(find.textContaining('Waiting ('), findsOneWidget);
    expect(find.textContaining('Replied ('), findsOneWidget);
    expect(find.textContaining('Solved ('), findsOneWidget);
  });

  testWidgets('ApplyLeaveScreen renders leave balances and form', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(ApplyLeaveScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Apply Leave'), findsOneWidget);
    expect(find.text('Your Leave Balances'), findsOneWidget);
    expect(find.text('Casual'), findsOneWidget);
    expect(find.text('Sick'), findsOneWidget);
    expect(find.text('Earned'), findsOneWidget);
    expect(find.text('Submit Leave Application'), findsOneWidget);
  });

  testWidgets('LeaveHistoryScreen renders filter chips and list', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(LeaveHistoryScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Leave History'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
  });

  testWidgets('AllowanceSubmitScreen renders type cards and claims history', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(AllowanceSubmitScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('My Allowance'), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);
    expect(find.text('Submit Claim'), findsOneWidget);
  });

  testWidgets('AdvanceManagementScreen renders outstanding balance and form', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(AdvanceManagementScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Salary Advance'), findsOneWidget);
    expect(find.text('Current Outstanding'), findsOneWidget);
    expect(find.text('Submit Request'), findsOneWidget);
  });

  testWidgets('GymCheckinScreen renders streak counter and punch action', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(GymCheckinScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Gym Check-in'), findsOneWidget);
    expect(find.textContaining('Days Streak!'), findsOneWidget);
    expect(find.text('Punch Today'), findsOneWidget);
  });

  testWidgets('EmployeeCertificatesScreen renders certificates list', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(EmployeeCertificatesScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('My Certificates'), findsOneWidget);
    expect(find.textContaining('Certificate'), findsWidgets);
    expect(find.text('View & Download'), findsWidgets);
  });

  testWidgets('WhiteboardScreen renders toolbar and drawing canvas', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(WhiteboardScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Essanecalidraw'), findsOneWidget);
    expect(find.text('Pen'), findsOneWidget);
    expect(find.text('Eraser'), findsOneWidget);
  });

  testWidgets('NotesScreen renders keep notes and checklist', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(NotesScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Essane Keep'), findsOneWidget);
    expect(find.text('PINNED'), findsOneWidget);
  });

  testWidgets('JsonCrackScreen renders editor and tree visualizer tabs', (WidgetTester tester) async {
    final authState = AuthState();

    await tester.pumpWidget(createTestWidget(JsonCrackScreen(authState: authState), authState: authState));
    await tester.pumpAndSettle();

    expect(find.text('Essane JSON Crack'), findsOneWidget);
    expect(find.text('JSON Editor'), findsOneWidget);
    expect(find.text('Tree Visualizer'), findsOneWidget);
  });
}
