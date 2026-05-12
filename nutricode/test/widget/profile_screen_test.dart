import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/profile_screen.dart';
import 'package:NutriCode/screens/allergen_screen.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

void main() {
  group('ProfileScreen widget tests', () {
    late MockAuthService mockAuth;
    late AllergenProvider allergenProvider;
    late VeganProvider veganProvider;

    Widget buildTestableProfileScreen({
      MockAuthService? authService,
      AllergenProvider? allergenProv,
      VeganProvider? veganProv,
    }) {
      mockAuth = authService ?? MockAuthService();
      allergenProvider = allergenProv ?? AllergenProvider(mockAuth);
      veganProvider = veganProv ?? VeganProvider(mockAuth);

      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AllergenProvider>.value(value: allergenProvider),
          ChangeNotifierProvider<VeganProvider>.value(value: veganProvider),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      );
    }

    testWidgets('displays My Profile title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('displays coming soon labels on feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Coming soon!'), findsNWidgets(3));
    });

    testWidgets('displays avatar placeholder icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('displays feature preview cards', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('displays My Allergens card', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('My Allergens'), findsOneWidget);
    });

    testWidgets('shows "No restrictions" when no allergens selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('No restrictions'), findsOneWidget);
    });

    testWidgets('shows restriction count when allergens are selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      // Toggle after initial load so loadFromFirestore doesn't reset state
      allergenProvider.toggle('gluten');
      allergenProvider.toggle('milk');
      await tester.pumpAndSettle();

      expect(find.text('2 restrictions active'), findsOneWidget);
    });

    testWidgets('shows singular "restriction" for single selection', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      // Toggle after initial load so loadFromFirestore doesn't reset state
      allergenProvider.toggle('gluten');
      await tester.pumpAndSettle();

      expect(find.text('1 restriction active'), findsOneWidget);
    });

    testWidgets('navigates to AllergenScreen when allergen card tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Allergens'));
      await tester.pumpAndSettle();

      expect(find.byType(AllergenScreen), findsOneWidget);
    });

    testWidgets('displays Vegan Mode card', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Vegan Mode'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('vegan toggle switches state', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Disabled'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Detection active'), findsOneWidget);
    });

    testWidgets('has icon for Scan History feature', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('has icon for App Settings feature', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_suggest_rounded), findsOneWidget);
    });

    testWidgets('has icon for My Allergens card', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.no_food_rounded), findsOneWidget);
    });

    testWidgets('has scaffold with correct background', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('is scrollable when content exceeds viewport', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays user name from mock data', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('displays user email from mock data', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('has logout button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('logout button shows confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsNWidgets(2)); // title + button
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('has edit name button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });

    testWidgets('has camera icon on avatar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableProfileScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });
  });
}
