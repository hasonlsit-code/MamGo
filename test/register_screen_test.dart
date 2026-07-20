import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/register_screen.dart';
import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';
import 'package:mamgo/presentation/viewmodels/bot_settings_provider.dart';

class MockBotSettingsProvider extends ChangeNotifier implements BotSettingsProvider {
  @override bool get enabled => false;
  @override Future<void> setEnabled(bool value) async {}
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  Future<String?> register(String name, String email, String password) async {
    if (email == 'student@example.com' && password == '123456')
      return null; // Success
    return 'Email already exists'; // Failure
  }

  @override
  UserAccount? get user => null;
  @override
  bool get isLoggedIn => false;
  @override
  Future<void> loadSession() async {}
  @override
  Future<String?> login(
    String email,
    String password, {
    bool remember = true,
  }) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<String?> rememberedEmail() async => null;
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

Future<void> pumpRegisterApp(WidgetTester tester) async {
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
      child: const MaterialApp(home: RegisterScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> registerSuccessfully(WidgetTester tester) async {
  await pumpRegisterApp(tester);

  await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen Van A');

  await tester.enterText(
    find.byKey(const Key('emailField')),
    'student@example.com',
  );

  await tester.enterText(find.byKey(const Key('passwordField')), '123456');

  await tester.enterText(
    find.byKey(const Key('confirmPasswordField')),
    '123456',
  );

  await tester.tap(find.byKey(const Key('registerButton')));

  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('Register screen displays fields and button', (tester) async {
      await pumpRegisterApp(tester);

      expect(find.byKey(const Key('nameField')), findsOneWidget);
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);
      expect(find.byKey(const Key('registerButton')), findsOneWidget);
    });

    testWidgets('Show validation messages when fields are empty', (
      tester,
    ) async {
      await pumpRegisterApp(tester);

      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      expect(find.text('Vui lòng nhập tên của bạn!'), findsOneWidget);
    });

    testWidgets('Show invalid email message', (tester) async {
      await pumpRegisterApp(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen');
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'wrong-email',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        '123456',
      );

      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      expect(find.text('Email không hợp lệ!'), findsOneWidget);
    });

    testWidgets('Show password mismatch message', (tester) async {
      await pumpRegisterApp(tester);

      await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen');
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        '654321',
      );

      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pump();

      expect(find.text('Mật khẩu nhập lại không khớp!'), findsOneWidget);
    });

    testWidgets('Navigate to HomeScreen after successful register', (
      tester,
    ) async {
      await registerSuccessfully(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
