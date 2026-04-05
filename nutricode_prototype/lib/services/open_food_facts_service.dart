import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductResult {
  final bool found;
  final String? name;
  final String? brand;
  final String? ingredientsText;
  final List<String> allergens;
  final String? imageUrl;
  final List<String> ingredients;

  ProductResult({
    required this.found,
    this.name,
    this.brand,
    this.ingredientsText,
    this.allergens = const [],
    this.imageUrl,
    this.ingredients = const [],
  });
}

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  static Future<ProductResult> fetchProduct(String barcode) async {
    final url = Uri.parse('$_baseUrl/$barcode');
    final response = await http.get(
      url,
      headers: {'User-Agent': 'NutriCode/1.0 (FEUP ES project)'},
    );

    if (response.statusCode != 200) {
      return ProductResult(found: false);
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 1) {
      return ProductResult(found: false);
    }

    final product = data['product'];

    final allergensRaw = product['allergens_tags'] as List<dynamic>? ?? [];
    final allergens = allergensRaw
        .map((a) => a.toString().replaceFirst('en:', ''))
        .toList();

    // Parse individual ingredients
    final ingredientsRaw = product['ingredients'] as List<dynamic>? ?? [];
    final ingredients = ingredientsRaw
        .map((i) => (i['text'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toList();

    // Prefer clean product image, fallback chain
    final imageUrl = product['image_front_url'] as String?
        ?? product['image_url'] as String?;

    return ProductResult(
      found: true,
      name: product['product_name'] as String?,
      brand: product['brands'] as String?,
      ingredientsText: product['ingredients_text'] as String?,
      allergens: allergens,
      imageUrl: imageUrl,
      ingredients: ingredients,
    );
  }
}
