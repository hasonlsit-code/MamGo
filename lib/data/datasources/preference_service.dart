import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/data/models/user_preference.dart';

class PreferenceService {
  static const _onboardingKey = 'onboarding_done';

  Future<bool> isOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboardingKey) ?? false;
  }

  Future<void> save(UserPreference pref) async {
    final p = await SharedPreferences.getInstance();
    final map = pref.toMap();
    for (final e in map.entries) {
      if (e.value is String) await p.setString(e.key, e.value as String);
      if (e.value is bool) await p.setBool(e.key, e.value as bool);
    }
    await p.setBool(_onboardingKey, true);
  }

  Future<UserPreference?> load() async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool(_onboardingKey) ?? false)) return null;
    return UserPreference.fromMap({
      'name': p.getString('name') ?? '',
      'tastePreferences': p.getString('tastePreferences') ?? '',
      'dietaryRestrictions': p.getString('dietaryRestrictions') ?? '',
      'favoriteCuisines': p.getString('favoriteCuisines') ?? '',
      'breakfastReminder': p.getBool('breakfastReminder') ?? false,
      'lunchReminder': p.getBool('lunchReminder') ?? false,
      'dinnerReminder': p.getBool('dinnerReminder') ?? false,
      'breakfastTime': p.getString('breakfastTime') ?? '07:00',
      'lunchTime': p.getString('lunchTime') ?? '12:00',
      'dinnerTime': p.getString('dinnerTime') ?? '18:30',
    });
  }
}
