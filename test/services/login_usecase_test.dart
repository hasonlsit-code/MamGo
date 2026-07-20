import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/domain/service/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> seedAccount({
    String name = 'Nguyễn Văn A',
    String email = 'test@example.com',
    String password = 'password123',
  }) async {
    final authService = AuthService();
    await authService.register(name, email, password);
  }

  group('Login - Validation email', () {
    test('trả về lỗi khi email rỗng', () async {
      final authService = AuthService();
      final result = await authService.login('', 'password123');

      expect(result.errorMessage, 'Email không được để trống!');
    });

    test('trả về lỗi khi email chỉ có khoảng trắng', () async {
      final authService = AuthService();
      final result = await authService.login('   ', 'password123');

      expect(result.errorMessage, 'Email không được để trống!');
    });

    test('trả về lỗi khi email không chứa @', () async {
      final authService = AuthService();
      final result = await authService.login('testexample.com', 'password123');

      expect(result.errorMessage, 'Email không đúng định dạng!');
    });

    test('trả về lỗi khi email không chứa dấu chấm', () async {
      final authService = AuthService();
      final result = await authService.login('test@examplecom', 'password123');

      expect(result.errorMessage, 'Email không đúng định dạng!');
    });
  });

  group('Login - Validation mật khẩu', () {
    test('trả về lỗi khi mật khẩu rỗng', () async {
      final authService = AuthService();
      final result = await authService.login('test@example.com', '');

      expect(result.errorMessage, 'Mật khẩu không được để trống!');
    });

    test('trả về lỗi khi mật khẩu dưới 6 ký tự', () async {
      final authService = AuthService();
      final result = await authService.login('test@example.com', '12345');

      expect(result.errorMessage, 'Mật khẩu phải có ít nhất 6 ký tự!');
    });

    test('mật khẩu đúng 6 ký tự thì không lỗi validation', () async {
      await seedAccount(email: 'six@test.com', password: '123456');
      final authService = AuthService();
      final result = await authService.login('six@test.com', '123456');
      expect(result.isSuccess, isTrue);
    });
  });

  group('Login - Đăng nhập thành công', () {
    test('đăng nhập thành công với thông tin đúng', () async {
      await seedAccount();
      final authService = AuthService();
      final result = await authService.login('test@example.com', 'password123');

      expect(result.user!.email, 'test@example.com');
      expect(result.user!.name, 'Nguyễn Văn A');
    });

    test('email có khoảng trắng thừa vẫn đăng nhập được', () async {
      await seedAccount();
      final authService = AuthService();
      final result = await authService.login(
        '  test@example.com  ',
        'password123',
      );
      expect(result.user, isNotNull);
    });
  });

  group('Login - Đăng nhập thất bại', () {
    test('trả về lỗi khi mật khẩu sai', () async {
      await seedAccount();
      final authService = AuthService();
      final result = await authService.login(
        'test@example.com',
        'wrongpassword',
      );

      expect(result.errorMessage, 'Email hoặc mật khẩu không đúng!');
    });

    test('trả về lỗi khi email không tồn tại', () async {
      await seedAccount();
      final authService = AuthService();
      final result = await authService.login(
        'notexist@example.com',
        'password123',
      );

      expect(result.errorMessage, 'Email hoặc mật khẩu không đúng!');
    });
  });
}
