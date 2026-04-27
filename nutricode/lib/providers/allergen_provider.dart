import 'package:flutter/material.dart';

class AllergenProvider extends ChangeNotifier {
  static final AllergenProvider instance = AllergenProvider._();
  AllergenProvider._();

  static const List<String> commonAllergens = [
    'celery',
    'crustaceans',
    'eggs',
    'fish',
    'gluten',
    'lupin',
    'milk',
    'molluscs',
    'mustard',
    'nuts',
    'peanuts',
    'sesame',
    'soybeans',
    'sulphites',
  ];

  static const Map<String, String> _displayNames = {
    'celery': 'Celery',
    'crustaceans': 'Crustaceans',
    'eggs': 'Eggs',
    'fish': 'Fish',
    'gluten': 'Gluten',
    'lupin': 'Lupin',
    'milk': 'Milk / Dairy',
    'molluscs': 'Molluscs',
    'mustard': 'Mustard',
    'nuts': 'Tree Nuts',
    'peanuts': 'Peanuts',
    'sesame': 'Sesame',
    'soybeans': 'Soybeans',
    'sulphites': 'Sulphites',
  };

  final Set<String> _selected = {};

  Set<String> get selectedAllergens => Set.unmodifiable(_selected);

  bool isSelected(String allergen) => _selected.contains(allergen);

  void toggle(String allergen) {
    if (_selected.contains(allergen)) {
      _selected.remove(allergen);
    } else {
      _selected.add(allergen);
    }
    notifyListeners();
  }

  static String displayName(String allergen) =>
      _displayNames[allergen] ?? allergen;
}
