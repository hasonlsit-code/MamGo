import 'package:mamgo/data/models/user_preference.dart';

/// Một mục thông báo hiển thị trong trung tâm thông báo.
class NotificationEntry {
  final String emoji;
  final String title;
  final String body;
  final DateTime time;

  const NotificationEntry({
    required this.emoji,
    required this.title,
    required this.body,
    required this.time,
  });
}

/// Dựng dòng thời gian thông báo đã gửi dựa trên cài đặt nhắc nhở
/// (khớp với các thông báo đã lên lịch trên điện thoại).
class NotificationLogService {
  static const morningHour = 6;
  static const morningMinute = 30;

  /// Các thông báo đã phát trong [days] ngày gần nhất, mới nhất trước.
  static List<NotificationEntry> buildTimeline(
    UserPreference? pref, {
    int days = 3,
  }) {
    final now = DateTime.now();
    final entries = <NotificationEntry>[];

    for (int d = 0; d < days; d++) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: d));

      void add(String emoji, String title, String body, int h, int m) {
        final t = DateTime(day.year, day.month, day.day, h, m);
        if (t.isBefore(now)) {
          entries.add(NotificationEntry(
              emoji: emoji, title: title, body: body, time: t));
        }
      }

      add(
        '☀️',
        'Chào buổi sáng!',
        'Chúc bạn một ngày tốt lành! Nhớ ăn uống đầy đủ để khỏe mạnh nhé 🍀',
        morningHour,
        morningMinute,
      );

      if (pref != null) {
        void addMeal(bool on, String time, String label) {
          if (!on) return;
          final parts = time.split(':');
          add(
            '🍽️',
            'Đến giờ $label rồi!',
            'MămGo có nhiều gợi ý ngon cho bạn hôm nay! 😋',
            int.tryParse(parts[0]) ?? 0,
            parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
          );
        }

        addMeal(pref.breakfastReminder, pref.breakfastTime, 'ăn sáng');
        addMeal(pref.lunchReminder, pref.lunchTime, 'ăn trưa');
        addMeal(pref.dinnerReminder, pref.dinnerTime, 'ăn tối');
      }
    }

    entries.sort((a, b) => b.time.compareTo(a.time));
    return entries;
  }
}
