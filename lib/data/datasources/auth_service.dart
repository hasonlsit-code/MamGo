import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/data/models/user_account.dart';

/// Lưu tài khoản người dùng cục bộ bằng SharedPreferences.
class AuthService {
  static const _accountsKey = 'auth_accounts';
  static const _sessionKey = 'auth_session_email';
  static const _rememberedEmailKey = 'auth_remembered_email';

  Future<List<UserAccount>> _loadAccounts() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => UserAccount.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _saveAccounts(List<UserAccount> accounts) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _accountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  /// Đăng ký tài khoản mới. Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> register(UserAccount account) async {
    final accounts = await _loadAccounts();
    final email = account.email.trim().toLowerCase();
    if (accounts.any((a) => a.email == email)) {
      return 'Email này đã được đăng ký!';
    }
    accounts.add(UserAccount(
      name: account.name.trim(),
      email: email,
      password: account.password,
    ));
    await _saveAccounts(accounts);
    return null;
  }

  /// Đăng nhập. Trả về tài khoản nếu đúng, null nếu sai thông tin.
  Future<UserAccount?> login(String email, String password) async {
    final accounts = await _loadAccounts();
    final normalized = email.trim().toLowerCase();
    for (final a in accounts) {
      if (a.email == normalized && a.password == password) return a;
    }
    return null;
  }

  Future<void> saveSession(String email) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_sessionKey, email);
  }

  Future<UserAccount?> currentUser() async {
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_sessionKey);
    if (email == null || email.isEmpty) return null;
    final accounts = await _loadAccounts();
    for (final a in accounts) {
      if (a.email == email) return a;
    }
    return null;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_sessionKey);
  }

  Future<void> setRememberedEmail(String? email) async {
    final p = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await p.remove(_rememberedEmailKey);
    } else {
      await p.setString(_rememberedEmailKey, email);
    }
  }

  Future<String?> rememberedEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_rememberedEmailKey);
  }
}
