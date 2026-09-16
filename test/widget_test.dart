import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tube_well/Screens/home_screen.dart';

void main() {
  testWidgets('home screen shows the greeting and user name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
  });
}
