import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AllergenProvider extends ChangeNotifier {
  final AuthService _authService;

  AllergenProvider(this._authService);

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

  Set<String> _selected = {};

  Set<String> get selectedAllergens => Set.unmodifiable(_selected);

  bool isSelected(String allergen) => _selected.contains(allergen);

  // Initialize from Firestore
  Future<void> loadFromFirestore() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _selected = Set<String>.from(userData.allergens);
      notifyListeners();
    }
  }

  void toggle(String allergen) async {
    if (_selected.contains(allergen)) {
      _selected.remove(allergen);
    } else {
      _selected.add(allergen);
    }
    notifyListeners();
    
    // Save to Firestore
    await _authService.updateProfile(allergens: _selected.toList());
  }

  static String displayName(String allergen) =>
      _displayNames[allergen] ?? allergen;
}

