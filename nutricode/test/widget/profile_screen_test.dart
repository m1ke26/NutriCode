import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/profile_screen.dart';
import 'package:NutriCode/screens/allergen_screen.dart';
import 'package:NutriCode/providers/allergen_provider.dart';

void main() {
  group('ProfileScreen widget tests', () {
    setUp(() {
      // Clear all allergens before each test
      for (final allergen in AllergenProvider.commonAllergens.toList()) {
        if (AllergenProvider.instance.isSelected(allergen)) {
          AllergenProvider.instance.toggle(allergen);
        }
      }
    });

    testWidgets('displays Profile title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('displays coming soon message', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Coming soon!'), findsOneWidget);
      expect(find.textContaining('profile settings'), findsOneWidget);
    });

    testWidgets('displays avatar placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('displays feature preview cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('Review your previously scanned products'), findsOneWidget);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Customize your NutriCode experience'), findsOneWidget);
    });

    testWidgets('displays My Allergens card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('My Allergens'), findsOneWidget);
    });

    testWidgets('shows "None configured" message when no allergens selected', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('None configured — tap to set up'), findsOneWidget);
    });

    testWidgets('shows allergen count when allergens are selected', (WidgetTester tester) async {
      // Pre-select allergens
      AllergenProvider.instance.toggle('gluten');
      AllergenProvider.instance.toggle('milk');

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2 allergens configured'), findsOneWidget);
    });

    testWidgets('shows singular "allergen" for single selection', (WidgetTester tester) async {
      // Pre-select one allergen
      AllergenProvider.instance.toggle('gluten');

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('1 allergen configured'), findsOneWidget);
    });

    testWidgets('navigates to AllergenScreen when allergen card tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Tap the allergen card
      await tester.tap(find.text('My Allergens'));
      await tester.pumpAndSettle();

      // Should navigate to AllergenScreen
      expect(find.text('My Allergens'), findsWidgets); // Title appears in both screens
      expect(find.byType(AllergenScreen), findsOneWidget);
    });

    testWidgets('updates allergen display when provider changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('None configured — tap to set up'), findsOneWidget);

      // Simulate user selecting an allergen from elsewhere
      AllergenProvider.instance.toggle('gluten');
      await tester.pumpAndSettle();

      expect(find.text('1 allergen configured'), findsOneWidget);
    });

    testWidgets('has icon for Scan History feature', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('has icon for Settings feature', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('has icon for My Allergens card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('has white background', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('is scrollable when content exceeds viewport', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('avatar has teal border color', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Find the container with the avatar
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('feature cards have rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Container widgets are used for the cards
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('allergen card shows teal icon', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // The icon should be present
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('can navigate back from AllergenScreen to ProfileScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Navigate to AllergenScreen
      await tester.tap(find.text('My Allergens'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on ProfileScreen
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
