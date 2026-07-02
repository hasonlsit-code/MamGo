import 'package:mamgo/data/datasources/preference_service.dart';
import 'package:mamgo/data/models/user_preference.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';

class PreferenceRepositoryImpl implements IPreferenceRepository {
  final _service = PreferenceService();

  @override
  Future<UserPreference?> load() => _service.load();

  @override
  Future<void> save(UserPreference preference) => _service.save(preference);

  @override
  Future<bool> isOnboardingDone() => _service.isOnboardingDone();
}
