import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/main.dart';
import 'package:NutriCode/services/auth_service.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/screens/welcome_screen.dart';
import 'package:NutriCode/screens/login_screen.dart';
import 'integration_mock_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration/Acceptance Tests', () {
    late MockAuthService mockAuth;

    setUp(() {
      mockAuth = MockAuthService();
    });

    Widget buildTestableAuthApp() {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AllergenProvider>(create: (_) => AllergenProvider(mockAuth)),
          ChangeNotifierProvider<VeganProvider>(create: (_) => VeganProvider(mockAuth)),
          ChangeNotifierProvider<HistoryProvider>(create: (_) => HistoryProvider(mockAuth)),
        ],
        child: const MaterialApp(
          home: AuthWrapper(),
        ),
      );
    }

    testWidgets(
      'Scenario 1: User navigates from WelcomeScreen to LoginScreen and goes back',
      (WidgetTester tester) async {
        // Given: The app launches on the unauthenticated WelcomeScreen
        await tester.pumpWidget(buildTestableAuthApp());
        await tester.pumpAndSettle();

        // WelcomeScreen should be active
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
        expect(find.text('Get Started'), findsOneWidget);

        // When: User taps 'Get Started'
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Then: The app navigates to the LoginScreen
        expect(find.byType(WelcomeScreen), findsNothing);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Email or Username'), findsOneWidget);

        // When: User taps the back arrow button on the LoginScreen
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Then: The app navigates back to the WelcomeScreen
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });
}
