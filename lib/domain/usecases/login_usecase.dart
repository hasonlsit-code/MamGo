import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/interface_repositories/iauth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResult> execute(String email, String password) async {
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

    final user = await repository.login(cleanEmail, password);
    if (user == null) {
      return const LoginResult.error('Email hoặc mật khẩu không đúng!');
    }

    return LoginResult.success(user);
  }
}

class LoginResult {
  final UserAccount? user;
  final String? errorMessage;
  final bool isSuccess;

  const LoginResult.success(this.user)
      : errorMessage = null,
        isSuccess = true;

  const LoginResult.error(this.errorMessage)
      : user = null,
        isSuccess = false;
}
