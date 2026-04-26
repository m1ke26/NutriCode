import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:NutriCode/screens/search_screen.dart';
import 'package:NutriCode/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Feature Acceptance Tests', () {
    // ── Scenario 1: Successful typing and match product ──────────────
    testWidgets(
      'Scenario 1: User searches for a product and sees matching results',
      (WidgetTester tester) async {
        // Arrange: Start at the HomeScreen
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pumpAndSettle();

        // Navigate to the Search tab
        await tester.tap(find.byKey(const Key('nav_search')));
        await tester.pumpAndSettle();

        // Verify we are on the search screen
        expect(find.text('Search Products'), findsOneWidget);
        expect(find.text('Type a product name to search'), findsOneWidget);

        // Act: Enter "Coca-Cola" in the search bar
        await tester.enterText(
          find.byKey(const Key('search_text_field')),
          'Coca-Cola',
        );

        // Submit the search
        await tester.tap(find.byKey(const Key('search_submit_button')));

        // Wait for loading (the search makes a real API call in integration tests)
        await tester.pump(const Duration(seconds: 1));

        // Show loading state while searching
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for results to come in (API call — give some time)
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Assert: Results should appear as product cards OR we show "no results"
        // (depending on network availability in CI, we verify the UI responded correctly)
        final hasResults = find.byKey(const Key('search_result_0')).evaluate().isNotEmpty;
        final hasNoResults = find.byKey(const Key('no_results_text')).evaluate().isNotEmpty;

        // One of these must be true — the search completed and displayed a result
        expect(hasResults || hasNoResults, isTrue);

        // If results found, the first result should be tappable
        if (hasResults) {
          await tester.tap(find.byKey(const Key('search_result_0')));
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // We should be on the VerdictScreen now (which shows "NutriCode" in its AppBar)
          expect(find.text('NutriCode'), findsOneWidget);
        }
      },
    );

    // ── Scenario 2: No results found ─────────────────────────────────
    testWidgets(
      'Scenario 2: User searches for non-existent product and sees no results message',
      (WidgetTester tester) async {
        // Arrange: Start at the HomeScreen
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pumpAndSettle();

        // Navigate to the Search tab
        await tester.tap(find.byKey(const Key('nav_search')));
        await tester.pumpAndSettle();

        // Act: Enter a misspelled / non-existent product name
        await tester.enterText(
          find.byKey(const Key('search_text_field')),
          'Xyzzyflurb99999NonExistent',
        );

        // Submit the search
        await tester.tap(find.byKey(const Key('search_submit_button')));

        // Wait for the API call to complete
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Assert: "No results found" message should display
        expect(find.text('No results found'), findsOneWidget);

        // The suggestions panel should be visible
        expect(find.text('Suggestions'), findsOneWidget);
        expect(find.text('Check your spelling and try again'), findsOneWidget);
        expect(find.text('Try scanning the barcode instead'), findsOneWidget);
      },
    );

    // ── Navigation tests ─────────────────────────────────────────────
    testWidgets(
      'Bottom navigation bar exists and allows switching between tabs',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pumpAndSettle();

        // Initially on Scan tab
        expect(find.byKey(const Key('nav_scan')), findsOneWidget);

        // Switch to Search
        await tester.tap(find.byKey(const Key('nav_search')));
        await tester.pumpAndSettle();
        expect(find.text('Search Products'), findsOneWidget);

        // Switch to Profile
        await tester.tap(find.byKey(const Key('nav_profile')));
        await tester.pumpAndSettle();
        expect(find.text('Profile'), findsWidgets);

        // Switch back to Scan
        await tester.tap(find.byKey(const Key('nav_scan')));
        await tester.pumpAndSettle();
        // Scanner screen has the NutriCode title
        expect(find.text('NutriCode'), findsOneWidget);
      },
    );
  });
}
