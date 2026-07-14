import 'package:mamgo/data/datasources/preference_service.dart';
import 'package:mamgo/data/models/user_preference.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';

class PreferenceRepositoryImpl implements IPreferenceRepository {
  final _service = PreferenceService();

  @override
  Future<UserPreference?> load(String email) => _service.load(email);

  @override
  Future<void> save(UserPreference preference, String email) => _service.save(preference, email);

  @override
  Future<bool> isOnboardingDone(String email) => _service.isOnboardingDone(email);
}
