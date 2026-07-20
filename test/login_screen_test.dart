import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/login_screen.dart';
import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';
import 'package:mamgo/presentation/viewmodels/bot_settings_provider.dart';

class MockBotSettingsProvider extends ChangeNotifier
    implements BotSettingsProvider {
  @override
  bool get enabled => false;
  @override
  Future<void> setEnabled(bool value) async {}
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  String? rememberedEmailResult;

  @override
  Future<String?> rememberedEmail() async => rememberedEmailResult;

  @override
  Future<String?> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    if (email == 'student@example.com' && password == '123456')
      return null; // Success
    return 'Invalid email or password'; // Failure
  }

  @override
  UserAccount? get user => null;
  @override
  bool get isLoggedIn => false;
  @override
  Future<void> loadSession() async {}
  @override
  Future<String?> register(String name, String email, String password) async =>
      null;
  @override
  Future<void> logout() async {}
}

class MockUserPreferenceProvider extends ChangeNotifier
    implements UserPreferenceProvider {
  @override
  bool get hasPreference => true;
  @override
  Future<void> load(String email) async {}
  @override
  bool get isLoading => false;
  @override
  UserPreference? get preference => null;
  @override
  Future<String?> save(UserPreference pref, String email) async => null;
  @override
  Future<void> clear() async {}
}

// Bọc màn hình Login bằng các Provider giả lập để chạy test độc lập không cần Backend.
Future<void> pumpDemoApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider<UserPreferenceProvider>(
          create: (_) => MockUserPreferenceProvider(),
        ),
        ChangeNotifierProvider<BotSettingsProvider>(
          create: (_) => MockBotSettingsProvider(),
        ),
      ],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> loginSuccessfully(WidgetTester tester) async {
  await pumpDemoApp(tester);

  await tester.enterText(
    find.byKey(const Key('emailField')),
    'student@example.com',
  );

  await tester.enterText(find.byKey(const Key('passwordField')), '123456');

  await tester.tap(find.byKey(const Key('loginButton')));

  // Dùng pump thay vì pumpAndSettle vì HomeScreen có thể có hiệu ứng lặp vô tận
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Hiện thị màn Đăng nhập', (tester) async {
      await pumpDemoApp(tester);

      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('Hiển thị thông báo lỗi khi email và mật khẩu bị bỏ trống', (
      tester,
    ) async {
      await pumpDemoApp(tester);

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      expect(find.text('Vui lòng nhập email và mật khẩu!'), findsOneWidget);
    });

    testWidgets('Hiển thị thông báo lỗi khi sai mật khẩu và email', (
      tester,
    ) async {
      await pumpDemoApp(tester);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'wrong-email@example.com',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('Login thành công, điều hướng tới HomePage', (tester) async {
      await loginSuccessfully(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
