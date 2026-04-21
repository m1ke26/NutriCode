import '../services/open_food_facts_service.dart';

/// Shared ingredient classification logic used by both VerdictScreen and ProductScreen.

// Harmful ingredients (worst — red)
const badIngredients = {
  // Sweeteners & Syrups
  'high fructose corn syrup', 'aspartame', 'acesulfame k', 'acesulfame',
  'saccharin', 'sucralose', 'neotame', 'cyclamate',
  // Preservatives & Additives
  'sodium nitrite', 'sodium nitrate', 'monosodium glutamate', 'msg',
  'butylated hydroxyanisole', 'bha', 'butylated hydroxytoluene', 'bht',
  'sodium benzoate', 'potassium benzoate', 'sodium metabisulfite',
  'potassium bromate', 'azodicarbonamide', 'propyl paraben',
  // Dyes & Colors
  'tartrazine', 'red 40', 'yellow 5', 'yellow 6', 'blue 1', 'blue 2', 'green 3',
  'red dye', 'erythrosine', 'brilliant blue', 'allura red', 'sunset yellow',
  'carmine', 'titanium dioxide', 'caramel colour', 'caramel color',
  // Fats & Oils
  'trans fat', 'hydrogenated', 'partially hydrogenated', 'interesterified',
  // Artificial & Synthetic
  'artificial sweetener', 'artificial flavour', 'artificial flavor',
  'artificial colour', 'artificial color',
  // Emulsifiers & Thickeners
  'propylene glycol', 'polysorbate 80', 'carrageenan',
  // Phosphates & Acids
  'sodium phosphate', 'phosphoric acid',
  // E-numbers (Harmful)
  'e102', 'e110', 'e129', 'e133', 'e150d', 'e171', 'e211', 'e249', 'e250',
  'e320', 'e321', 'e338', 'e407', 'e452', 'e621', 'e950', 'e951', 'e952', 'e954', 'e955'
};

// Moderate concern ingredients (yellow)
const moderateIngredients = {
  // Sugars & Sweeteners
  'sugar', 'glucose syrup', 'fructose', 'sucrose', 'dextrose', 'corn syrup',
  'agave nectar', 'honey', 'maple syrup', 'rice syrup', 'coconut sugar', 'maltitol', 'erythritol', 'xylitol',
  // Salts
  'salt', 'sodium', 'sea salt',
  // Oils & Fats
  'palm oil', 'sunflower oil', 'rapeseed oil', 'vegetable oil', 'canola oil', 'soybean oil',
  // Starches & Maltodextrins
  'maltodextrin', 'modified starch', 'corn starch', 'potato starch', 'tapioca starch',
  // Acids
  'citric acid', 'malic acid', 'ascorbic acid', 'lactic acid',
  // Flavorings
  'natural flavour', 'natural flavor', 'flavouring', 'flavoring', 'yeast extract',
  // Gums & Thickeners
  'xanthan gum', 'guar gum', 'locust bean gum', 'pectin', 'gelatin', 'agar',
  // Emulsifiers & Others
  'emulsifier', 'stabiliser', 'stabilizer', 'thickener', 'acidity regulator',
  'anti-caking agent', 'preservative', 'lecithin', 'mono- and diglycerides', 'monoglycerides', 'diglycerides',
  // E-numbers (Moderate)
  'e300', 'e322', 'e330', 'e412', 'e415', 'e440', 'e471'
};

/// Classification levels, ordered from best to worst.
enum IngredientLevel { good, moderate, bad }

/// Classify a single ingredient string.
IngredientLevel classifyIngredient(String ingredient, List<String> allergens) {
  final lower = ingredient.toLowerCase().trim();

  // Allergen checks for color marking have been temporarily decoupled per user request.

  for (final bad in badIngredients) {
    if (RegExp(r'\b' + RegExp.escape(bad) + r'\b').hasMatch(lower)) return IngredientLevel.bad;
  }
  for (final mod in moderateIngredients) {
    if (RegExp(r'\b' + RegExp.escape(mod) + r'\b').hasMatch(lower)) return IngredientLevel.moderate;
  }
  return IngredientLevel.good;
}

/// Determine the worst-case verdict across all ingredients.
/// Returns [IngredientLevel.good] if the list is empty (no data to flag).
IngredientLevel worstCaseVerdict(List<Ingredient> ingredients, List<String> allergens) {
  var worst = IngredientLevel.good;
  for (final ingredient in ingredients) {
    // Check the ingredient itself
    final level = classifyIngredient(ingredient.text, allergens);
    if (level == IngredientLevel.bad) return IngredientLevel.bad;
    if (level == IngredientLevel.moderate) worst = IngredientLevel.moderate;

    // Recursively check sub-ingredients
    if (ingredient.subIngredients.isNotEmpty) {
      final subWorst = worstCaseVerdict(ingredient.subIngredients, allergens);
      if (subWorst == IngredientLevel.bad) return IngredientLevel.bad;
      if (subWorst == IngredientLevel.moderate) worst = IngredientLevel.moderate;
    }
  }
  return worst;
}
