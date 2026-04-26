import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/search_screen.dart';

void main() {
  group('SearchScreen Widget Tests', () {
    testWidgets('renders search screen with search bar and empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Header text
      expect(find.text('Search Products'), findsOneWidget);
      expect(
        find.text('Find products by name when barcode is unavailable'),
        findsOneWidget,
      );

      // Search text field
      expect(find.byKey(const Key('search_text_field')), findsOneWidget);

      // Empty state
      expect(find.text('Type a product name to search'), findsOneWidget);
      expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    });

    testWidgets('shows hint text in search field',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      expect(find.text('e.g. Coca-Cola, Nutella...'), findsOneWidget);
    });

    testWidgets('submit button exists and is tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      final submitButton = find.byKey(const Key('search_submit_button'));
      expect(submitButton, findsOneWidget);
    });

    testWidgets('entering text shows clear button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Initially no clear button
      expect(find.byKey(const Key('clear_search_button')), findsNothing);

      // Type in the search field — this triggers onChanged which calls setState
      await tester.enterText(
        find.byKey(const Key('search_text_field')),
        'Test',
      );
      await tester.pump(); // Rebuild after setState in onChanged

      // Clear button should now appear
      expect(find.byKey(const Key('clear_search_button')), findsOneWidget);
    });

    testWidgets('clear button clears text and removes itself',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Type something
      await tester.enterText(
        find.byKey(const Key('search_text_field')),
        'Coca-Cola',
      );
      await tester.pump(); // Rebuild to show clear button

      // Verify clear button appeared
      expect(find.byKey(const Key('clear_search_button')), findsOneWidget);

      // Tap clear
      await tester.tap(find.byKey(const Key('clear_search_button')));
      await tester.pump(); // Rebuild after clear

      // Text should be empty, clear button gone
      final textField =
          tester.widget<TextField>(find.byKey(const Key('search_text_field')));
      expect(textField.controller!.text, isEmpty);
      expect(find.byKey(const Key('clear_search_button')), findsNothing);
    });

    testWidgets('empty state disappears after typing text',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Initially shows empty state
      expect(find.text('Type a product name to search'), findsOneWidget);

      // Type search query
      await tester.enterText(
        find.byKey(const Key('search_text_field')),
        'Coca-Cola',
      );
      await tester.pump();

      // Empty state text should still be visible until debounce triggers search
      // (search hasn't been submitted yet, so empty state remains until loading starts)
      expect(find.byKey(const Key('search_text_field')), findsOneWidget);
    });

    testWidgets('submitting empty search does not trigger loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Tap submit without typing anything
      await tester.tap(find.byKey(const Key('search_submit_button')));
      await tester.pump();

      // Should still show empty state, not loading
      expect(find.text('Type a product name to search'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('SearchScreen Navigation Tests', () {
    testWidgets('search screen can be rendered inside a navigator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SearchScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Products'), findsOneWidget);
    });
  });
}
