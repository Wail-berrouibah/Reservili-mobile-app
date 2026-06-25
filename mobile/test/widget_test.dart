import 'package:flutter_test/flutter_test.dart';
import 'package:reservili/app.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Reservili'), findsOneWidget);
  });
}
