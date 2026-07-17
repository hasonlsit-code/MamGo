import 'package:mamgo/domain/entities/user_account_entity.dart';

abstract class IAuthRepository {
  Future<UserAccount?> login(String email, String password);
  Future<String?> register(UserAccount account);
  Future<UserAccount?> currentUser();
  Future<void> logout();
  Future<void> saveSession(String email);
  Future<void> setRememberedEmail(String? email);
  Future<String?> rememberedEmail();
}
