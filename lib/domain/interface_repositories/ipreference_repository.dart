import 'package:mamgo/data/models/user_preference.dart';

abstract class IPreferenceRepository {
  Future<UserPreference?> load();
  Future<void> save(UserPreference preference);
  Future<bool> isOnboardingDone();
}
