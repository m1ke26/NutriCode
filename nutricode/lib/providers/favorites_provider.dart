import 'package:flutter/material.dart';
import '../models/favorite_product.dart';
import '../services/auth_service.dart';
import '../services/open_food_facts_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final AuthService _authService;

  FavoritesProvider(this._authService);

  List<FavoriteProduct> _favorites = [];
  List<FavoriteProduct> get favorites => List.unmodifiable(_favorites);
  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(String barcode) {
    return _favorites.any((f) => f.barcode == barcode);
  }

  Future<void> loadFromFirestore() async {
    _favorites = await _authService.getFavorites();
    notifyListeners();
  }

  Future<void> addFavorite(ProductResult product, String barcode) async {
    // Avoid duplicates
    if (isFavorite(barcode)) return;

    await _authService.addFavorite(
      barcode: barcode,
      name: product.name,
      imageUrl: product.imageUrl,
      brand: product.brand,
    );
    // Optimistic local update — insert at front (most recent first)
    _favorites.insert(
      0,
      FavoriteProduct(
        id: '',
        barcode: barcode,
        name: product.name,
        imageUrl: product.imageUrl,
        brand: product.brand,
        addedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> removeFavorite(String barcode) async {
    await _authService.removeFavorite(barcode);
    _favorites.removeWhere((f) => f.barcode == barcode);
    notifyListeners();
  }

  Future<void> toggleFavorite(ProductResult product, String barcode) async {
    if (isFavorite(barcode)) {
      await removeFavorite(barcode);
    } else {
      await addFavorite(product, barcode);
    }
  }
}
