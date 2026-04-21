import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriCodeApp());
    expect(find.text('NutriCode'), findsOneWidget);
  });
}
