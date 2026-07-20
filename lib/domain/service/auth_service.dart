import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/data/models/user_account.dart';
export 'package:mamgo/domain/entities/user_account_entity.dart';
export 'package:mamgo/data/models/user_account.dart';

/// Xử lý xác thực người dùng (validation + lưu trữ cục bộ bằng SharedPreferences).
class AuthService {
  static const _accountsKey = 'auth_accounts';
  static const _sessionKey = 'auth_session_email';
  static const _rememberedEmailKey = 'auth_remembered_email';

  Future<List<UserAccountModel>> _loadAccounts() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => UserAccountModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _saveAccounts(List<UserAccountModel> accounts) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _accountsKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<RegisterResult> register(
    String name,
    String email,
    String password,
  ) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      return const RegisterResult.error('Họ tên không được để trống!');
    }
    if (cleanName.length < 2) {
      return const RegisterResult.error('Họ tên phải có ít nhất 2 ký tự!');
    }
    if (cleanEmail.isEmpty) {
      return const RegisterResult.error('Email không được để trống!');
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return const RegisterResult.error('Email không đúng định dạng!');
    }
    if (password.isEmpty) {
      return const RegisterResult.error('Mật khẩu không được để trống!');
    }
    if (password.length < 6) {
      return const RegisterResult.error('Mật khẩu phải có ít nhất 6 ký tự!');
    }

    // --- Lưu tài khoản ---
    final accounts = await _loadAccounts();
    final normalized = cleanEmail.toLowerCase();
    if (accounts.any((a) => a.email == normalized)) {
      return const RegisterResult.error('Email này đã được đăng ký!');
    }
    accounts.add(
      UserAccountModel(name: cleanName, email: normalized, password: password),
    );
    await _saveAccounts(accounts);
    return const RegisterResult.success();
  }

  Future<LoginResult> login(String email, String password) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return const LoginResult.error('Email không được để trống!');
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return const LoginResult.error('Email không đúng định dạng!');
    }
    if (password.isEmpty) {
      return const LoginResult.error('Mật khẩu không được để trống!');
    }
    if (password.length < 6) {
      return const LoginResult.error('Mật khẩu phải có ít nhất 6 ký tự!');
    }

    // --- Truy vấn tài khoản ---
    final accounts = await _loadAccounts();
    final normalized = cleanEmail.toLowerCase();
    for (final a in accounts) {
      if (a.email == normalized && a.password == password) {
        return LoginResult.success(a);
      }
    }
    return const LoginResult.error('Email hoặc mật khẩu không đúng!');
  }

  Future<void> saveSession(String email) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_sessionKey, email);
  }

  Future<UserAccountModel?> currentUser() async {
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

/// Kết quả đăng nhập.
class LoginResult {
  final UserAccount? user;
  final String? errorMessage;
  final bool isSuccess;

  const LoginResult.success(this.user) : errorMessage = null, isSuccess = true;

  const LoginResult.error(this.errorMessage) : user = null, isSuccess = false;
}

/// Kết quả đăng ký.
class RegisterResult {
  final String? errorMessage;
  final bool isSuccess;

  const RegisterResult.success() : errorMessage = null, isSuccess = true;

  const RegisterResult.error(this.errorMessage) : isSuccess = false;
}
