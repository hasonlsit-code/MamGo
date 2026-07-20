import 'package:mamgo/domain/interface_repositories/iauth_repository.dart';
import 'package:mamgo/domain/service/auth_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final _service = AuthService();

  @override
  Future<LoginResult> login(String email, String password) =>
      _service.login(email, password);

  @override
  Future<RegisterResult> register(String name, String email, String password) =>
      _service.register(name, email, password);

  @override
  Future<UserAccount?> currentUser() => _service.currentUser();

  @override
  Future<void> logout() => _service.logout();

  @override
  Future<void> saveSession(String email) => _service.saveSession(email);

  @override
  Future<void> setRememberedEmail(String? email) =>
      _service.setRememberedEmail(email);

  @override
  Future<String?> rememberedEmail() => _service.rememberedEmail();
}
