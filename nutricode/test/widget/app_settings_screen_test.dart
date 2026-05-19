import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/app_settings_screen.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

class LocalMockHistoryProvider extends HistoryProvider {
  bool clearHistoryCalled = false;
  LocalMockHistoryProvider(super.authService);

  @override
  bool get isEmpty => false;

  @override
  Future<void> clearHistory() async {
    clearHistoryCalled = true;
  }
}

void main() {
  group('AppSettingsScreen Widget Tests', () {
    late MockAuthService mockAuth;
    late LocalMockHistoryProvider mockHistoryProvider;

    setUp(() {
      mockAuth = MockAuthService();
      mockHistoryProvider = LocalMockHistoryProvider(mockAuth);
    });

    Widget buildAppSettingsScreen() {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<HistoryProvider>.value(value: mockHistoryProvider),
        ],
        child: const MaterialApp(
          home: AppSettingsScreen(),
        ),
      );
    }

    testWidgets('renders setting options and app version info', (WidgetTester tester) async {
      await tester.pumpWidget(buildAppSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('DATA'), findsOneWidget);
      expect(find.text('Clear Scan History'), findsOneWidget);
      expect(find.text('Remove all previously scanned products'), findsOneWidget);
      expect(find.text('APP INFO'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('v3.0.0'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog on clear scan history tap and handles cancel', (WidgetTester tester) async {
      await tester.pumpWidget(buildAppSettingsScreen());
      await tester.pumpAndSettle();

      // Tap Clear Scan History list tile
      await tester.tap(find.text('Clear Scan History'));
      await tester.pumpAndSettle();

      // Verify AlertDialog elements
      expect(find.text('Clear History'), findsOneWidget);
      expect(find.text('This will permanently remove all your scanned products. This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed and clearHistory not called
      expect(find.text('Clear History'), findsNothing);
      expect(mockHistoryProvider.clearHistoryCalled, isFalse);
    });

    testWidgets('triggers clearHistory and shows Snackbar when confirmed', (WidgetTester tester) async {
      await tester.pumpWidget(buildAppSettingsScreen());
      await tester.pumpAndSettle();

      // Tap Clear Scan History
      await tester.tap(find.text('Clear Scan History'));
      await tester.pumpAndSettle();

      // Tap Clear
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Verify dialog is closed, provider called, and SnackBar shows up
      expect(find.text('Clear History'), findsNothing);
      expect(mockHistoryProvider.clearHistoryCalled, isTrue);
      expect(find.text('Scan history cleared.'), findsOneWidget);
    });
  });
}
