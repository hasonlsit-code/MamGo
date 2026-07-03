import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/main.dart';

void main() {
  testWidgets('MamGo app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MamGoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    // Cho timer chuyển màn của splash chạy xong để không còn pending timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
