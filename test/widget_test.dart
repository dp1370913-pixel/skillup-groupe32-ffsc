import 'package:flutter_test/flutter_test.dart';

import 'package:skillup/main.dart';

void main() {
  testWidgets('App builds and shows home title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SkillUp — Groupe 32'), findsOneWidget);
  });
}
