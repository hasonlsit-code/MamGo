import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';

class LoadUserPreferenceUseCase {
  final IPreferenceRepository repository;

  LoadUserPreferenceUseCase(this.repository);

  Future<UserPreference?> execute(String email) {
    return repository.load(email);
  }
}
