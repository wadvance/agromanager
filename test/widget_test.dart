import 'package:flutter_test/flutter_test.dart';
import 'package:agromanager/app.dart';

void main() {
  testWidgets('App loads dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroManagerApp());
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
  });
}
