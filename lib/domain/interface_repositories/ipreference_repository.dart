import 'package:mamgo/domain/entities/user_preference_entity.dart';

abstract class IPreferenceRepository {
  Future<UserPreference?> load(String email);
  Future<void> save(UserPreference preference, String email);
  Future<bool> isOnboardingDone(String email);
}
