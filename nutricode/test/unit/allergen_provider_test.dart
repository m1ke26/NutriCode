import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

void main() {
  group('AllergenProvider', () {
    late MockAuthService mockAuth;
    late AllergenProvider allergenProvider;

    setUp(() {
      mockAuth = MockAuthService();
      allergenProvider = AllergenProvider(mockAuth);
    });

    test('initializes with no selected allergens', () {
      expect(allergenProvider.selectedAllergens.isEmpty, true);
    });

    test('toggles allergen selection on', () {
      allergenProvider.toggle('gluten');
      expect(allergenProvider.isSelected('gluten'), true);
    });

    test('toggles allergen selection off', () {
      allergenProvider.toggle('gluten');
      allergenProvider.toggle('gluten');
      expect(allergenProvider.isSelected('gluten'), false);
    });

    test('maintains multiple selected allergens', () {
      allergenProvider.toggle('gluten');
      allergenProvider.toggle('milk');
      allergenProvider.toggle('nuts');

      expect(allergenProvider.selectedAllergens.length, 3);
      expect(allergenProvider.isSelected('gluten'), true);
      expect(allergenProvider.isSelected('milk'), true);
      expect(allergenProvider.isSelected('nuts'), true);
    });

    test('returns unmodifiable set of selected allergens', () {
      allergenProvider.toggle('gluten');
      final selected = allergenProvider.selectedAllergens;

      expect(() => (selected as dynamic).add('milk'), throwsUnsupportedError);
    });

    test('notifies listeners on toggle', () {
      var notificationCount = 0;
      allergenProvider.addListener(() {
        notificationCount++;
      });

      allergenProvider.toggle('gluten');
      expect(notificationCount, 1);

      allergenProvider.toggle('milk');
      expect(notificationCount, 2);
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

    test('persists state across multiple toggles', () {
      allergenProvider.toggle('gluten');
      allergenProvider.toggle('milk');
      expect(allergenProvider.selectedAllergens.length, 2);

      allergenProvider.toggle('gluten');
      expect(allergenProvider.selectedAllergens.length, 1);
      expect(allergenProvider.isSelected('milk'), true);
    });
  });
}
