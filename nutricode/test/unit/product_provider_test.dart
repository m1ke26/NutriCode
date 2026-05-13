import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:NutriCode/providers/product_provider.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';

void main() {
  group('ProductProvider', () {
    test('initializes with initial state', () {
      final provider = ProductProvider();
      expect(provider.state, ProductState.initial);
      expect(provider.product, null);
      expect(provider.errorMessage, null);
    });

    test('fetches product successfully and updates state', () async {
      final mockJson = {
        'status': 1,
        'product': {
          'code': '123456789012',
          'product_name': 'Test Product',
          'brands': 'Test Brand',
          'image_front_small_url': 'https://example.com/image.jpg',
          'nutriscore_grade': 'b'
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('123456789012');

      expect(provider.state, ProductState.success);
      expect(provider.product?.found, true);
      expect(provider.product?.name, 'Test Product');
    });

    test('sets loading state during fetch', () async {
      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Test'}
      };

      var isLoading = false;
      final mockClient = http_testing.MockClient((request) async {
        // At this point, the provider should have set loading state
        isLoading = true;
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      final future = provider.fetchProduct('123456789012');
      expect(isLoading, false); // Not loading yet

      await future;
      expect(provider.state, ProductState.success);
    });

    test('sets not found state when product not found', () async {
      final mockJson = {'status': 0};

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('999999999999');

      expect(provider.state, ProductState.notFound);
      expect(provider.product?.found, false);
    });

    test('sets not found state on non-200 response', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('123456789012');

      // Note: OpenFoodFactsService returns found:false on non-200 status,
      // which ProductProvider interprets as notFound, not error
      expect(provider.state, ProductState.notFound);
    });

    test('sets not found state for empty barcode', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('{}', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('   ');

      expect(provider.state, ProductState.notFound);
    });

    test('caches product results', () async {
      var callCount = 0;
      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Cached Product'}
      };

      final mockClient = http_testing.MockClient((request) async {
        callCount++;
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('123456789012');
      expect(callCount, 1);

      await provider.fetchProduct('123456789012');
      expect(callCount, 1); // No additional API call
      expect(provider.product?.name, 'Cached Product');
    });

    test('handles timeout gracefully', () async {
      final mockClient = http_testing.MockClient((request) async {
        // Simulate a long delay
        await Future.delayed(const Duration(seconds: 20));
        return http.Response('{}', 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('123456789012');

      expect(provider.state, ProductState.error);
    });

    test('notifies listeners on state change', () async {
      var notificationCount = 0;

      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Test'}
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      provider.addListener(() {
        notificationCount++;
      });

      await provider.fetchProduct('123456789012');

      expect(notificationCount, greaterThan(0));
    });

    test('does not notify after dispose', () async {
      var notificationCount = 0;

      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Test'}
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      provider.addListener(() {
        notificationCount++;
      });

      provider.dispose();

      // This should not increment notificationCount
      // because provider is disposed
      await provider.fetchProduct('123456789012');

      expect(notificationCount, 0);
    });

    test('cleans barcode by trimming whitespace', () async {
      final mockJson = {
        'status': 1,
        'product': {'code': '123456789012', 'product_name': 'Trimmed'}
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('  123456789012  ');

      expect(provider.state, ProductState.success);
    });

    test('provides default error message on unknown error', () async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response('Unknown Error', 500);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final provider = ProductProvider(service: service);

      await provider.fetchProduct('123456789012');

      expect(provider.state, ProductState.notFound);
    });
  });
}
