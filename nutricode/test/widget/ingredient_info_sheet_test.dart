import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/widgets/ingredient_info_sheet.dart';
import '../../lib/utils/ingredient_classifier.dart';

void main() {
  group('Ingredient Info Sheet Widget Tests', () {
    testWidgets('displays correct exact match description', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showIngredientInfo(
                    context,
                    ingredientName: 'aspartame',
                    level: IngredientLevel.bad,
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ));

      // Tap to show bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Expect to find the bottom sheet title and the exact description from the dictionary
      expect(find.text('aspartame'), findsOneWidget);
      // 'aspartame' has a specific description in the dictionary:
      expect(find.textContaining('An artificial sweetener'), findsOneWidget);
    });

    testWidgets('sorts by specific key correctly to prevent false substring matches', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  // "fat" should NOT pick up "trans fat" description
                  showIngredientInfo(
                    context,
                    ingredientName: 'fat',
                    level: IngredientLevel.good,
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // If it incorrectly matched "trans fat", we would see "strictly avoid"
      // It should just show a generic "Good" description because "fat" itself isn't a key
      expect(find.textContaining('strictly avoid', skipOffstage: false), findsNothing);
      expect(find.textContaining('commonly found in everyday foods'), findsWidgets); // Generic good description
    });

    testWidgets('shows correct fallback description when not found in dictionary', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showIngredientInfo(
                    context,
                    ingredientName: 'unknown harmless ingredient',
                    level: IngredientLevel.good,
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.textContaining('unknown harmless ingredient'), findsOneWidget);
      expect(find.textContaining('commonly found in everyday foods'), findsOneWidget);
    });
  });
}
