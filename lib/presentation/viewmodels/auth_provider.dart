import 'package:flutter/material.dart';
import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/interface_repositories/iauth_repository.dart';
import 'package:mamgo/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repo;
  UserAccount? _user;

  AuthProvider({
    IAuthRepository? repository,
  }) : _repo = repository ?? AuthRepositoryImpl();

  UserAccount? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> loadSession() async {
    _user = await _repo.currentUser();
    notifyListeners();
  }

  Future<String?> rememberedEmail() => _repo.rememberedEmail();

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    final result = await _repo.login(email, password);
    if (!result.isSuccess) return result.errorMessage;

    final account = result.user!;
    _user = account;
    await _repo.saveSession(account.email);
    await _repo.setRememberedEmail(remember ? account.email : null);
    notifyListeners();
    return null;
  }

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> register(String name, String email, String password) async {
    final result = await _repo.register(name, email, password);
    if (!result.isSuccess) return result.errorMessage;

    // Tự động đăng nhập sau khi đăng ký thành công
    final loginResult = await _repo.login(email, password);
    if (!loginResult.isSuccess) return loginResult.errorMessage;

    final account = loginResult.user!;
    _user = account;
    await _repo.saveSession(account.email);
    await _repo.setRememberedEmail(
      account.email,
    ); // Mặc định ghi nhớ sau khi đăng ký
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }
}
