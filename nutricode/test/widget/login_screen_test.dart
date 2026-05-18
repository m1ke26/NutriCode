import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/screens/login_screen.dart';
import 'package:NutriCode/services/auth_service.dart';
import '../mock_helper.dart';

void main() {
  group('LoginScreen & RegisterScreen Widget Tests', () {
    late MockAuthService mockAuth;

    setUp(() {
      mockAuth = MockAuthService();
    });

    Widget buildTestableLoginScreen({VoidCallback? onBack}) {
      return Provider<AuthService>.value(
        value: mockAuth,
        child: MaterialApp(
          home: LoginScreen(onBack: onBack ?? () {}),
        ),
      );
    }

    testWidgets('renders all login controls and toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      // Verify header logo and text are present
      expect(find.text('NutriCode'), findsOneWidget);
      expect(find.text('Scan. Know. Choose.'), findsOneWidget);

      // Verify email and password text fields are present
      expect(find.widgetWithText(TextField, 'Email or Username'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

      // Verify login and Google sign in buttons exist
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Verify register prompt is visible
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Verify password obscure by checking the suffix icon toggles
      final visibilityOffFinder = find.byIcon(Icons.visibility_off);
      expect(visibilityOffFinder, findsOneWidget);

      await tester.tap(visibilityOffFinder);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows validation snackbar if fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      // Tap Login with empty fields
      final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginBtnFinder);
      await tester.tap(loginBtnFinder);
      await tester.pump();

      // Check if validation snackbar appears
      expect(find.text('Please enter both your details'), findsOneWidget);
    });

    testWidgets('navigates to RegisterScreen and validates registration form', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      // Tap Register link to push RegisterScreen
      final registerFinder = find.text('Register');
      await tester.ensureVisible(registerFinder);
      await tester.tap(registerFinder);
      await tester.pumpAndSettle();

      // Verify RegisterScreen renders
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join NutriCode today'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Confirm Password'), findsOneWidget);

      // Tap Register button with empty fields
      final registerBtn = find.widgetWithText(ElevatedButton, 'Register');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsOneWidget);

      // Enter mismatched passwords
      final nameField = find.widgetWithText(TextField, 'Full Name');
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'john@example.com');

      final passField = find.widgetWithText(TextField, 'Password');
      await tester.ensureVisible(passField);
      await tester.enterText(passField, 'password123');

      final confirmField = find.widgetWithText(TextField, 'Confirm Password');
      await tester.ensureVisible(confirmField);
      await tester.enterText(confirmField, 'password999');
      await tester.pump();

      // Tap Register again
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pump();

      // Mismatched error should display
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
