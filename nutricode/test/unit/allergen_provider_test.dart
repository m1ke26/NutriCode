import 'package:flutter_test/flutter_test.dart';
import '../../lib/providers/allergen_provider.dart';

void main() {
  group('AllergenProvider', () {
    setUp(() {
      // Clear all allergens before each test
      for (final allergen in AllergenProvider.commonAllergens.toList()) {
        if (AllergenProvider.instance.isSelected(allergen)) {
          AllergenProvider.instance.toggle(allergen);
        }
      }
    });

    test('initializes with no selected allergens', () {
      expect(AllergenProvider.instance.selectedAllergens.isEmpty, true);
    });

    test('toggles allergen selection on', () {
      AllergenProvider.instance.toggle('gluten');
      expect(AllergenProvider.instance.isSelected('gluten'), true);
    });

    test('toggles allergen selection off', () {
      AllergenProvider.instance.toggle('gluten');
      AllergenProvider.instance.toggle('gluten');
      expect(AllergenProvider.instance.isSelected('gluten'), false);
    });

    test('maintains multiple selected allergens', () {
      AllergenProvider.instance.toggle('gluten');
      AllergenProvider.instance.toggle('milk');
      AllergenProvider.instance.toggle('nuts');

      expect(AllergenProvider.instance.selectedAllergens.length, 3);
      expect(AllergenProvider.instance.isSelected('gluten'), true);
      expect(AllergenProvider.instance.isSelected('milk'), true);
      expect(AllergenProvider.instance.isSelected('nuts'), true);
    });

    test('returns unmodifiable set of selected allergens', () {
      AllergenProvider.instance.toggle('gluten');
      final selected = AllergenProvider.instance.selectedAllergens;

      expect(() => selected.add('milk'), throwsUnsupportedError);
    });

    test('notifies listeners on toggle', () {
      var notificationCount = 0;
      AllergenProvider.instance.addListener(() {
        notificationCount++;
      });

      AllergenProvider.instance.toggle('gluten');
      expect(notificationCount, 1);

      AllergenProvider.instance.toggle('milk');
      expect(notificationCount, 2);

      // Cleanup
      AllergenProvider.instance.removeListener(() {});
    });

    test('returns correct display name for allergen', () {
      expect(AllergenProvider.displayName('gluten'), 'Gluten');
      expect(AllergenProvider.displayName('milk'), 'Milk / Dairy');
      expect(AllergenProvider.displayName('nuts'), 'Tree Nuts');
      expect(AllergenProvider.displayName('peanuts'), 'Peanuts');
    });

    test('returns original name as fallback for unknown allergen', () {
      expect(AllergenProvider.displayName('unknown_allergen'), 'unknown_allergen');
    });

    test('contains all required common allergens', () {
      expect(AllergenProvider.commonAllergens, contains('gluten'));
      expect(AllergenProvider.commonAllergens, contains('milk'));
      expect(AllergenProvider.commonAllergens, contains('eggs'));
      expect(AllergenProvider.commonAllergens, contains('peanuts'));
      expect(AllergenProvider.commonAllergens, contains('nuts'));
      expect(AllergenProvider.commonAllergens, contains('fish'));
      expect(AllergenProvider.commonAllergens, contains('crustaceans'));
      expect(AllergenProvider.commonAllergens, contains('molluscs'));
      expect(AllergenProvider.commonAllergens, contains('sesame'));
      expect(AllergenProvider.commonAllergens.length, 14);
    });

    test('is singleton instance', () {
      final instance1 = AllergenProvider.instance;
      final instance2 = AllergenProvider.instance;

      expect(identical(instance1, instance2), true);
    });

    test('persists state across multiple toggles', () {
      AllergenProvider.instance.toggle('gluten');
      AllergenProvider.instance.toggle('milk');
      expect(AllergenProvider.instance.selectedAllergens.length, 2);

      AllergenProvider.instance.toggle('gluten');
      expect(AllergenProvider.instance.selectedAllergens.length, 1);
      expect(AllergenProvider.instance.isSelected('milk'), true);
    });
  });
}
