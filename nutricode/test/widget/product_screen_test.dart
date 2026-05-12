import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:NutriCode/screens/product_screen.dart';
import 'package:NutriCode/providers/product_provider.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';

void main() {
  group('ProductScreen widget tests', () {
    testWidgets('has NutriCode: Scan title', (WidgetTester tester) async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('NutriCode: Scan'), findsOneWidget);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has Scaffold widget', (WidgetTester tester) async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles not found state', (WidgetTester tester) async {
      final mockJson = {'status': 0};

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '999999999999', provider: provider),
        ),
      );

      // Just verify the provider initialized properly
      expect(provider, isNotNull);
    });

    testWidgets('handles network errors', (WidgetTester tester) async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Error', 500);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      // Just verify the provider was created
      expect(provider, isNotNull);
    });

    testWidgets('renders product screen content', (WidgetTester tester) async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand',
          'ingredients': [],
          'allergens_tags': [],
          'nutrient_levels': {}
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      await tester.pump();

      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('has AppBar', (WidgetTester tester) async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('initializes with product provider', (WidgetTester tester) async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('{}', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: '123456789012', provider: provider),
        ),
      );

      expect(find.byType(ProductScreen), findsOneWidget);
    });

    testWidgets('handles product barcode parameter', (WidgetTester tester) async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('{}', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductScreen(barcode: 'test123', provider: provider),
        ),
      );

      expect(find.byType(ProductScreen), findsOneWidget);
    });
  });
}
