import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:NutriCode/screens/verdict_screen.dart';
import 'package:NutriCode/services/open_food_facts_service.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/providers/favorites_provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

void main() {
  group('VerdictScreen Widget Tests', () {
    late MockAuthService mockAuth;
    late AllergenProvider allergenProvider;
    late VeganProvider veganProvider;
    late HistoryProvider historyProvider;
    late FavoritesProvider favoritesProvider;

    setUp(() {
      mockAuth = MockAuthService();
      allergenProvider = AllergenProvider(mockAuth);
      veganProvider = VeganProvider(mockAuth);
      historyProvider = HistoryProvider(mockAuth);
      favoritesProvider = FavoritesProvider(mockAuth);
    });

    Widget buildVerdictScreen(OpenFoodFactsService service, String barcode) {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuth),
          ChangeNotifierProvider<AllergenProvider>.value(value: allergenProvider),
          ChangeNotifierProvider<VeganProvider>.value(value: veganProvider),
          ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
        ],
        child: MaterialApp(
          home: VerdictScreen(
            barcode: barcode,
            service: service,
            saveToHistory: false, // Prevent Firestore saves during tests
          ),
        ),
      );
    }

    testWidgets('shows loading spinner initially', (WidgetTester tester) async {
      final mockClient = http_testing.MockClient((request) async {
        // Delay to ensure the loading state remains visible
        await Future.delayed(const Duration(milliseconds: 100));
        return http.Response(jsonEncode({'status': 0}), 200);
      });
      final service = OpenFoodFactsService(client: mockClient);

      await tester.pumpWidget(buildVerdictScreen(service, '123'));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing product... 🔍'), findsOneWidget);
      
      // Let delay complete
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
    });

    testWidgets('shows product not found screen with Google Search option', (WidgetTester tester) async {
      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode({'status': 0}), 200);
      });
      final service = OpenFoodFactsService(client: mockClient);

      await tester.pumpWidget(buildVerdictScreen(service, '999111'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Product Not Found'), findsOneWidget);
      expect(find.text('Barcode: 999111'), findsOneWidget);
      expect(find.text('Search the Internet'), findsOneWidget);
      expect(find.text('Scan again'), findsOneWidget);
    });

    testWidgets('shows safe verdict when all ingredients are good', (WidgetTester tester) async {
      final mockProduct = {
        'status': 1,
        'product': {
          'product_name': 'Pure Water',
          'brands': 'Nature',
          'ingredients': [
            {'text': 'water', 'english_text': 'water', 'percent': 100}
          ],
          'allergens_tags': [],
          'nutriscore_grade': 'a',
          'nutrient_levels': {}
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockProduct), 200);
      });
      final service = OpenFoodFactsService(client: mockClient);

      await tester.pumpWidget(buildVerdictScreen(service, '777'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Pure Water'), findsOneWidget);
      expect(find.text('Nature'), findsOneWidget);
      expect(find.text('All ingredients are safe'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('shows moderate verdict when some ingredients are moderate', (WidgetTester tester) async {
      final mockProduct = {
        'status': 1,
        'product': {
          'product_name': 'Slightly Salted Nuts',
          'brands': 'Nutty',
          'ingredients': [
            {'text': 'peanuts', 'english_text': 'peanuts'},
            {'text': 'salt', 'english_text': 'salt'} // Salt is moderate
          ],
          'allergens_tags': [],
          'nutriscore_grade': 'b',
          'nutrient_levels': {}
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockProduct), 200);
      });
      final service = OpenFoodFactsService(client: mockClient);

      await tester.pumpWidget(buildVerdictScreen(service, '888'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Slightly Salted Nuts'), findsOneWidget);
      expect(find.text('Some ingredients need attention'), findsOneWidget);
    });

    testWidgets('shows bad verdict when harmful ingredients present', (WidgetTester tester) async {
      final mockProduct = {
        'status': 1,
        'product': {
          'product_name': 'Soda Drink',
          'brands': 'SodaCorp',
          'ingredients': [
            {'text': 'water', 'english_text': 'water'},
            {'text': 'aspartame', 'english_text': 'aspartame'} // Aspartame is bad
          ],
          'allergens_tags': [],
          'nutriscore_grade': 'e',
          'nutrient_levels': {}
        }
      };

      final mockClient = http_testing.MockClient((request) async {
        return http.Response(jsonEncode(mockProduct), 200);
      });
      final service = OpenFoodFactsService(client: mockClient);

      await tester.pumpWidget(buildVerdictScreen(service, '555'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Soda Drink'), findsOneWidget);
      expect(find.text('Contains harmful ingredients'), findsOneWidget);
    });
  });
}
