import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamgo/presentation/pages/notification_settings_screen.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/domain/entities/user_account_entity.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserAccount? get user => const UserAccount(name: 'Người Dùng Test', email: 'test@example.com', password: '');

  @override
  Future<void> logout() async {}
  @override
  bool get isLoggedIn => true;
  @override
  Future<String?> rememberedEmail() async => null;
  @override
  Future<String?> login(String email, String password, {bool remember = true}) async => null;
  @override
  Future<void> loadSession() async {}
  @override
  Future<String?> register(String name, String email, String password) async => null;
}

class MockUserPreferenceProvider extends ChangeNotifier implements UserPreferenceProvider {
  @override
  UserPreference? preference = const UserPreference(
    name: 'Người Dùng Test',
    tastePreferences: [],
    dietaryRestrictions: [],
    favoriteCuisines: [],
    breakfastReminder: false,
    lunchReminder: false,
    dinnerReminder: false,
    breakfastTime: '07:00',
    lunchTime: '12:00',
    dinnerTime: '18:30',
  );

  bool isSaved = false;
  
  @override
  Future<String?> save(UserPreference pref, String email) async {
    preference = pref;
    isSaved = true;
    notifyListeners();
    return null;
  }
  
  @override
  Future<void> clear() async {}
  @override
  bool get hasPreference => true;
  @override
  Future<void> load(String email) async {}
  @override
  bool get isLoading => false;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(UserPreferenceProvider prefProv) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider<UserPreferenceProvider>.value(value: prefProv),
      ],
      child: const MaterialApp(home: NotificationSettingsScreen()),
    );
  }

  group('NotificationSettingsScreen Tests', () {
    testWidgets('Hiển thị giao diện cài đặt nhắc nhở', (tester) async {
      final prefProv = MockUserPreferenceProvider();
      await tester.pumpWidget(createTestWidget(prefProv));
      await tester.pumpAndSettle();

      expect(find.text('🔔 Điều chỉnh nhắc nhở'), findsOneWidget);
      expect(find.text('Bữa sáng'), findsOneWidget);
      expect(find.text('Bữa trưa'), findsOneWidget);
      expect(find.text('Bữa tối'), findsOneWidget);
    });

    testWidgets('Bật nhắc nhở bữa sáng và lưu', (tester) async {
      final prefProv = MockUserPreferenceProvider();
      await tester.pumpWidget(createTestWidget(prefProv));
      await tester.pumpAndSettle();

      // Mặc định là false (Switch bị tắt)
      // Tìm Switch bữa sáng (Switch đầu tiên)
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // Bật công tắc đầu tiên (Bữa sáng)
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Khung thời gian hiện ra (chứa icon access_time)
      expect(find.byIcon(Icons.access_time), findsOneWidget);

      // Cuộn xuống để bấm lưu
      final saveBtn = find.text('Lưu cài đặt');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Kiểm tra xem provider đã ghi đè chưa
      expect(prefProv.isSaved, true);
      expect(prefProv.preference!.breakfastReminder, true);
    });
    testWidgets('Bật nhắc nhở bữa trưa và lưu', (tester) async {
      final prefProv = MockUserPreferenceProvider();
      await tester.pumpWidget(createTestWidget(prefProv));
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      
      // Bật công tắc thứ hai (Bữa trưa)
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      final saveBtn = find.text('Lưu cài đặt');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(prefProv.isSaved, true);
      expect(prefProv.preference!.lunchReminder, true);
    });

    testWidgets('Bật nhắc nhở bữa tối và lưu', (tester) async {
      final prefProv = MockUserPreferenceProvider();
      await tester.pumpWidget(createTestWidget(prefProv));
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      
      // Bật công tắc thứ ba (Bữa tối)
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      final saveBtn = find.text('Lưu cài đặt');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(prefProv.isSaved, true);
      expect(prefProv.preference!.dinnerReminder, true);
    });

    testWidgets('Tắt nhắc nhở sáng, trưa, tối và lưu', (tester) async {
      final prefProv = MockUserPreferenceProvider();
      // Set trạng thái ban đầu trực tiếp cho test case này (độc lập hoàn toàn)
      prefProv.preference = prefProv.preference!.copyWith(
        breakfastReminder: true,
        lunchReminder: true,
        dinnerReminder: true,
      );
      
      await tester.pumpWidget(createTestWidget(prefProv));
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // Tắt cả 3 công tắc đi
      await tester.ensureVisible(switches.at(0));
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      
      await tester.ensureVisible(switches.at(1));
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      
      await tester.ensureVisible(switches.at(2));
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();

      // Lưu
      final saveBtn = find.text('Lưu cài đặt');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Kiểm tra xem provider đã ghi đè thành false chưa
      expect(prefProv.isSaved, true);
      expect(prefProv.preference!.breakfastReminder, false);
      expect(prefProv.preference!.lunchReminder, false);
      expect(prefProv.preference!.dinnerReminder, false);
    });
  });
}
