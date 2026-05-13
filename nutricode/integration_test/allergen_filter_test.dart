import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/screens/verdict_screen.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';
import 'integration_mock_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('US05 — Allergen Filter (100% Reliable)', () {
    late MockAuthService mockAuth;
    late AllergenProvider allergenProvider;

    setUp(() {
      mockAuth = MockAuthService();
      allergenProvider = AllergenProvider(mockAuth);
    });

    testWidgets(
      'Scenario 1: red alert banner appears when product contains user allergen',
      (WidgetTester tester) async {
        // Arrange: Mock product containing gluten
        final mockJson = {
          'status': 1,
          'product': {
            'product_name': 'Wheat Bread',
            'brands': 'Test Bakery',
            'ingredients': [],
            'allergens_tags': ['en:gluten'],
            'nutriscore_grade': 'c',
            'nutrient_levels': {}
          }
        };

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(jsonEncode(mockJson), 200);
        });
        
        final mockService = OpenFoodFactsService(client: mockClient);

        // Given: user has configured Gluten as a personal allergen
        allergenProvider.toggle('gluten');

        // When: the verdict screen loads
        await tester.pumpWidget(
          createTestableWidget(
            VerdictScreen(
              barcode: '123',
              service: mockService,
            ),
            authService: mockAuth,
            allergenProvider: allergenProvider,
          ),
        );
        
        // Wait for loading to finish and animations to complete
        await tester.pump(); // Start loading
        await tester.pump(const Duration(milliseconds: 500)); // Wait for API
        await tester.pumpAndSettle(); // Wait for animations

        // Then: a red alert banner shows the allergen name
        expect(find.text('Allergens Detected'), findsOneWidget);
        expect(find.text('Gluten'), findsOneWidget);
        expect(find.text('Find Alternatives'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 2: yellow warning shown when product has no allergen data',
      (WidgetTester tester) async {
        // Arrange: Mock product with NO allergen data
        final mockJson = {
          'status': 1,
          'product': {
            'product_name': 'Mystery Snack',
            'brands': 'Unknown',
            'ingredients': [],
            'allergens_tags': [], // Empty
            'nutriscore_grade': 'b',
            'nutrient_levels': {}
          }
        };

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(jsonEncode(mockJson), 200);
        });
        
        final mockService = OpenFoodFactsService(client: mockClient);

        // Given: user has some allergen configured (so the banner logic triggers)
        allergenProvider.toggle('nuts');

        // When: the verdict screen loads
        await tester.pumpWidget(
          createTestableWidget(
            VerdictScreen(
              barcode: '456',
              service: mockService,
            ),
            authService: mockAuth,
            allergenProvider: allergenProvider,
          ),
        );
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Then: a yellow warning about missing allergen data is shown
        expect(find.text('Allergen data unavailable'), findsOneWidget);
        expect(find.text('Check the physical label'), findsOneWidget);
        
        // And: no red banner
        expect(find.text('Allergens Detected'), findsNothing);
      },
    );
  });
}
