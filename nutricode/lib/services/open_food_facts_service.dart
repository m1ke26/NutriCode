import 'dart:convert';
import 'package:http/http.dart' as http;
import 'translation_service.dart';

class Ingredient {
  final String text;
  final String englishText;
  final List<Ingredient> subIngredients;

  Ingredient({
    required this.text,
    this.englishText = '',
    this.subIngredients = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

class ProductResult {
  final bool found;
  final String? name;
  final String? brand;
  final String? ingredientsText;
  final List<String> allergens;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final String? nutriScore;
  final Map<String, String> nutrientLevels;

  ProductResult({
    required this.found,
    this.name,
    this.brand,
    this.ingredientsText,
    this.allergens = const [],
    this.imageUrl,
    this.ingredients = const [],
    this.nutriScore,
    this.nutrientLevels = const {},
  });
}

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  /// Tries to fetch a product by barcode. If not found and the barcode is
  /// 12 digits (UPC-A), automatically retries with a leading '0' (EAN-13).
  /// If the barcode is 14 digits starting with '0', also tries stripping it.
  static Future<ProductResult> fetchProduct(String barcode) async {
    // Clean the barcode: trim whitespace and remove any non-digit characters
    final cleaned = barcode.trim().replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.isEmpty) {
      return ProductResult(found: false);
    }

    // Try the original barcode first
    final result = await _fetchSingle(cleaned);
    if (result.found) return result;

    // UPC-A (12 digits) → try as EAN-13 (pad with leading 0)
    if (cleaned.length == 12) {
      final ean13 = '0$cleaned';
      final padded = await _fetchSingle(ean13);
      if (padded.found) return padded;
    }

    // EAN-13 starting with 0 → try as UPC-A (strip leading 0)
    if (cleaned.length == 13 && cleaned.startsWith('0')) {
      final upcA = cleaned.substring(1);
      final stripped = await _fetchSingle(upcA);
      if (stripped.found) return stripped;
    }

    // 14-digit GTIN → try last 13 digits as EAN-13
    if (cleaned.length == 14) {
      final ean13 = cleaned.substring(1);
      final trimmed = await _fetchSingle(ean13);
      if (trimmed.found) return trimmed;
    }

    return ProductResult(found: false);
  }

  /// Fetches a single barcode from the API (no retries/variations).
  static Future<ProductResult> _fetchSingle(String barcode) async {
    final url = Uri.parse('$_baseUrl/$barcode.json?lc=en');
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

    // Parse individual ingredients recursively to maintain hierarchy
    List<Ingredient> extractIngredients(List<dynamic> list) {
      List<Ingredient> result = [];
      for (var item in list) {
        if (item is Map) {
          final idRaw = item['id']?.toString() ?? '';
          final textRaw = (item['text'] ?? '').toString();
          
          String text = '';
          bool isEnglish = false;
          if (idRaw.startsWith('en:')) {
            text = idRaw.substring(3);
            isEnglish = true;
          } else if (idRaw.contains(':')) {
            // Strip any native prefix like "pt:" or "fr:"
            text = idRaw.substring(idRaw.indexOf(':') + 1);
          } else {
            text = textRaw;
          }
          
          // Replace anything that is not a letter/number with a space (removes '-', '_', etc.)
          text = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
          // Clean up multiple spaces
          text = text.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
          
          if (text.length >= 2 && text.contains(RegExp(r'\p{L}', unicode: true))) {
            // Capitalize the first letter
            text = text[0].toUpperCase() + text.substring(1);
            
            final subs = item['ingredients'] is List 
                ? extractIngredients(item['ingredients']) 
                : <Ingredient>[];
            result.add(Ingredient(
              text: text, 
              englishText: isEnglish ? text.toLowerCase() : '',
              subIngredients: subs
            ));
          } else if (item['ingredients'] is List) {
            // Some items might not have text but have sub-ingredients (unlikely but safe)
            result.addAll(extractIngredients(item['ingredients']));
          }
        }
      }
      return result;
    }

    final ingredientsRaw = product['ingredients'] as List<dynamic>? ?? [];
    List<Ingredient> ingredients = extractIngredients(ingredientsRaw);

    if (ingredients.isEmpty) {
      final ingredientsText = product['ingredients_text'] as String? ?? '';
      if (ingredientsText.isNotEmpty) {
        // Fallback: splitting text doesn't provide hierarchy, but we wrap in Ingredient objects
        ingredients = ingredientsText
            .split(RegExp(r'[,()\[\]]'))
            .map((s) {
              String cleaned = s.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
                                .replaceAll(RegExp(r'\s+'), ' ')
                                .trim()
                                .toLowerCase();
              return cleaned;
            })
            .where((t) => t.length >= 2 && t.contains(RegExp(r'\p{L}', unicode: true)))
            .map((t) {
              final capitalized = t[0].toUpperCase() + t.substring(1);
              return Ingredient(text: capitalized);
            })
            .toList();
      }
    }
    
    // De-duplicate top-level ingredients while preserving order
    final seen = <String>{};
    ingredients = ingredients.where((i) => seen.add(i.text)).toList();

    // Translate ingredients
    List<String> allTexts = [];
    void collectTexts(List<Ingredient> ings) {
      for (var i in ings) {
        if (i.englishText.isEmpty) {
          allTexts.add(i.text);
        }
        collectTexts(i.subIngredients);
      }
    }
    collectTexts(ingredients);

    final uniqueTexts = allTexts.toSet().toList();
    if (uniqueTexts.isNotEmpty) {
      final translatedTexts = await TranslationService.translateToEnglishBulk(uniqueTexts);
      final translationMap = Map.fromIterables(uniqueTexts, translatedTexts);

      List<Ingredient> applyTranslations(List<Ingredient> ings) {
        return ings.map((i) {
          // If englishText is already set, keep it, otherwise translate
          return Ingredient(
            text: i.text,
            englishText: i.englishText.isNotEmpty ? i.englishText : (translationMap[i.text] ?? ''),
            subIngredients: applyTranslations(i.subIngredients),
          );
        }).toList();
      }

      ingredients = applyTranslations(ingredients);
    }

    // Prefer clean product image, fallback chain
    final imageUrl = product['image_front_url'] as String?
        ?? product['image_url'] as String?;

    final nutriScoreRaw = product['nutriscore_grade'] as String?;
    final nutriScore = nutriScoreRaw?.toLowerCase();

    final levelsRaw = product['nutrient_levels'];
    final nutrientLevels = <String, String>{};
    if (levelsRaw is Map) {
      for (final key in levelsRaw.keys) {
        nutrientLevels[key.toString()] = levelsRaw[key].toString();
      }
    }

    return ProductResult(
      found: true,
      name: product['product_name'] as String?,
      brand: product['brands'] as String?,
      ingredientsText: product['ingredients_text'] as String?,
      allergens: allergens,
      imageUrl: imageUrl,
      ingredients: ingredients,
      nutriScore: nutriScore,
      nutrientLevels: nutrientLevels,
    );
  }
}
