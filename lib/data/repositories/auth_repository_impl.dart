import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/interface_repositories/iauth_repository.dart';
import 'package:mamgo/data/datasources/auth_service.dart';
import 'package:mamgo/data/models/user_account.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final _service = AuthService();

  @override
  Future<UserAccount?> login(String email, String password) =>
      _service.login(email, password);

  @override
  Future<String?> register(UserAccount account) {
    final model = account is UserAccountModel
        ? account
        : UserAccountModel(
            name: account.name,
            email: account.email,
            password: account.password,
          );
    return _service.register(model);
  }

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
