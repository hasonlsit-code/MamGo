import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';
import 'package:mamgo/data/datasources/preference_service.dart';
import 'package:mamgo/data/models/user_preference.dart';

class PreferenceRepositoryImpl implements IPreferenceRepository {
  final _service = PreferenceService();

  @override
  Future<UserPreference?> load(String email) => _service.load(email);

  @override
  Future<void> save(UserPreference preference, String email) async {
    final model = preference is UserPreferenceModel
        ? preference
        : UserPreferenceModel(
            name: preference.name,
            tastePreferences: preference.tastePreferences,
            dietaryRestrictions: preference.dietaryRestrictions,
            favoriteCuisines: preference.favoriteCuisines,
            breakfastReminder: preference.breakfastReminder,
            lunchReminder: preference.lunchReminder,
            dinnerReminder: preference.dinnerReminder,
            breakfastTime: preference.breakfastTime,
            lunchTime: preference.lunchTime,
            dinnerTime: preference.dinnerTime,
          );
    await _service.save(model, email);
  }

  @override
  Future<bool> isOnboardingDone(String email) =>
      _service.isOnboardingDone(email);
}
