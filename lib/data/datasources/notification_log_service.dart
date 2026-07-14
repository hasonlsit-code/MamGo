import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Một thông báo THẬT đã xảy ra, ghi đúng thời điểm theo đồng hồ máy lúc đó.
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

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
      };

  factory NotificationEntry.fromJson(Map<String, dynamic> json) =>
      NotificationEntry(
        emoji: json['emoji'] ?? '🔔',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      );
}

/// Nhật ký thông báo THẬT (không phải tính toán giả lập): mỗi khi một thông
/// báo thực sự xảy ra (nhắc trong app, mở từ hệ thống, hoặc xác nhận đặt lịch)
/// thì [log] được gọi và ghi đúng [DateTime.now()] tại thời điểm đó — luôn
/// khớp với đồng hồ đang hiển thị trên điện thoại.
class NotificationLogService {
  static const _key = 'notification_log';
  static const _maxEntries = 100;

  static Future<void> log({
    required String emoji,
    required String title,
    required String body,
    DateTime? time,
  }) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    final list = raw == null || raw.isEmpty ? <dynamic>[] : jsonDecode(raw) as List;
    list.add(NotificationEntry(
      emoji: emoji,
      title: title,
      body: body,
      time: time ?? DateTime.now(),
    ).toJson());
    final trimmed =
        list.length > _maxEntries ? list.sublist(list.length - _maxEntries) : list;
    await p.setString(_key, jsonEncode(trimmed));
  }

  static Future<List<NotificationEntry>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    final entries = list
        .map((e) => NotificationEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    entries.sort((a, b) => b.time.compareTo(a.time));
    return entries;
  }
}
