import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/welcome_screen.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders screen and CTA button', (WidgetTester tester) async {
      bool getStartedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(
            onGetStarted: () {
              getStartedTapped = true;
            },
          ),
        ),
      );

      // Verify the CTA button text is rendered
      expect(find.text('Get Started'), findsOneWidget);

      // Tap on the button
      await tester.tap(find.text('Get Started'));
      await tester.pump();

      // Verify the callback was triggered
      expect(getStartedTapped, isTrue);
    });
  });
}
