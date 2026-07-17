import 'package:flutter/material.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/domain/usecases/load_user_preference_usecase.dart';
import 'package:mamgo/domain/usecases/save_user_preference_usecase.dart';
import 'package:mamgo/data/repositories/preference_repository_impl.dart';
import 'package:mamgo/data/datasources/notification_service.dart';

class UserPreferenceProvider extends ChangeNotifier {
  final LoadUserPreferenceUseCase _loadUseCase;
  final SaveUserPreferenceUseCase _saveUseCase;
  UserPreference? _pref;
  bool _loading = true;

  UserPreferenceProvider({
    LoadUserPreferenceUseCase? loadUseCase,
    SaveUserPreferenceUseCase? saveUseCase,
  })  : _loadUseCase =
            loadUseCase ?? LoadUserPreferenceUseCase(PreferenceRepositoryImpl()),
        _saveUseCase =
            saveUseCase ?? SaveUserPreferenceUseCase(PreferenceRepositoryImpl());

  UserPreference? get preference => _pref;
  bool get isLoading => _loading;
  bool get hasPreference => _pref != null;

  Future<void> load(String email) async {
    _loading = true;
    notifyListeners();
    _pref = await _loadUseCase.execute(email);
    _loading = false;
    notifyListeners();
  }

  Future<String?> save(UserPreference pref, String email) async {
    final result = await _saveUseCase.execute(pref, email);
    if (!result.isSuccess) return result.errorMessage;
    _pref = pref;
    await _syncNotifications();
    notifyListeners();
    return null;
  }

  Future<void> clear() async {
    await NotificationService().cancelAll();
    _pref = null;
    _loading = true;
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
        payload: 'meal_breakfast',
      );
    }
    if (p.lunchReminder) {
      final parts = p.lunchTime.split(':');
      await notif.scheduleMeal(
        id: 2,
        mealLabel: 'bữa trưa',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        payload: 'meal_lunch',
      );
    }
    if (p.dinnerReminder) {
      final parts = p.dinnerTime.split(':');
      await notif.scheduleMeal(
        id: 3,
        mealLabel: 'bữa tối',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        payload: 'meal_dinner',
      );
    }
  }
}
