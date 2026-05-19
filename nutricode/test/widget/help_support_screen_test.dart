import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/help_support_screen.dart';
import 'package:NutriCode/screens/privacy_policy_screen.dart';

void main() {
  group('HelpSupportScreen Widget Tests', () {
    testWidgets('renders all main settings sections and menu tiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('GETTING STARTED'), findsOneWidget);
      expect(find.text('How to Use NutriCode'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('About NutriCode'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('CONTACT'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('nutricode.support@gmail.com'), findsOneWidget);
    });

    testWidgets('tapping How to Use NutriCode opens modal bottom sheet with steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );

      // Tap How to Use NutriCode tile
      await tester.tap(find.text('How to Use NutriCode'));
      // Use pump with a duration instead of pumpAndSettle because the sheet
      // contains a repeating AnimationController that never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Modal bottom sheet should be visible
      expect(find.text('How to Use NutriCode'), findsWidgets); // finds in sheet too
      expect(find.text('Follow these steps to get started'), findsOneWidget);
      expect(find.text('Scan a product'), findsOneWidget);
      expect(find.text('View ingredients & nutrition'), findsOneWidget);

      // Drag/scroll ListView to reveal step 3
      await tester.drag(find.byType(ListView).last, const Offset(0, -200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Set your allergens'), findsOneWidget);
    });

    testWidgets('tapping About NutriCode opens modal bottom sheet with details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );

      // Tap About NutriCode
      await tester.tap(find.text('About NutriCode'));
      await tester.pumpAndSettle();

      // Verify About modal content
      expect(find.text('v3.0.0'), findsOneWidget);
      expect(find.text('Faculty of Engineering, University of Porto (FEUP)'), findsOneWidget);
      expect(find.text('Software Engineering — Group T2'), findsOneWidget);
      expect(find.text('2025 / 2026'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
      expect(find.text('Open Food Facts'), findsOneWidget);
    });

    testWidgets('tapping Privacy Policy navigates to PrivacyPolicyScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );

      // Tap Privacy Policy
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Verify we navigated to the PrivacyPolicyScreen
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text('Your privacy matters'), findsOneWidget);
    });
  });
}
