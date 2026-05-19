import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

import 'package:NutriCode/screens/search_screen.dart';
import 'package:NutriCode/services/product_search_service.dart';
import 'integration_mock_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Feature Acceptance Tests (100% Reliable)', () {
    
    testWidgets(
      'Scenario 1: User searches for a product and sees matching results',
      (WidgetTester tester) async {
        // Arrange: Mock search results
        final mockResultsJson = {
          'products': [
            {
              'code': '123456',
              'product_name': 'Coca-Cola Zero',
              'brands': 'The Coca-Cola Company',
              'image_front_small_url': ''
            }
          ]
        };

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(jsonEncode(mockResultsJson), 200);
        });
        
        final mockService = ProductSearchService(client: mockClient);

        // Load the SearchScreen directly with mock service to ensure isolation
        await tester.pumpWidget(createTestableWidget(
          Scaffold(body: SearchScreen(service: mockService)),
        ));
        await tester.pumpAndSettle();

        // Act: Enter "Coca-Cola"
        await tester.enterText(find.byKey(const Key('search_text_field')), 'Coca-Cola');
        await tester.pump(); // Ensure text change is processed
        await tester.tap(find.byKey(const Key('search_submit_button')));

        // Wait for results
        await tester.pump(); // Start loading
        await tester.pump(const Duration(milliseconds: 500)); // Wait for API
        await tester.pumpAndSettle(); // Wait for animations

        // Assert: Result card appears
        expect(find.text('Coca-Cola Zero'), findsOneWidget);
        expect(find.byKey(const Key('search_result_0')), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 2: User searches for non-existent product and sees no results',
      (WidgetTester tester) async {
        // Arrange: Mock empty results
        final mockEmptyJson = {'products': []};

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(jsonEncode(mockEmptyJson), 200);
        });
        
        final mockService = ProductSearchService(client: mockClient);

        await tester.pumpWidget(createTestableWidget(
            Scaffold(body: SearchScreen(service: mockService)),
        ));
        await tester.pumpAndSettle();

        // Act: Enter random text
        await tester.enterText(find.byKey(const Key('search_text_field')), 'NonExistentProduct123');
        await tester.pump(); // Ensure text change is processed
        await tester.tap(find.byKey(const Key('search_submit_button')));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Assert: No results found message
        expect(find.text('No results found'), findsOneWidget);
        expect(find.text('Suggestions'), findsOneWidget);
      },
    );
  });
}
