import 'package:mamgo/domain/service/auth_service.dart';

abstract class IAuthRepository {
  Future<LoginResult> login(String email, String password);
  Future<RegisterResult> register(String name, String email, String password);
  Future<UserAccount?> currentUser();
  Future<void> logout();
  Future<void> saveSession(String email);
  Future<void> setRememberedEmail(String? email);
  Future<String?> rememberedEmail();
}

