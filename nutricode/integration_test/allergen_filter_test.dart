import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/screens/verdict_screen.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('US05 — Allergen Filter (100% Reliable)', () {
    
    setUp(() {
      // Clear allergens before each test
      for (final a in AllergenProvider.instance.selectedAllergens.toList()) {
        AllergenProvider.instance.toggle(a);
      }
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
        AllergenProvider.instance.toggle('gluten');

        // When: the verdict screen loads
        await tester.pumpWidget(
          MaterialApp(
            home: VerdictScreen(
              barcode: '123',
              service: mockService,
            ),
          ),
        );
        
        // Wait for loading to finish and animations to complete
        await tester.pump(); // Start loading
        await tester.pump(const Duration(milliseconds: 500)); // Wait for API
        await tester.pumpAndSettle(); // Wait for animations

        // Then: a red alert banner shows the allergen name
        expect(find.textContaining('GLUTEN'), findsOneWidget);
        expect(find.text('See Alternatives'), findsOneWidget);
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
        AllergenProvider.instance.toggle('nuts');

        // When: the verdict screen loads
        await tester.pumpWidget(
          MaterialApp(
            home: VerdictScreen(
              barcode: '456',
              service: mockService,
            ),
          ),
        );
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Then: a yellow warning about missing allergen data is shown
        expect(
          find.text('⚠️ Allergen data unavailable — check the physical label'),
          findsOneWidget,
        );
        
        // And: no red banner
        expect(find.textContaining('matches your allergen profile'), findsNothing);
      },
    );
  });
}
