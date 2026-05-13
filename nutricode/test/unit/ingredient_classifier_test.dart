import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/utils/ingredient_classifier.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';

void main() {
  group('classifyIngredient', () {
    test('classifies exactly known bad ingredients as bad', () {
      expect(classifyIngredient('aspartame', []), IngredientLevel.bad);
      expect(classifyIngredient('trans fat', []), IngredientLevel.bad);
      expect(classifyIngredient('E102', []), IngredientLevel.bad);
    });

    test('classifies exactly known moderate ingredients as moderate', () {
      expect(classifyIngredient('sugar', []), IngredientLevel.moderate);
      expect(classifyIngredient('citric acid', []), IngredientLevel.moderate);
      expect(classifyIngredient('E101', []), IngredientLevel.moderate);
      // Recently updated ingredients (moved from bad to moderate)
      expect(classifyIngredient('monosodium glutamate', []), IngredientLevel.moderate);
      expect(classifyIngredient('carrageenan', []), IngredientLevel.moderate);
    });

    test('classifies unknown or safe ingredients as good', () {
      expect(classifyIngredient('water', []), IngredientLevel.good);
      expect(classifyIngredient('organic apples', []), IngredientLevel.good);
      expect(classifyIngredient('vitamin c', []), IngredientLevel.good); // 'ascorbic acid' is moderate, 'vitamin c' is good/unclassified
    });

    test('uses word boundaries to prevent false positives', () {
      // "fat" shouldn't trigger "trans fat"
      expect(classifyIngredient('fat', []), IngredientLevel.good);
      // "natural color" shouldn't trigger "artificial color"
      expect(classifyIngredient('natural color', []), IngredientLevel.good);
    });

    test('handles case insensitivity', () {
      expect(classifyIngredient('ASPARTAME', []), IngredientLevel.bad);
      expect(classifyIngredient('SuGar', []), IngredientLevel.moderate);
    });
  });

  group('worstCaseVerdict', () {
    test('returns good for empty list', () {
      expect(worstCaseVerdict([], []), IngredientLevel.good);
    });

    test('returns worst level found in top-level ingredients', () {
      final ingredients = [
        Ingredient(text: 'water', englishText: '', subIngredients: []),
        Ingredient(text: 'sugar', englishText: '', subIngredients: []),
      ];
      expect(worstCaseVerdict(ingredients, []), IngredientLevel.moderate);
    });

    test('returns bad if any ingredient is bad, even if sub-ingredients are good', () {
      final ingredients = [
        Ingredient(text: 'water', englishText: '', subIngredients: []),
        Ingredient(text: 'aspartame', englishText: '', subIngredients: []),
      ];
      expect(worstCaseVerdict(ingredients, []), IngredientLevel.bad);
    });

    test('recursively checks sub-ingredients', () {
      final ingredients = [
        Ingredient(text: 'sauce', englishText: '', subIngredients: [
          Ingredient(text: 'water', englishText: '', subIngredients: []),
          Ingredient(text: 'E102', englishText: '', subIngredients: []), // Bad
        ]),
      ];
      expect(worstCaseVerdict(ingredients, []), IngredientLevel.bad);
    });
  });
}
