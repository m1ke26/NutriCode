import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/history_screen.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/models/scan_history_entry.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';
import 'package:NutriCode/services/auth_service.dart';
import 'integration_mock_helper.dart';

class LocalMockAuthService extends MockAuthService {
  List<ScanHistoryEntry> mockHistory = [];

  @override
  Future<List<ScanHistoryEntry>> getScanHistory() async => mockHistory;

  @override
  Future<void> addScanToHistory({
    required String barcode,
    String? name,
    String? imageUrl,
    String? brand,
  }) async {
    mockHistory.add(ScanHistoryEntry(
      id: 'h_id',
      barcode: barcode,
      name: name,
      imageUrl: imageUrl,
      brand: brand,
      scannedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> clearScanHistory() async {
    mockHistory.clear();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scan History Feature Integration/Acceptance Tests', () {
    late LocalMockAuthService mockAuth;
    late HistoryProvider historyProvider;

    setUp(() {
      mockAuth = LocalMockAuthService();
      historyProvider = HistoryProvider(mockAuth);
    });

    Widget buildTestableHistoryApp() {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HistoryScreen(),
          ),
        ),
      );
    }

    testWidgets(
      'Scenario 1: User views empty history, performs a scan and confirms it is recorded',
      (WidgetTester tester) async {
        // Given: History is empty at start
        await tester.pumpWidget(buildTestableHistoryApp());
        await tester.pumpAndSettle();

        expect(find.text('No scans yet'), findsOneWidget);

        // When: A scan is successfully captured
        final mockProduct = ProductResult(
          found: true,
          name: 'Super Orange Juice',
          imageUrl: '',
          brand: 'FreshCo',
          ingredients: [],
          allergens: [],
        );
        await historyProvider.addScan(mockProduct, '12345999');

        // Re-render UI to display updated history
        await tester.pumpAndSettle();

        // Then: The scan list displays the product details
        expect(find.text('No scans yet'), findsNothing);
        expect(find.text('Super Orange Juice'), findsOneWidget);
        expect(find.text('FreshCo'), findsOneWidget);
        expect(find.text('View Full Scan'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 2: User clears scan history and confirms the UI goes back to empty state',
      (WidgetTester tester) async {
        // Given: History is populated
        mockAuth.mockHistory = [
          ScanHistoryEntry(
            id: '1',
            barcode: '1111',
            name: 'Cookie',
            scannedAt: DateTime.now(),
          )
        ];
        await historyProvider.loadFromFirestore();

        await tester.pumpWidget(buildTestableHistoryApp());
        await tester.pumpAndSettle();

        expect(find.text('Cookie'), findsOneWidget);

        // When: User clears the history list
        await historyProvider.clearHistory();
        await tester.pumpAndSettle();

        // Then: The screen displays the empty message
        expect(find.text('Cookie'), findsNothing);
        expect(find.text('No scans yet'), findsOneWidget);
      },
    );
  });
}
