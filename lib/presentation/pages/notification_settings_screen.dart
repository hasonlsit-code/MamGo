import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/data/datasources/notification_log_datasource.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/core/constants/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _breakfastOn = false;
  bool _lunchOn = false;
  bool _dinnerOn = false;
  late TimeOfDay _breakfastTime;
  late TimeOfDay _lunchTime;
  late TimeOfDay _dinnerTime;

  @override
  void initState() {
    super.initState();
    _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
    _lunchTime = const TimeOfDay(hour: 12, minute: 0);
    _dinnerTime = const TimeOfDay(hour: 18, minute: 30);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrefs());
  }

  void _loadPrefs() {
    final p = context.read<UserPreferenceProvider>().preference;
    if (p == null) return;
    _parseTime(p.breakfastTime, (t) => _breakfastTime = t);
    _parseTime(p.lunchTime, (t) => _lunchTime = t);
    _parseTime(p.dinnerTime, (t) => _dinnerTime = t);
    setState(() {
      _breakfastOn = p.breakfastReminder;
      _lunchOn = p.lunchReminder;
      _dinnerOn = p.dinnerReminder;
    });
  }

  void _parseTime(String s, Function(TimeOfDay) fn) {
    final parts = s.split(':');
    if (parts.length == 2) {
      fn(
        TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        ),
      );
    }
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(TimeOfDay current, Function(TimeOfDay) onPick) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) setState(() => onPick(picked));
  }

  Future<void> _save() async {
    final prov = context.read<UserPreferenceProvider>();
    final p = prov.preference;
    if (p == null) return;
    final email = context.read<AuthProvider>().user?.email ?? '';
    await prov.save(
      p.copyWith(
        breakfastReminder: _breakfastOn,
        lunchReminder: _lunchOn,
        dinnerReminder: _dinnerOn,
        breakfastTime: _fmtTime(_breakfastTime),
        lunchTime: _fmtTime(_lunchTime),
        dinnerTime: _fmtTime(_dinnerTime),
      ),
      email,
    );

    await _logScheduleConfirmations();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã lưu cài đặt nhắc nhở!'),
        backgroundColor: AppTheme.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Ghi log "đã đặt lịch" cho mỗi bữa vừa bật nhắc, kèm đếm ngược còn bao
  /// lâu nữa sẽ đến bữa — tính đúng tại thời điểm lưu (đồng hồ máy thật).
  Future<void> _logScheduleConfirmations() async {
    final now = DateTime.now();

    Future<void> logOne(
      bool on,
      TimeOfDay t,
      String label,
      String emoji,
    ) async {
      if (!on) return;
      var target = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));
      final remaining = target.difference(now);
      final hh = remaining.inHours;
      final mm = remaining.inMinutes % 60;
      final countdown = hh > 0 ? '$hh giờ $mm phút' : '$mm phút';
      await NotificationLogService.log(
        emoji: emoji,
        title: 'Đã đặt lịch nhắc $label',
        body: 'Lúc ${_fmtTime(t)} — còn $countdown nữa sẽ đến $label',
        time: now,
      );
    }

    await logOne(_breakfastOn, _breakfastTime, 'bữa sáng', '🌅');
    await logOne(_lunchOn, _lunchTime, 'bữa trưa', '☀️');
    await logOne(_dinnerOn, _dinnerTime, 'bữa tối', '🌙');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('🔔 Điều chỉnh nhắc nhở')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),
            const SizedBox(height: 20),
            _mealTile(
              emoji: '🌅',
              label: 'Bữa sáng',
              subtitle: 'Bắt đầu ngày mới với năng lượng tràn đầy',
              isOn: _breakfastOn,
              time: _breakfastTime,
              onToggle: (v) => setState(() => _breakfastOn = v),
              onPickTime: () =>
                  _pickTime(_breakfastTime, (t) => _breakfastTime = t),
            ),
            const SizedBox(height: 14),
            _mealTile(
              emoji: '☀️',
              label: 'Bữa trưa',
              subtitle: 'Nạp năng lượng giữa ngày',
              isOn: _lunchOn,
              time: _lunchTime,
              onToggle: (v) => setState(() => _lunchOn = v),
              onPickTime: () => _pickTime(_lunchTime, (t) => _lunchTime = t),
            ),
            const SizedBox(height: 14),
            _mealTile(
              emoji: '🌙',
              label: 'Bữa tối',
              subtitle: 'Kết thúc ngày với bữa ăn ngon',
              isOn: _dinnerOn,
              time: _dinnerTime,
              onToggle: (v) => setState(() => _dinnerOn = v),
              onPickTime: () => _pickTime(_dinnerTime, (t) => _dinnerTime = t),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Thông báo sẽ nhắc bạn đúng giờ mỗi ngày 📱',
                style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _tipCard(),
          ],
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhắc nhở thông minh',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'MămGo sẽ nhắc bạn đúng giờ ăn và gợi ý món ngon phù hợp!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealTile({
    required String emoji,
    required String label,
    required String subtitle,
    required bool isOn,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required VoidCallback onPickTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOn
              ? AppTheme.primary.withValues(alpha: 0.4)
              : const Color(0xFFEEE0D8),
          width: isOn ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),
          if (isOn) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEE0D8)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onPickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fmtTime(time),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo nhỏ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Khi nhận thông báo, nhấn vào để mở MamGo - '
                  'trợ lý sẽ gợi ý ngay những món phù hợp với khẩu vị của bạn!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
