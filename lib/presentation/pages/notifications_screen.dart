import 'package:flutter/material.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/data/datasources/notification_log_service.dart';

/// Trung tâm thông báo: xem lại các thông báo THẬT đã xảy ra, đúng thời điểm
/// theo đồng hồ máy lúc đó (không phải tính toán giả lập).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await NotificationLogService.loadAll();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final now = DateTime.now();

    // Gom nhóm theo ngày
    final groups = <String, List<NotificationEntry>>{};
    if (entries != null) {
      for (final e in entries) {
        final key = _dayLabel(e.time, now);
        groups.putIfAbsent(key, () => []).add(e);
      }
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
      body: entries == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : entries.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: groups.entries
                        .expand((g) => [
                              _dayHeader(g.key),
                              ...g.value.map(_entryTile),
                            ])
                        .toList(),
                  ),
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
    final ss = e.time.second.toString().padLeft(2, '0');
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
                      '$hh:$mm:$ss',
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMedium,
                          fontFamily: 'monospace'),
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
    return Center(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        shrinkWrap: true,
        children: const [
          SizedBox(height: 120),
          Icon(Icons.notifications_off_outlined,
              size: 56, color: AppTheme.textMedium),
          SizedBox(height: 12),
          Text(
            'Chưa có thông báo nào',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Bật nhắc nhở trong Hồ sơ để nhận thông báo nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMedium, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
