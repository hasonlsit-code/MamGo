import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/bot_settings_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';
import 'package:mamgo/presentation/pages/splash_screen.dart';
import 'package:mamgo/data/datasources/notification_log_datasource.dart';
import 'package:mamgo/data/datasources/notification_datasource.dart';
import 'package:mamgo/core/constants/app_theme.dart';

/// Nội dung tương ứng từng payload thông báo, dùng để ghi log khi người dùng
/// bấm mở thông báo hệ thống (thời điểm ghi = lúc bấm, theo đồng hồ máy thật).
const _kNotificationContent = {
  'meal_breakfast': (
    '🍽️',
    'Đến giờ bữa sáng rồi!',
    'MămGo có nhiều gợi ý ngon cho bạn hôm nay! 😋',
  ),
  'meal_lunch': (
    '🍽️',
    'Đến giờ bữa trưa rồi!',
    'MămGo có nhiều gợi ý ngon cho bạn hôm nay! 😋',
  ),
  'meal_dinner': (
    '🍽️',
    'Đến giờ bữa tối rồi!',
    'MămGo có nhiều gợi ý ngon cho bạn hôm nay! 😋',
  ),
  'morning_greeting': (
    '☀️',
    'Chào buổi sáng!',
    'Chúc bạn một ngày tốt lành! Nhớ ăn uống đầy đủ để khỏe mạnh nhé 🍀',
  ),
};

void _logTappedNotification(String? payload) {
  final content = _kNotificationContent[payload];
  if (content == null) return;
  NotificationLogService.log(
    emoji: content.$1,
    title: content.$2,
    body: content.$3,
    time: DateTime.now(),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await NotificationService().initialize(
    onNotificationTap: (payload) {
      _logTappedNotification(payload);
      // Khi tap notification → mở HomeScreen tab chatbot (index 3)
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialTab: 3, chatbotPayload: payload),
        ),
        (_) => false,
      );
    },
  );

  runApp(const MamGoApp());
}

class MamGoApp extends StatelessWidget {
  const MamGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BotSettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferenceProvider()),
      ],
      child: MaterialApp(
        title: 'MămGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
