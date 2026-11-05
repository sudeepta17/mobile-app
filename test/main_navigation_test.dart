import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:essane_management/state/auth_state.dart';
import 'package:essane_management/state/theme_state.dart';
import 'package:essane_management/screens/navigation/main_navigation_screen.dart';

void main() {
  testWidgets('MainNavigationScreen tabs can be clicked without throwing', (WidgetTester tester) async {
    final authState = AuthState();
    final themeState = ThemeState();
    await authState.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: MainNavigationScreen(
          authState: authState,
          themeState: themeState,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Tasks tab (index 1)
    await tester.tap(find.text('Tasks'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Team tab (index 2)
    await tester.tap(find.text('Team'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Leave tab (index 3)
    await tester.tap(find.text('Leave'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Profile tab (index 4)
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Home tab (index 0)
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}

