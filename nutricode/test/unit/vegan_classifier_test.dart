import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/utils/vegan_classifier.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';

void main() {
  group('Vegan Classifier Unit Tests', () {
    test('isIngredientNonVegan detects dairy ingredients', () {
      final dairy = Ingredient(text: 'milk powder', englishText: 'milk powder');
      final cheese = Ingredient(text: 'cheddar cheese', englishText: 'cheddar cheese');
      final organicMilk = Ingredient(text: 'skimmed milk', englishText: 'skimmed milk');

      expect(isIngredientNonVegan(dairy), isTrue);
      expect(isIngredientNonVegan(cheese), isTrue);
      expect(isIngredientNonVegan(organicMilk), isTrue);
    });

    test('isIngredientNonVegan detects meat and seafood ingredients', () {
      final beef = Ingredient(text: 'beef fat', englishText: 'beef fat');
      final salmon = Ingredient(text: 'salmon fillet', englishText: 'salmon fillet');
      final pork = Ingredient(text: 'pork gelatin', englishText: 'pork gelatin');

      expect(isIngredientNonVegan(beef), isTrue);
      expect(isIngredientNonVegan(salmon), isTrue);
      expect(isIngredientNonVegan(pork), isTrue);
    });

    test('isIngredientNonVegan detects eggs and other by-products', () {
      final egg = Ingredient(text: 'egg yolk', englishText: 'egg yolk');
      final honey = Ingredient(text: 'honey extract', englishText: 'honey extract');
      final carmine = Ingredient(text: 'carmine (color)', englishText: 'carmine (color)');

      expect(isIngredientNonVegan(egg), isTrue);
      expect(isIngredientNonVegan(honey), isTrue);
      expect(isIngredientNonVegan(carmine), isTrue);
    });

    test('isIngredientNonVegan respects vegan exceptions', () {
      final cocoa = Ingredient(text: 'cocoa butter', englishText: 'cocoa butter');
      final peanut = Ingredient(text: 'peanut butter', englishText: 'peanut butter');
      final coconut = Ingredient(text: 'coconut milk', englishText: 'coconut milk');
      final oat = Ingredient(text: 'oat cream', englishText: 'oat cream');

      expect(isIngredientNonVegan(cocoa), isFalse);
      expect(isIngredientNonVegan(peanut), isFalse);
      expect(isIngredientNonVegan(coconut), isFalse);
      expect(isIngredientNonVegan(oat), isFalse);
    });

    test('isVegan returns true for a list of purely plant-based ingredients', () {
      final ingredients = [
        Ingredient(text: 'water', englishText: 'water'),
        Ingredient(text: 'cocoa butter', englishText: 'cocoa butter'),
        Ingredient(text: 'sugar', englishText: 'sugar'),
        Ingredient(text: 'soy lecithin', englishText: 'soy lecithin'),
      ];

      expect(isVegan(ingredients), isTrue);
    });

    test('isVegan returns false when any animal-derived ingredient is present', () {
      final ingredients = [
        Ingredient(text: 'water', englishText: 'water'),
        Ingredient(text: 'milk chocolate', englishText: 'milk chocolate'),
        Ingredient(text: 'sugar', englishText: 'sugar'),
      ];

      expect(isVegan(ingredients), isFalse);
    });

    test('getNonVeganIngredients lists and formats animal-derived ingredients properly', () {
      final ingredients = [
        Ingredient(text: 'cocoa butter', englishText: 'cocoa butter'),
        Ingredient(text: 'beef gelatin', englishText: 'beef gelatin'),
        Ingredient(text: 'skimmed milk powder', englishText: 'skimmed milk powder'),
      ];

      final results = getNonVeganIngredients(ingredients);

      expect(results.length, 2);
      expect(results.contains('Beef gelatin'), isTrue);
      expect(results.contains('Skimmed milk powder'), isTrue);
    });

    test('getNonVeganIngredients scans sub-ingredients recursively', () {
      final subIngredients = [
        Ingredient(text: 'whey protein', englishText: 'whey protein'),
        Ingredient(text: 'cocoa butter', englishText: 'cocoa butter'),
      ];
      final complexIngredient = Ingredient(
        text: 'chocolate chips',
        englishText: 'chocolate chips',
        subIngredients: subIngredients,
      );

      final results = getNonVeganIngredients([complexIngredient]);

      expect(results.length, 1);
      expect(results.first, 'Whey protein');
    });

    test('isIngredientNonVegan falls back to raw text if englishText is empty', () {
      final fallback = Ingredient(text: 'milk', englishText: '');
      expect(isIngredientNonVegan(fallback), isTrue);
    });
  });
}
