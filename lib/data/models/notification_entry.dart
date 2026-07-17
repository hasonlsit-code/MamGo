/// Một thông báo THẬT đã xảy ra, ghi đúng thời điểm theo đồng hồ máy lúc đó.
class NotificationEntry {
  final String emoji;
  final String title;
  final String body;
  final DateTime time;

  const NotificationEntry({
    required this.emoji,
    required this.title,
    required this.body,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'title': title,
    'body': body,
    'time': time.toIso8601String(),
  };

  factory NotificationEntry.fromJson(Map<String, dynamic> json) =>
      NotificationEntry(
        emoji: json['emoji'] ?? '🔔',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      );
}
