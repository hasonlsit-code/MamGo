import 'package:flutter/material.dart';
import 'package:mamgo/data/models/user_preference.dart';
import 'package:mamgo/data/datasources/preference_service.dart';
import 'package:mamgo/data/datasources/notification_service.dart';

class UserPreferenceProvider extends ChangeNotifier {
  final _svc = PreferenceService();
  UserPreference? _pref;
  bool _loading = true;

  UserPreference? get preference => _pref;
  bool get isLoading => _loading;
  bool get hasPreference => _pref != null;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _pref = await _svc.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(UserPreference pref) async {
    await _svc.save(pref);
    _pref = pref;
    await _syncNotifications();
    notifyListeners();
  }

  Future<void> _syncNotifications() async {
    final notif = NotificationService();
    await notif.cancelAll();
    final p = _pref;
    if (p == null) return;

    // Chúc buổi sáng hằng ngày trên điện thoại
    await notif.scheduleMorningGreeting();

    if (p.breakfastReminder) {
      final parts = p.breakfastTime.split(':');
      await notif.scheduleMeal(
        id: 1,
        mealLabel: 'bữa sáng',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (p.lunchReminder) {
      final parts = p.lunchTime.split(':');
      await notif.scheduleMeal(
        id: 2,
        mealLabel: 'bữa trưa',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (p.dinnerReminder) {
      final parts = p.dinnerTime.split(':');
      await notif.scheduleMeal(
        id: 3,
        mealLabel: 'bữa tối',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }
}
