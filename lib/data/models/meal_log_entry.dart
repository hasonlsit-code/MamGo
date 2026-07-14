/// Một bữa ăn đã được lưu vào nhật ký (từ kết quả phân tích AI).
class MealLogEntry {
  final DateTime time;
  final int totalKcal;
  final List<String> items;

  const MealLogEntry({
    required this.time,
    required this.totalKcal,
    required this.items,
  });

  factory MealLogEntry.fromJson(Map<String, dynamic> json) => MealLogEntry(
        time: DateTime.parse(json['time'] as String),
        totalKcal: (json['total_kcal'] as num?)?.round() ?? 0,
        items:
            ((json['items'] as List?) ?? []).map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'total_kcal': totalKcal,
        'items': items,
      };
}
