import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/privacy_policy_screen.dart';

void main() {
  group('PrivacyPolicyScreen Widget Tests', () {
    testWidgets('renders all policy headers and paragraphs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      // Verify screen title and hero header card are visible
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Your privacy matters'), findsOneWidget);
      expect(find.text('We are committed to protecting your personal data and being transparent about how we use it.'), findsOneWidget);

      // Verify first two sections are visible (others will be built lazily when scrolled)
      expect(find.text('1. Data We Collect'), findsOneWidget);
      expect(find.text('2. How We Use Your Data'), findsOneWidget);
    });
  });
}
