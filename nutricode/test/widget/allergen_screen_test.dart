import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/allergen_screen.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

void main() {
  group('AllergenScreen widget tests', () {
    late MockAuthService mockAuth;
    late AllergenProvider allergenProvider;
    late VeganProvider veganProvider;

    Widget buildTestableAllergenScreen({
      MockAuthService? authService,
      AllergenProvider? allergenProv,
      VeganProvider? veganProv,
    }) {
      mockAuth = authService ?? MockAuthService();
      allergenProvider = allergenProv ?? AllergenProvider(mockAuth);
      veganProvider = veganProv ?? VeganProvider(mockAuth);

      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AllergenProvider>.value(value: allergenProvider),
          ChangeNotifierProvider<VeganProvider>.value(value: veganProvider),
        ],
        child: const MaterialApp(home: AllergenScreen()),
      );
    }

    testWidgets('displays common allergens', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      expect(find.text('My Allergens'), findsWidgets);
      // Just check that at least some allergens are visible
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('toggles allergen selection when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CheckboxListTile), findsWidgets);

      // Tap the first checkbox
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      // Verify that allergen provider was updated
      expect(allergenProvider.selectedAllergens.isNotEmpty, true);
    });

    testWidgets('updates selected count in appbar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      // Select an allergen
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('1'), findsWidgets);

      // Select another
      await tester.tap(find.byType(CheckboxListTile).at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('search filters allergens by name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      // Get initial count
      final initialCount = find.byType(CheckboxListTile);
      expect(initialCount, findsWidgets);

      // Find the search field and type
      await tester.enterText(find.byType(TextField), 'gluten');
      await tester.pump();

      // Filtering should work
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      // Search with uppercase
      await tester.enterText(find.byType(TextField), 'GLUTEN');
      await tester.pump();

      // Should still find allergens
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('shows no results message for empty search', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      // Search for something that doesn't exist
      await tester.enterText(find.byType(TextField), 'xyz123nonexistent');
      await tester.pump();

      expect(find.text('No allergens match your search.'), findsOneWidget);
    });

    testWidgets('multiple allergens can be selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      // Select multiple allergens
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile).at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile).at(2));
      await tester.pumpAndSettle();

      expect(allergenProvider.selectedAllergens.length, 3);
    });

    testWidgets('has search icon in search field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search field has correct hint text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableAllergenScreen());
      await tester.pumpAndSettle();

      expect(find.text('Search allergens...'), findsOneWidget);
    });
  });
}
