import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';
import 'package:mamgo/presentation/pages/splash_screen.dart';
import 'package:mamgo/data/datasources/notification_service.dart';
import 'package:mamgo/core/constants/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await NotificationService().initialize(
    onNotificationTap: (_) {
      // Khi tap notification → mở HomeScreen tab chatbot (index 1)
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UserPreferenceProvider()..load(),
            child: const HomeScreen(initialTab: 1),
          ),
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
