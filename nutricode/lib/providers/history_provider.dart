import 'package:flutter/material.dart';
import '../models/scan_history_entry.dart';
import '../services/auth_service.dart';
import '../services/open_food_facts_service.dart';

class HistoryProvider extends ChangeNotifier {
  final AuthService _authService;

  HistoryProvider(this._authService);

  List<ScanHistoryEntry> _entries = [];
  List<ScanHistoryEntry> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;

  Future<void> loadFromFirestore() async {
    _entries = await _authService.getScanHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _authService.clearScanHistory();
    _entries = [];
    notifyListeners();
  }

  Future<void> addScan(ProductResult product, String barcode) async {
    await _authService.addScanToHistory(
      barcode: barcode,
      name: product.name,
      imageUrl: product.imageUrl,
      brand: product.brand,
    );
    // Optimistic local update — insert at front (most recent first)
    _entries.insert(
      0,
      ScanHistoryEntry(
        id: '',
        barcode: barcode,
        name: product.name,
        imageUrl: product.imageUrl,
        brand: product.brand,
        scannedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
