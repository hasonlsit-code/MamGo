import 'package:flutter/material.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/data/datasources/meal_log_service.dart';
import 'package:mamgo/data/models/meal_log_entry.dart';

/// Nhật ký bữa ăn: xem lại lịch sử các bữa đã lưu từ màn phân tích AI,
/// theo dõi xu hướng calo theo tuần.
class MealDiaryScreen extends StatefulWidget {
  const MealDiaryScreen({super.key});

  @override
  State<MealDiaryScreen> createState() => _MealDiaryScreenState();
}

class _MealDiaryScreenState extends State<MealDiaryScreen> {
  List<MealLogEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await MealLogService.loadAll();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xoá bữa ăn'),
        content: const Text(
            'Bạn có chắc muốn xoá bữa ăn này khỏi nhật ký không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ',
                style: TextStyle(color: AppTheme.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _delete(MealLogEntry entry) async {
    setState(() => _entries!.remove(entry));
    await MealLogService.deleteAt(entry.time);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá bữa ăn khỏi nhật ký')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
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
          'Nhật ký bữa ăn',
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
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _weekChart(entries),
                    const SizedBox(height: 20),
                    ..._buildDayGroups(entries),
                  ],
                ),
    );
  }

  // ── Biểu đồ tuần này: cố định Thứ 2 → CN ──────────────────────────────────
  Widget _weekChart(List<MealLogEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // weekday: Thứ 2 = 1 ... CN = 7 → lùi về đầu tuần (Thứ 2) rồi sinh đủ 7 ngày
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final totals = <DateTime, int>{
      for (final d in days) d: 0,
    };
    for (final e in entries) {
      final d = DateTime(e.time.year, e.time.month, e.time.day);
      if (totals.containsKey(d)) totals[d] = totals[d]! + e.totalKcal;
    }
    final maxVal = totals.values.fold<int>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'Calo tuần này',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: days.map((d) {
              final kcal = totals[d]!;
              final isToday = d == today;
              // Tỉ lệ chiều cao cột (10%–100% của khung cột cố định bên dưới),
              // dùng FractionallySizedBox thay vì cộng pixel thủ công để
              // không bao giờ tràn khung dù text lớn hay nhỏ.
              final fraction =
                  maxVal <= 0 ? 0.05 : 0.1 + (kcal / maxVal) * 0.9;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nhãn kcal: khung cố định để các cột luôn thẳng hàng
                      // dù ngày đó có dữ liệu hay không.
                      SizedBox(
                        height: 14,
                        child: kcal > 0
                            ? FittedBox(
                                child: Text(
                                  '$kcal',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? AppTheme.primary
                                        : AppTheme.textMedium,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      // Khung cột cố định 74px; cột thật chỉ lấp một phần
                      // theo tỉ lệ, neo ở đáy.
                      SizedBox(
                        height: 74,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: fraction,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isToday
                                      ? AppTheme.brandGradient
                                      : [
                                          AppTheme.primary
                                              .withValues(alpha: 0.25),
                                          AppTheme.primary
                                              .withValues(alpha: 0.15),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _weekdayLabel(d.weekday),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[weekday - 1];
  }

  // ── Danh sách theo ngày ──────────────────────────────────────────────────
  List<Widget> _buildDayGroups(List<MealLogEntry> entries) {
    final now = DateTime.now();
    final groups = <String, List<MealLogEntry>>{};
    for (final e in entries) {
      final key = _dayLabel(e.time, now);
      groups.putIfAbsent(key, () => []).add(e);
    }

    return groups.entries.expand((g) {
      final dayTotal = g.value.fold<int>(0, (s, e) => s + e.totalKcal);
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          child: Row(
            children: [
              Text(
                g.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMedium,
                ),
              ),
              const Spacer(),
              Text(
                'Tổng $dayTotal kcal',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.orange,
                ),
              ),
            ],
          ),
        ),
        ...g.value.map(_entryTile),
        const SizedBox(height: 8),
      ];
    }).toList();
  }

  static String _dayLabel(DateTime t, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _entryTile(MealLogEntry e) {
    final hh = e.time.hour.toString().padLeft(2, '0');
    final mm = e.time.minute.toString().padLeft(2, '0');
    return Dismissible(
      key: ValueKey(e.time.toIso8601String()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => _delete(e),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EAF4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: AppTheme.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${e.totalKcal} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$hh:$mm',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                  if (e.items.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      e.items.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textMedium),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.textMedium, size: 20),
              onPressed: () async {
                if (await _confirmDelete()) _delete(e);
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded,
              size: 56, color: AppTheme.textMedium),
          const SizedBox(height: 12),
          const Text(
            'Chưa có bữa ăn nào trong nhật ký',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chụp ảnh bữa ăn ở tab Đo lường rồi lưu lại nhé!',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 12),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.camera_alt_rounded,
                size: 18, color: AppTheme.primary),
            label: const Text('Quay lại chụp ảnh',
                style: TextStyle(color: AppTheme.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
