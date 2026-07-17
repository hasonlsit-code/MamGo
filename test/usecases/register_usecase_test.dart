import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/domain/service/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Register - Validation họ tên', () {
    test('trả về lỗi khi tên rỗng', () async {
      final authService = AuthService();
      final result = await authService.register(
        '',
        'test@example.com',
        'password123',
      );

      expect(result.errorMessage, 'Họ tên không được để trống!');
    });

    test('trả về lỗi khi tên chỉ có khoảng trắng', () async {
      final authService = AuthService();
      final result = await authService.register(
        '   ',
        'test@example.com',
        'password123',
      );

      expect(result.errorMessage, 'Họ tên không được để trống!');
    });

    test('trả về lỗi khi tên chỉ có 1 ký tự', () async {
      final authService = AuthService();
      final result = await authService.register(
        'A',
        'test@example.com',
        'password123',
      );

      expect(result.errorMessage, 'Họ tên phải có ít nhất 2 ký tự!');
    });

    test('tên đúng 2 ký tự thì hợp lệ', () async {
      final authService = AuthService();
      final result = await authService.register(
        'AB',
        'test@example.com',
        'password123',
      );

      expect(result.isSuccess, isTrue);
    });
  });

  group('Register - Validation email', () {
    test('trả về lỗi khi email rỗng', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        '',
        'password123',
      );

      expect(result.errorMessage, 'Email không được để trống!');
    });

    test('trả về lỗi khi email chỉ có khoảng trắng', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        '   ',
        'password123',
      );

      expect(result.errorMessage, 'Email không được để trống!');
    });

    test('trả về lỗi khi email không chứa @', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'testexample.com',
        'password123',
      );

      expect(result.errorMessage, 'Email không đúng định dạng!');
    });

    test('trả về lỗi khi email không chứa dấu chấm', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'test@examplecom',
        'password123',
      );

      expect(result.errorMessage, 'Email không đúng định dạng!');
    });
  });

  group('Register - Validation mật khẩu', () {
    test('trả về lỗi khi mật khẩu rỗng', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        '',
      );

      expect(result.errorMessage, 'Mật khẩu không được để trống!');
    });

    test('trả về lỗi khi mật khẩu dưới 6 ký tự', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        '12345',
      );

      expect(result.errorMessage, 'Mật khẩu phải có ít nhất 6 ký tự!');
    });

    test('mật khẩu đúng 6 ký tự thì hợp lệ', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        '123456',
      );

      expect(result.isSuccess, isTrue);
    });
  });

  group('Register - Đăng ký thành công', () {
    test('đăng ký thành công với thông tin hợp lệ', () async {
      final authService = AuthService();
      final result = await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        'password123',
      );

      expect(result.errorMessage, isNull);
    });

    test('sau khi đăng ký, có thể login với tài khoản vừa tạo', () async {
      final authService = AuthService();
      await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        'password123',
      );

      final loginResult = await authService.login(
        'test@example.com',
        'password123',
      );

      expect(loginResult.user!.email, 'test@example.com');
      expect(loginResult.user!.name, 'Nguyễn Văn A');
    });

    test('tên và email được trim khoảng trắng', () async {
      final authService = AuthService();
      await authService.register(
        '  Nguyễn Văn B  ',
        '  user@example.com  ',
        'password123',
      );

      final loginResult = await authService.login(
        'user@example.com',
        'password123',
      );

      expect(loginResult.user!.name, 'Nguyễn Văn B');
      expect(loginResult.user!.email, 'user@example.com');
    });
  });

  group('Register - Đăng ký thất bại', () {
    test('trả về lỗi khi email đã tồn tại', () async {
      final authService = AuthService();

      // Đăng ký lần 1 - thành công
      final first = await authService.register(
        'Nguyễn Văn A',
        'test@example.com',
        'password123',
      );
      expect(first.isSuccess, isTrue);

      // Đăng ký lần 2 cùng email - thất bại
      final second = await authService.register(
        'Nguyễn Văn B',
        'test@example.com',
        'password456',
      );

      expect(second.isSuccess, isFalse);
      expect(second.errorMessage, 'Email này đã được đăng ký!');
    });
  });
}
