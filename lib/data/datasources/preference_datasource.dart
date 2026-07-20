import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/data/models/user_preference.dart';

class PreferenceDatasource {
  static const _onboardingKey = 'onboarding_done';

  String _getKey(String email, String key) {
    if (email.isEmpty) return key;
    return '${email}_$key';
  }

  Future<bool> isOnboardingDone(String email) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_getKey(email, _onboardingKey)) ?? false;
  }

  Future<void> save(UserPreferenceModel pref, String email) async {
    final p = await SharedPreferences.getInstance();
    final map = pref.toMap();
    for (final e in map.entries) {
      if (e.value is String) {
        await p.setString(_getKey(email, e.key), e.value as String);
      }
      if (e.value is bool) {
        await p.setBool(_getKey(email, e.key), e.value as bool);
      }
    }
    await p.setBool(_getKey(email, _onboardingKey), true);
  }

  Future<UserPreferenceModel?> load(String email) async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool(_getKey(email, _onboardingKey)) ?? false)) return null;
    return UserPreferenceModel.fromMap({
      'name': p.getString(_getKey(email, 'name')) ?? '',
      'tastePreferences': p.getString(_getKey(email, 'tastePreferences')) ?? '',
      'dietaryRestrictions':
          p.getString(_getKey(email, 'dietaryRestrictions')) ?? '',
      'favoriteCuisines': p.getString(_getKey(email, 'favoriteCuisines')) ?? '',
      'breakfastReminder':
          p.getBool(_getKey(email, 'breakfastReminder')) ?? false,
      'lunchReminder': p.getBool(_getKey(email, 'lunchReminder')) ?? false,
      'dinnerReminder': p.getBool(_getKey(email, 'dinnerReminder')) ?? false,
      'breakfastTime': p.getString(_getKey(email, 'breakfastTime')) ?? '07:00',
      'lunchTime': p.getString(_getKey(email, 'lunchTime')) ?? '12:00',
      'dinnerTime': p.getString(_getKey(email, 'dinnerTime')) ?? '18:30',
    });
  }
}
