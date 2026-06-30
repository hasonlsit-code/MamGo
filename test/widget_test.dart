import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamgo/main.dart';

void main() {
  testWidgets('MamGo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MamGoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
