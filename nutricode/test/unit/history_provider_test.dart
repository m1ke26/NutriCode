import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/models/scan_history_entry.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';
import '../mock_helper.dart';

class LocalMockAuthService extends MockAuthService {
  List<ScanHistoryEntry> mockHistory = [];
  bool clearHistoryCalled = false;
  bool addScanCalled = false;
  String? lastAddedBarcode;
  String? lastAddedName;

  @override
  Future<List<ScanHistoryEntry>> getScanHistory() async => mockHistory;

  @override
  Future<void> clearScanHistory() async {
    clearHistoryCalled = true;
    mockHistory.clear();
  }

  @override
  Future<void> addScanToHistory({
    required String barcode,
    String? name,
    String? imageUrl,
    String? brand,
  }) async {
    addScanCalled = true;
    lastAddedBarcode = barcode;
    lastAddedName = name;
    mockHistory.add(ScanHistoryEntry(
      id: 'mock_id',
      barcode: barcode,
      name: name,
      imageUrl: imageUrl,
      brand: brand,
      scannedAt: DateTime.now(),
    ));
  }
}

void main() {
  group('HistoryProvider Unit Tests', () {
    late LocalMockAuthService mockAuth;
    late HistoryProvider provider;

    setUp(() {
      mockAuth = LocalMockAuthService();
      provider = HistoryProvider(mockAuth);
    });

    test('initializes with empty entries', () {
      expect(provider.entries, isEmpty);
      expect(provider.isEmpty, isTrue);
    });

    test('loadFromFirestore loads entries from auth service', () async {
      mockAuth.mockHistory = [
        ScanHistoryEntry(
          id: '1',
          barcode: '123',
          name: 'Cereal',
          scannedAt: DateTime.now(),
        ),
      ];

      await provider.loadFromFirestore();

      expect(provider.entries.length, 1);
      expect(provider.entries.first.barcode, '123');
      expect(provider.entries.first.name, 'Cereal');
      expect(provider.isEmpty, isFalse);
    });

    test('clearHistory clears local state and calls auth service clear', () async {
      provider = HistoryProvider(mockAuth);
      mockAuth.mockHistory = [
        ScanHistoryEntry(
          id: '1',
          barcode: '123',
          name: 'Cereal',
          scannedAt: DateTime.now(),
        ),
      ];

      await provider.loadFromFirestore();
      expect(provider.entries.isNotEmpty, isTrue);

      await provider.clearHistory();

      expect(provider.entries, isEmpty);
      expect(mockAuth.clearHistoryCalled, isTrue);
    });

    test('addScan calls auth service add and adds optimistically to front of list', () async {
      final product = ProductResult(
        found: true,
        name: 'Organic Milk',
        imageUrl: 'http://image.com',
        brand: 'Nature',
        ingredients: [],
        allergens: [],
      );

      bool listenerNotified = false;
      provider.addListener(() {
        listenerNotified = true;
      });

      await provider.addScan(product, '999888');

      expect(mockAuth.addScanCalled, isTrue);
      expect(mockAuth.lastAddedBarcode, '999888');
      expect(mockAuth.lastAddedName, 'Organic Milk');

      expect(provider.entries.length, 1);
      expect(provider.entries.first.barcode, '999888');
      expect(provider.entries.first.name, 'Organic Milk');
      expect(provider.entries.first.imageUrl, 'http://image.com');
      expect(provider.entries.first.brand, 'Nature');
      expect(listenerNotified, isTrue);
    });
  });
}
