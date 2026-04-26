import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:NutriCode/services/product_search_service.dart';

void main() {
  group('ProductSearchService', () {
    test('returns empty list for empty query', () async {
      final service = ProductSearchService();
      final results = await service.searchByName('');
      expect(results, isEmpty);
    });

    test('returns empty list for whitespace-only query', () async {
      final service = ProductSearchService();
      final results = await service.searchByName('   ');
      expect(results, isEmpty);
    });

    test('parses valid API response into ProductSearchResult list', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({
          'products': [
            {
              'code': '5449000000996',
              'product_name': 'Coca-Cola',
              'brands': 'The Coca-Cola Company',
              'image_front_small_url': 'https://example.com/coke.jpg',
            },
            {
              'code': '5449000131805',
              'product_name': 'Coca-Cola Zero',
              'brands': 'Coca-Cola',
              'image_front_small_url': 'https://example.com/coke_zero.jpg',
            },
          ],
        });
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('Coca-Cola');

      expect(results, hasLength(2));
      expect(results[0].name, 'Coca-Cola');
      expect(results[0].barcode, '5449000000996');
      expect(results[0].brand, 'The Coca-Cola Company');
      expect(results[0].imageUrl, 'https://example.com/coke.jpg');
      expect(results[1].name, 'Coca-Cola Zero');
    });

    test('filters out products without names', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({
          'products': [
            {
              'code': '5449000000996',
              'product_name': 'Coca-Cola',
              'brands': 'Coca-Cola',
            },
            {
              'code': '0000000000000',
              'product_name': '',
              'brands': 'Unknown',
            },
            {
              'code': '1111111111111',
              // missing product_name entirely
              'brands': 'Another Brand',
            },
          ],
        });
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('test');

      expect(results, hasLength(1));
      expect(results[0].name, 'Coca-Cola');
    });

    test('filters out products without barcode', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({
          'products': [
            {
              'code': '',
              'product_name': 'No Barcode Product',
            },
          ],
        });
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('no barcode');

      expect(results, isEmpty);
    });

    test('throws exception on non-200 HTTP status', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = ProductSearchService(client: mockClient);
      expect(
        () => service.searchByName('test'),
        throwsException,
      );
    });

    test('handles empty products array in response', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({'products': []});
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('nonexistent');

      expect(results, isEmpty);
    });

    test('handles missing products key in response', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({'count': 0});
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('nonexistent');

      expect(results, isEmpty);
    });

    test('sends correct query parameters to API', () async {
      Uri? capturedUri;
      final mockClient = http_testing.MockClient((request) async {
        capturedUri = request.url;
        final body = jsonEncode({'products': []});
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      await service.searchByName('Coca-Cola', pageSize: 10);

      expect(capturedUri, isNotNull);
      expect(capturedUri!.queryParameters['search_terms'], 'Coca-Cola');
      expect(capturedUri!.queryParameters['json'], '1');
      expect(capturedUri!.queryParameters['page_size'], '10');
      expect(capturedUri!.queryParameters['action'], 'process');
    });

    test('handles product with null brand gracefully', () async {
      final mockClient = http_testing.MockClient((request) async {
        final body = jsonEncode({
          'products': [
            {
              'code': '123456',
              'product_name': 'Generic Product',
              // No brands field
            },
          ],
        });
        return http.Response(body, 200);
      });

      final service = ProductSearchService(client: mockClient);
      final results = await service.searchByName('generic');

      expect(results, hasLength(1));
      expect(results[0].brand, isNull);
    });
  });
}
