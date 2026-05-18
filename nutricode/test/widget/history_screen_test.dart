import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/history_screen.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/models/scan_history_entry.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

class LocalMockAuthService extends MockAuthService {
  List<ScanHistoryEntry> mockHistory = [];
  @override
  Future<List<ScanHistoryEntry>> getScanHistory() async => mockHistory;
}

void main() {
  group('HistoryScreen Widget Tests', () {
    late LocalMockAuthService mockAuth;
    late HistoryProvider historyProvider;

    setUp(() {
      mockAuth = LocalMockAuthService();
      historyProvider = HistoryProvider(mockAuth);
    });

    Widget buildHistoryScreen({VoidCallback? onGoToScan}) {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
        ],
        child: MaterialApp(
          home: HistoryScreen(onGoToScan: onGoToScan),
        ),
      );
    }

    testWidgets('renders empty state when history is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildHistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('No scans yet'), findsOneWidget);
      expect(find.text('Start by scanning a product.\nYour scan history will appear here.'), findsOneWidget);
      expect(find.text('Start Scanning'), findsOneWidget);
    });

    testWidgets('triggers onGoToScan callback when Start Scanning button is tapped', (WidgetTester tester) async {
      bool scanTapped = false;
      await tester.pumpWidget(buildHistoryScreen(onGoToScan: () {
        scanTapped = true;
      }));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Start Scanning'));
      await tester.pump();

      expect(scanTapped, isTrue);
    });

    testWidgets('renders list of scan history cards when populated', (WidgetTester tester) async {
      mockAuth.mockHistory = [
        ScanHistoryEntry(
          id: '1',
          barcode: '123456',
          name: 'Healthy Cereal',
          brand: 'Nature Choice',
          scannedAt: DateTime.now(),
        ),
        ScanHistoryEntry(
          id: '2',
          barcode: '789012',
          name: 'Pure Apple Juice',
          brand: 'Fruit Farms',
          scannedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await historyProvider.loadFromFirestore();

      await tester.pumpWidget(buildHistoryScreen());
      await tester.pumpAndSettle();

      // Verify both items show up
      expect(find.text('Healthy Cereal'), findsOneWidget);
      expect(find.text('Nature Choice'), findsOneWidget);
      expect(find.text('Pure Apple Juice'), findsOneWidget);
      expect(find.text('Fruit Farms'), findsOneWidget);

      // Verify that "View Full Scan" buttons render
      expect(find.text('View Full Scan'), findsNWidgets(2));
    });
  });
}
