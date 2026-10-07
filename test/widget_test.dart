import 'package:flutter_test/flutter_test.dart';

import 'package:birdcount/main.dart';

void main() {
  testWidgets('BirdCount app renders splash', (WidgetTester tester) async {
    await tester.pumpWidget(const BirdCountApp());

    expect(find.text('BirdCount'), findsOneWidget);
    expect(find.text('YOLO Bird Detection'), findsOneWidget);
  });
}
