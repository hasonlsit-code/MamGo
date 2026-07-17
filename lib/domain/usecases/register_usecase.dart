import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/interface_repositories/iauth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<RegisterResult> execute(
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

    final account = UserAccount(
      name: cleanName,
      email: cleanEmail,
      password: password,
    );
    final error = await repository.register(account);
    if (error != null) {
      return RegisterResult.error(error);
    }

    return const RegisterResult.success();
  }
}

class RegisterResult {
  final String? errorMessage;
  final bool isSuccess;

  const RegisterResult.success()
      : errorMessage = null,
        isSuccess = true;

  const RegisterResult.error(this.errorMessage) : isSuccess = false;
}
