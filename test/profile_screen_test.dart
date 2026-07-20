import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/presentation/pages/profile_screen.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/bot_settings_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/presentation/pages/login_screen.dart';
import 'package:mamgo/presentation/pages/onboarding_screen.dart';
import 'package:mamgo/presentation/pages/notification_settings_screen.dart';

// -- MOCK CLASSES --

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserAccount? get user => const UserAccount(
    name: 'Người Dùng Test',
    email: 'test@example.com',
    password: '',
  );

  bool isLoggedOut = false;

  @override
  Future<void> logout() async {
    isLoggedOut = true;
  }

  @override
  bool get isLoggedIn => true;
  @override
  Future<String?> rememberedEmail() async => null;
  @override
  Future<String?> login(
    String email,
    String password, {
    bool remember = true,
  }) async => null;
  @override
  Future<void> loadSession() async {}
  @override
  Future<String?> register(String name, String email, String password) async =>
      null;
}

class MockUserPreferenceProvider extends ChangeNotifier
    implements UserPreferenceProvider {
  bool isCleared = false;

  @override
  UserPreference? get preference => const UserPreference(
    name: 'Người Dùng Test',
    tastePreferences: ['Mặn', 'Ngọt'],
    dietaryRestrictions: ['Ăn chay'],
    favoriteCuisines: ['Việt Nam'],
  );

  @override
  Future<void> clear() async {
    isCleared = true;
  }

  @override
  bool get hasPreference => true;
  @override
  Future<void> load(String email) async {}
  @override
  bool get isLoading => false;
  @override
  Future<String?> save(UserPreference pref, String email) async => null;
}

class MockBotSettingsProvider extends ChangeNotifier
    implements BotSettingsProvider {
  bool _enabled = true;

  @override
  bool get enabled => _enabled;

  @override
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
  }
}

void main() {
  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider<UserPreferenceProvider>(
          create: (_) => MockUserPreferenceProvider(),
        ),
        ChangeNotifierProvider<BotSettingsProvider>(
          create: (_) => MockBotSettingsProvider(),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('Hiển thị thông tin người dùng và sở thích cơ bản', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Kiểm tra Avatar / Tên / Email
      expect(find.text('Người Dùng Test'), findsWidgets);
      expect(find.text('test@example.com'), findsOneWidget);

      // Kiểm tra hiển thị sở thích
      expect(find.text('Mặn, Ngọt'), findsOneWidget);
      expect(find.text('Ăn chay'), findsOneWidget);
      expect(find.text('Việt Nam'), findsOneWidget);
    });

    testWidgets('Nút Cập nhật sở thích điều hướng sang OnboardingScreen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final btn = find.text('Cập nhật sở thích');
      await tester.ensureVisible(btn);
      await tester.tap(btn);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets(
      'Nút Điều chỉnh nhắc nhở điều hướng sang NotificationSettingsScreen',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final btn = find.text('Điều chỉnh nhắc nhở');
        await tester.ensureVisible(btn);
        await tester.tap(btn);

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(NotificationSettingsScreen), findsOneWidget);
      },
    );

    testWidgets('Bật/tắt MamGo Bot Switch', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tìm Switch
      final switchFinder = find.byType(Switch);
      await tester.ensureVisible(switchFinder);
      expect(switchFinder, findsOneWidget);

      var switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, true);

      // Bấm vào Switch để tắt
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, false);
    });

    testWidgets('Mở dialog Đăng xuất và chọn Hủy', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Cuộn xuống để thấy nút Đăng xuất
      final logoutBtn = find.text('Đăng xuất').last;
      await tester.ensureVisible(logoutBtn);

      // Bấm đăng xuất
      await tester.tap(logoutBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Xác nhận dialog xuất hiện
      expect(
        find.text('Bạn có chắc muốn đăng xuất khỏi MamGo?'),
        findsOneWidget,
      );

      // Bấm hủy
      await tester.tap(find.text('Hủy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog biến mất
      expect(find.text('Bạn có chắc muốn đăng xuất khỏi MamGo?'), findsNothing);
    });

    testWidgets('Chọn Đăng xuất trong dialog sẽ điều hướng ra LoginScreen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final logoutBtn = find.text('Đăng xuất').last;
      await tester.ensureVisible(logoutBtn);

      await tester.tap(logoutBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Bấm xác nhận đăng xuất trên dialog
      final confirmBtn = find.widgetWithText(TextButton, 'Đăng xuất');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
