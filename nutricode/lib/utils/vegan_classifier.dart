import '../services/open_food_facts_service.dart';

/// Keywords that indicate an ingredient is animal-derived.
/// All lowercase — matched against the ingredient's English text.
const _animalKeywords = [
  // Dairy
  'milk', 'cream', 'butter', 'cheese', 'yogurt', 'yoghurt',
  'ghee', 'whey', 'casein', 'lactose', 'lactalbumin',
  'skimmed milk', 'condensed milk', 'creme fraiche',
  // Eggs
  'egg', 'eggs', 'albumin',
  // Meat & by-products
  'beef', 'pork', 'chicken', 'turkey', 'lamb', 'duck', 'veal', 'venison',
  'bacon', 'ham', 'lard', 'tallow', 'gelatin', 'gelatine', 'collagen',
  // Seafood
  'fish', 'salmon', 'tuna', 'cod', 'shrimp', 'prawn', 'prawns',
  'crab', 'lobster', 'anchovy', 'anchovies', 'sardine', 'sardines',
  'mackerel', 'herring', 'mussel', 'mussels', 'oyster', 'oysters',
  'clam', 'clams', 'squid', 'octopus', 'scallop', 'scallops', 'tilapia',
  // Other animal-derived
  'honey', 'beeswax', 'carmine', 'shellac', 'royal jelly', 'isinglass',
  'lanolin',
];

/// Plant-based ingredients whose names happen to contain animal keywords.
/// Checked by exact match against the full ingredient text to avoid false positives.
const _veganExceptions = [
  'cocoa butter',
  'shea butter',
  'peanut butter',
  'almond butter',
  'cashew butter',
  'sunflower butter',
  'coconut butter',
  'coconut cream',
  'coconut milk',
  'oat milk',
  'soy milk',
  'almond milk',
  'rice milk',
  'hemp milk',
  'oat cream',
];

/// Returns `true` if the ingredient text appears to be animal-derived.
bool _isAnimalDerived(String ingredientText) {
  final text = ingredientText.toLowerCase().trim();
  if (_veganExceptions.contains(text)) return false;

  for (final keyword in _animalKeywords) {
    if (RegExp(r'\b' + RegExp.escape(keyword) + r'\b').hasMatch(text)) {
      return true;
    }
  }
  return false;
}

/// Returns true if a single ingredient (ignoring sub-ingredients) is animal-derived.
bool isIngredientNonVegan(Ingredient ingredient) {
  final text = ingredient.englishText.isNotEmpty
      ? ingredient.englishText
      : ingredient.text;
  return text.isNotEmpty && _isAnimalDerived(text);
}

/// Returns `true` if no animal-derived ingredient is detected in the list.
bool isVegan(List<Ingredient> ingredients) {
  return getNonVeganIngredients(ingredients).isEmpty;
}

/// Returns deduplicated display names of detected non-vegan ingredients.
List<String> getNonVeganIngredients(List<Ingredient> ingredients) {
  final detected = <String>{};
  for (final ingredient in ingredients) {
    _collectNonVegan(ingredient, detected);
  }
  return detected.toList();
}

void _collectNonVegan(Ingredient ingredient, Set<String> detected) {
  final searchText = ingredient.englishText.isNotEmpty
      ? ingredient.englishText
      : ingredient.text;

  if (searchText.isNotEmpty && _isAnimalDerived(searchText)) {
    final display = searchText.trim();
    detected.add(display[0].toUpperCase() + display.substring(1).toLowerCase());
  }

  for (final sub in ingredient.subIngredients) {
    _collectNonVegan(sub, detected);
  }
}
