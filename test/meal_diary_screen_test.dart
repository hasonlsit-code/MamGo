import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/presentation/pages/meal_diary_screen.dart';

void main() {
  setUp(() {
    // Thiết lập dữ liệu mẫu vào SharedPreferences
    final now = DateTime.now();
    // Hôm nay
    final entry1 = {
      'time': now.toIso8601String(),
      'total_kcal': 450,
      'items': ['Phở bò', 'Trà đá'],
    };
    // Hôm qua
    final entry2 = {
      'time': now.subtract(const Duration(days: 1)).toIso8601String(),
      'total_kcal': 600,
      'items': ['Cơm tấm'],
    };

    SharedPreferences.setMockInitialValues({
      'flutter.saved_meals': jsonEncode([entry1, entry2]),
    });
  });

  Widget createTestWidget() {
    return const MaterialApp(home: MealDiaryScreen());
  }

  group('MealDiaryScreen Tests', () {
    testWidgets('Hiển thị danh sách nhật ký bữa ăn', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nhật ký bữa ăn'), findsOneWidget);

      expect(find.text('Calo tuần này'), findsOneWidget);

      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('Hôm qua'), findsOneWidget);

      expect(find.text('450 kcal'), findsOneWidget);
      expect(find.text('600 kcal'), findsOneWidget);
      expect(find.text('Phở bò, Trà đá'), findsOneWidget);
      expect(find.text('Cơm tấm'), findsOneWidget);
    });

    testWidgets('Xoá bữa ăn khỏi nhật ký', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final deleteBtns = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtns, findsNWidgets(2));

      await tester.tap(deleteBtns.first);
      await tester.pumpAndSettle();

      expect(find.text('Xoá bữa ăn'), findsOneWidget);
      expect(
        find.text('Bạn có chắc muốn xoá bữa ăn này khỏi nhật ký không?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();

      expect(find.text('450 kcal'), findsOneWidget);

      await tester.tap(deleteBtns.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xoá'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('450 kcal'), findsNothing);
      expect(find.text('600 kcal'), findsOneWidget);
      expect(find.text('Đã xoá bữa ăn khỏi nhật ký'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
