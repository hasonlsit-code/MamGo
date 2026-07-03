import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/data/datasources/notification_log_service.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';

/// Trung tâm thông báo: xem lại các nhắc nhở đã gửi theo mốc thời gian.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<UserPreferenceProvider>().preference;
    final entries = NotificationLogService.buildTimeline(pref);
    final now = DateTime.now();

    // Gom nhóm theo ngày
    final groups = <String, List<NotificationEntry>>{};
    for (final e in entries) {
      final key = _dayLabel(e.time, now);
      groups.putIfAbsent(key, () => []).add(e);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: entries.isEmpty
          ? _emptyState()
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: groups.entries
                  .expand((g) => [
                        _dayHeader(g.key),
                        ...g.value.map(_entryTile),
                      ])
                  .toList(),
            ),
    );
  }

  static String _dayLabel(DateTime t, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _dayHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textMedium,
        ),
      ),
    );
  }

  Widget _entryTile(NotificationEntry e) {
    final hh = e.time.hour.toString().padLeft(2, '0');
    final mm = e.time.minute.toString().padLeft(2, '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(e.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '$hh:$mm',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  e.body,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textMedium,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 56, color: AppTheme.textMedium),
          SizedBox(height: 12),
          Text(
            'Chưa có thông báo nào',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Bật nhắc nhở trong Hồ sơ để nhận thông báo nhé!',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
