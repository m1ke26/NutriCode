import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/main.dart';
import 'mock_helper.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const NutriCodeApp()));
    
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
  });
}
