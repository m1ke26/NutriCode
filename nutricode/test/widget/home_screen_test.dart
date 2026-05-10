import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/home_screen.dart';
import '../mock_helper.dart';

void main() {
  group('HomeScreen / Bottom Navigation Bar Tests', () {
    testWidgets('renders bottom navigation bar with three tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Check all three nav items exist
      expect(find.byKey(const Key('nav_profile')), findsOneWidget);
      expect(find.byKey(const Key('nav_scan')), findsOneWidget);
      expect(find.byKey(const Key('nav_search')), findsOneWidget);
    });

    testWidgets('starts on the Scan tab by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // The scanner tab AppBar title should be visible
      expect(find.text('NutriCode'), findsOneWidget);
    });

    testWidgets('tapping Profile tab navigates to profile screen',
        (WidgetTester tester) async {
      // Use a larger surface to avoid overflow
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap profile tab
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();

      // Profile screen content should appear
      expect(find.text('My Profile'), findsWidgets);
    });

    testWidgets('tapping Search tab navigates to search screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap search tab
      await tester.tap(find.byKey(const Key('nav_search')));
      await tester.pumpAndSettle();

      // Search screen content should appear
      expect(find.text('Search Products'), findsOneWidget);
      expect(find.text('Type a product name to search'), findsOneWidget);
    });

    testWidgets('tapping Scan tab from another tab returns to scanner',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Go to Search first
      await tester.tap(find.byKey(const Key('nav_search')));
      await tester.pumpAndSettle();
      expect(find.text('Search Products'), findsOneWidget);

      // Go back to Scan
      await tester.tap(find.byKey(const Key('nav_scan')));
      await tester.pumpAndSettle();

      // Scanner screen should be visible
      expect(find.text('NutriCode'), findsOneWidget);
    });

    testWidgets('scan button in nav bar has QR code scanner icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // The scan button uses a qr_code_scanner icon
      expect(find.byIcon(Icons.qr_code_scanner), findsWidgets);
    });

    testWidgets('nav bar labels are Profile, Scan, and Search',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Check all labels exist
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Scan'), findsWidgets);
      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('tab switching preserves state (IndexedStack)',
        (WidgetTester tester) async {
      // Use a larger surface to avoid overflow when switching tabs
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Go to search, type something
      await tester.tap(find.byKey(const Key('nav_search')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('search_text_field')),
        'Test',
      );
      await tester.pump();

      // Switch to profile
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();

      // Switch back to search
      await tester.tap(find.byKey(const Key('nav_search')));
      await tester.pumpAndSettle();

      // The text should still be there
      final textField =
          tester.widget<TextField>(find.byKey(const Key('search_text_field')));
      expect(textField.controller!.text, 'Test');
    });
   group('Logout Dialog Tests', () {
    testWidgets('tapping logout icon shows confirmation dialog',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      // Go to profile
      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();

      // Tap logout icon in the header
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Check if dialog is shown
      expect(find.text('Logout'), findsWidgets);
      expect(find.text('Are you sure you want to log out of your NutriCode account?'), findsOneWidget);
    });
  });
 });
}
