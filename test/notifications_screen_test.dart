import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/presentation/pages/notifications_screen.dart';

void main() {
  group('NotificationsScreen Widget Tests', () {
    testWidgets('Hiển thị thông báo trống khi không có dữ liệu', (tester) async {
      SharedPreferences.setMockInitialValues({'notification_log': '[]'});
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Chưa có thông báo nào'), findsOneWidget);
    });

    testWidgets('Hiển thị danh sách thông báo đã lưu', (tester) async {
      final now = DateTime.now();
      final mockData = [
        {
          'emoji': '🌅',
          'title': 'Đã đặt lịch nhắc bữa sáng',
          'body': 'Lúc 07:00 — còn 10 phút nữa sẽ đến bữa sáng',
          'time': now.toIso8601String(),
        },
        {
          'emoji': '☀️',
          'title': 'Đã đặt lịch nhắc bữa trưa',
          'body': 'Lúc 12:00',
          'time': now.subtract(const Duration(days: 1)).toIso8601String(),
        }
      ];
      SharedPreferences.setMockInitialValues({
        'notification_log': jsonEncode(mockData)
      });
      
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Đã đặt lịch nhắc bữa sáng'), findsOneWidget);
      expect(find.text('Hôm nay'), findsOneWidget); // Header ngày cho now()
      
      expect(find.text('Đã đặt lịch nhắc bữa trưa'), findsOneWidget);
      expect(find.text('Hôm qua'), findsOneWidget); // Header ngày cho now() - 1 ngày
    });
  });
}
