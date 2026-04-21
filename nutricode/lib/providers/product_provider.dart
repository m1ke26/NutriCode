import 'package:flutter/material.dart';
import '../services/open_food_facts_service.dart';

enum ProductState { initial, loading, success, error, notFound }

class ProductProvider with ChangeNotifier {
  final Map<String, ProductResult> _cache = {};
  bool _isDisposed = false;

  ProductState _state = ProductState.initial;
  ProductState get state => _state;

  ProductResult? _product;
  ProductResult? get product => _product;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> fetchProduct(String barcode) async {
    // Clean the barcode — strip whitespace only; let the service handle digit cleaning
    final cleaned = barcode.trim();
    if (cleaned.isEmpty) {
      _state = ProductState.notFound;
      notifyListeners();
      return;
    }

    if (_cache.containsKey(cleaned)) {
      _product = _cache[cleaned];
      _state = _product!.found ? ProductState.success : ProductState.notFound;
      notifyListeners();
      return;
    }

    _state = ProductState.loading;
    notifyListeners();

    try {
      final result = await OpenFoodFactsService.fetchProduct(cleaned).timeout(
        const Duration(seconds: 15),
      );

      if (_isDisposed) return;

      _cache[cleaned] = result;
      _product = result;

      if (result.found) {
        _state = ProductState.success;
      } else {
        _state = ProductState.notFound;
      }
    } on FormatException catch (_) {
      if (_isDisposed) return;
      _state = ProductState.notFound;
    } catch (e) {
      if (_isDisposed) return;
      _state = ProductState.error;
      _errorMessage =
          'Parece que estás sem internet no supermercado! 🛒📶\nVerifica a tua ligação e tenta novamente.';
    }

    notifyListeners();
  }
}
