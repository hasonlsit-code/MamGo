import 'package:mamgo/data/models/user_preference.dart';

abstract class IPreferenceRepository {
  Future<UserPreference?> load(String email);
  Future<void> save(UserPreference preference, String email);
  Future<bool> isOnboardingDone(String email);
}
