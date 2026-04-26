import 'dart:convert';
import 'package:http/http.dart' as http;

/// A single search result item returned by the Open Food Facts search API.
class ProductSearchResult {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;

  ProductSearchResult({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
  });
}

/// Service that searches Open Food Facts by product name.
class ProductSearchService {
  static const _searchUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  /// Optional HTTP client for dependency injection (testing).
  final http.Client _client;

  ProductSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches products by [query]. Returns up to [pageSize] results.
  /// Results are filtered to only include items that have a product name.
  Future<List<ProductSearchResult>> searchByName(
    String query, {
    int pageSize = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final url = Uri.parse(_searchUrl).replace(queryParameters: {
      'search_terms': trimmed,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': pageSize.toString(),
      'fields': 'code,product_name,brands,image_front_small_url',
    });

    final response = await _client.get(
      url,
      headers: {'User-Agent': 'NutriCode/1.0 (FEUP ES project)'},
    );

    if (response.statusCode != 200) {
      throw Exception('Search failed: HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final products = data['products'] as List<dynamic>? ?? [];

    return products
        .map((p) {
          final code = p['code']?.toString() ?? '';
          final name = p['product_name']?.toString() ?? '';
          if (code.isEmpty || name.isEmpty) return null;

          return ProductSearchResult(
            barcode: code,
            name: name,
            brand: p['brands']?.toString(),
            imageUrl: p['image_front_small_url']?.toString(),
          );
        })
        .whereType<ProductSearchResult>()
        .toList();
  }
}
