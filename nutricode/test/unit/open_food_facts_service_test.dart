import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import '../../lib/services/open_food_facts_service.dart';

void main() {
  group('OpenFoodFactsService', () {
    test('fetches product successfully with valid barcode', () async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand',
          'image_front_small_url': 'https://example.com/image.jpg',
          'ingredients_text_en': 'Water, Sugar',
          'allergens_tags': ['en:gluten', 'en:milk'],
          'nutriscore_grade': 'b',
          'nutrient_levels': {'fat': 'high', 'sugar': 'moderate'}
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.found, true);
      expect(result.name, 'Test Product');
      expect(result.brand, 'Test Brand');
      expect(result.allergens, contains('gluten'));
      expect(result.allergens, contains('milk'));
      expect(result.nutriScore, 'b');
    });

    test('returns not found for invalid product', () async {
      final mockJson = {'status': 0};

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('999999999999');

      expect(result.found, false);
    });

    test('cleans barcode by trimming whitespace', () async {
      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Clean Barcode'}
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('  123456789012  ');

      expect(result.found, true);
      expect(result.name, 'Clean Barcode');
    });

    test('removes non-digit characters from barcode', () async {
      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Cleaned'}
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123-456-789-012');

      expect(result.found, true);
    });

    test('returns not found for empty barcode', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('{}', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('   ');

      expect(result.found, false);
    });

    test('converts UPC-A (12 digits) to EAN-13 (padded with 0)', () async {
      final mockJson = {
        'status': 0,
      };
      final mockEan13Json = {
        'status': 1,
        'product': {
          'code': '0123456789012',
          'product_name': 'EAN-13 Product'
        }
      };

      var callCount = 0;
      final mockClient = http_testing.MockClient((request) async {
        callCount++;
        // Second call should be for the padded EAN-13
        if (callCount == 2) {
          return http.Response(jsonEncode(mockEan13Json), 200);
        }
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.found, true);
      expect(result.name, 'EAN-13 Product');
    });

    test('parses allergens from allergens_tags correctly', () async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Allergen Test',
          'allergens_tags': ['en:gluten', 'en:peanuts', 'en:shellfish']
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.allergens.length, 3);
      expect(result.allergens, contains('gluten'));
      expect(result.allergens, contains('peanuts'));
    });

    test('extracts NutriScore correctly', () async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'NutriScore Test',
          'nutriscore_grade': 'c'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.nutriScore, 'c');
    });

    test('handles API errors gracefully', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.found, false);
    });

    test('handles malformed JSON response', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Invalid JSON', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final result = await service.fetchProduct('123456789012');

      expect(result.found, false);
    });
  });
}
