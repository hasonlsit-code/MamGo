import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bật/tắt trợ lý nổi "MamGo bot" hiển thị xuyên suốt app.
class BotSettingsProvider extends ChangeNotifier {
  static const _key = 'mamgo_bot_enabled';

  bool _enabled = true;
  bool get enabled => _enabled;

  BotSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _enabled = p.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, value);
  }
}
