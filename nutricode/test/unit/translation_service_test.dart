import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/services/translation_service.dart';

void main() {
  group('TranslationService Unit Tests', () {
    test('translateToEnglishBulk returns empty list for empty input', () async {
      final results = await TranslationService.translateToEnglishBulk([]);
      expect(results, isEmpty);
    });

    test('translateToEnglish returns empty string for empty or whitespace-only input', () async {
      expect(await TranslationService.translateToEnglish(''), '');
      expect(await TranslationService.translateToEnglish('   '), '');
    });

    test('translateToEnglishBulk handles single and multiple elements with fallback or success', () async {
      // If there is no internet, this will successfully fall back to returning the lowercase input, which is a key tested feature.
      final results = await TranslationService.translateToEnglishBulk(['Milk', 'Egg']);
      expect(results.length, 2);
      expect(results.first, anyOf([equals('milk'), equals('milk')]));
      expect(results.last, anyOf([equals('egg'), equals('egg')]));
    });

    test('translateToEnglish handles single string input gracefully', () async {
      final result = await TranslationService.translateToEnglish('MILK');
      expect(result, 'milk');
    });
  });
}
