import 'package:flutter_test/flutter_test.dart';
import 'package:dataf1/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const DataF1App());
    expect(find.byType(DataF1App), findsOneWidget);
  });
}
