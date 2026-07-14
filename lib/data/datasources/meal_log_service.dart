import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/data/models/meal_log_entry.dart';

/// Lưu/đọc nhật ký các bữa ăn đã phân tích (SharedPreferences, key 'saved_meals').
class MealLogService {
  static const _key = 'saved_meals';

  static Future<List<MealLogEntry>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    final entries = list
        .map((e) => MealLogEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    entries.sort((a, b) => b.time.compareTo(a.time));
    return entries;
  }

  static Future<void> add(MealLogEntry entry) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    final list =
        raw == null || raw.isEmpty ? <dynamic>[] : (jsonDecode(raw) as List);
    list.add(entry.toJson());
    await p.setString(_key, jsonEncode(list));
  }

  /// Xoá theo mốc thời gian lưu (định danh duy nhất trong thực tế sử dụng).
  static Future<void> deleteAt(DateTime time) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List;
    list.removeWhere((e) => e['time'] == time.toIso8601String());
    await p.setString(_key, jsonEncode(list));
  }
}
