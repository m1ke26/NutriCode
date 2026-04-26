import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:NutriCode/screens/product_screen.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';
import 'package:NutriCode/providers/product_provider.dart';
import 'package:provider/provider.dart';

// We create a simple mock provider to inject our test data
class MockProductProvider extends ProductProvider {
  final ProductResult mockResult;
  MockProductProvider(this.mockResult);

  @override
  ProductState get state => ProductState.success;
  @override
  ProductResult? get product => mockResult;
  @override
  Future<void> fetchProduct(String barcode) async {} // Do nothing
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ingredient Details Acceptance Tests', () {
    testWidgets('Tapping ingredient info icon shows detailed description sheet', (WidgetTester tester) async {
      // 1. Arrange: Create a mock product with known ingredients
      final mockResult = ProductResult(
        found: true,
        name: 'Test Product',
        brand: 'Test Brand',
        imageUrl: '',
        ingredientsText: 'Water, Sugar, Aspartame',
        nutriScore: 'c',
        allergens: [],
        ingredients: [
          Ingredient(text: 'Water', englishText: 'Water', subIngredients: []),
          Ingredient(text: 'Sugar', englishText: 'Sugar', subIngredients: []),
          Ingredient(text: 'Aspartame', englishText: 'Aspartame', subIngredients: []),
        ],
        nutrientLevels: {},
      );

      final mockProvider = MockProductProvider(mockResult);

      // Pump the ProductScreen with the mock product
      await tester.pumpWidget(MaterialApp(
        home: ProductScreen(
          barcode: 'mock_barcode',
          provider: mockProvider,
        ),
      ));
      
      // Wait for animations and rendering
      await tester.pumpAndSettle();

      // 2. Act: Find the Aspartame ingredient and tap its info icon
      // First, ensure the text "Aspartame" is actually on screen
      expect(find.text('Aspartame'), findsOneWidget);

      // Find all info icons and tap the one that is near the "Aspartame" text.
      // Since Aspartame is classified as "Bad", it will be sorted to the top of the list.
      final infoButton = find.byIcon(Icons.info_outline).first;
      expect(infoButton, findsOneWidget);

      // Tap the info icon
      await tester.tap(infoButton);
      await tester.pumpAndSettle(); // Wait for bottom sheet to animate up

      // 3. Assert: Verify the bottom sheet displays the correct specific description
      // In the bottom sheet, the name is shown again
      expect(find.text('Aspartame'), findsWidgets);
      expect(find.textContaining('artificial sweetener'), findsOneWidget);
      expect(find.text('Avoid'), findsWidgets);

      // Close the bottom sheet
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle(); // Wait for animation

      // Ensure bottom sheet is closed
      expect(find.text('Got it'), findsNothing);
    });
    testWidgets('Tapping unknown ingredient info icon shows search button (Acceptance)', (WidgetTester tester) async {
      final mockResult = ProductResult(
        found: true,
        name: 'Mysterious Product',
        brand: 'Unknown Brand',
        imageUrl: '',
        ingredientsText: 'MysteryChemicalX',
        nutriScore: 'd',
        allergens: [],
        ingredients: [
          Ingredient(text: 'MysteryChemicalX', englishText: 'MysteryChemicalX', subIngredients: []),
        ],
        nutrientLevels: {},
      );

      final mockProvider = MockProductProvider(mockResult);

      await tester.pumpWidget(MaterialApp(
        home: ProductScreen(
          barcode: 'mock_barcode_2',
          provider: mockProvider,
        ),
      ));
      
      await tester.pumpAndSettle();

      // Find and tap info icon for the unknown ingredient
      expect(find.text('MysteryChemicalX'), findsOneWidget);
      final infoButton = find.byIcon(Icons.info_outline).first;
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Verify fallback description and Search button
      expect(find.textContaining('generally considered safe'), findsOneWidget); // Default for "Good" if not classified as bad/mod
      expect(find.text('Search online for more info'), findsOneWidget);
      
      // Tap Search button to ensure it doesn't crash the app
      await tester.tap(find.text('Search online for more info'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });
  });
}
