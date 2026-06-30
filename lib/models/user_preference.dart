class UserPreference {
  final String name;
  final List<String> tastePreferences;
  final List<String> dietaryRestrictions;
  final List<String> favoriteCuisines;
  final bool breakfastReminder;
  final bool lunchReminder;
  final bool dinnerReminder;
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;

  const UserPreference({
    required this.name,
    required this.tastePreferences,
    required this.dietaryRestrictions,
    required this.favoriteCuisines,
    this.breakfastReminder = false,
    this.lunchReminder = false,
    this.dinnerReminder = false,
    this.breakfastTime = '07:00',
    this.lunchTime = '12:00',
    this.dinnerTime = '18:30',
  });

  UserPreference copyWith({
    String? name,
    List<String>? tastePreferences,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    bool? breakfastReminder,
    bool? lunchReminder,
    bool? dinnerReminder,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
  }) {
    return UserPreference(
      name: name ?? this.name,
      tastePreferences: tastePreferences ?? this.tastePreferences,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      breakfastReminder: breakfastReminder ?? this.breakfastReminder,
      lunchReminder: lunchReminder ?? this.lunchReminder,
      dinnerReminder: dinnerReminder ?? this.dinnerReminder,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'tastePreferences': tastePreferences.join(','),
        'dietaryRestrictions': dietaryRestrictions.join(','),
        'favoriteCuisines': favoriteCuisines.join(','),
        'breakfastReminder': breakfastReminder,
        'lunchReminder': lunchReminder,
        'dinnerReminder': dinnerReminder,
        'breakfastTime': breakfastTime,
        'lunchTime': lunchTime,
        'dinnerTime': dinnerTime,
      };

  factory UserPreference.fromMap(Map<String, dynamic> map) => UserPreference(
        name: map['name'] ?? '',
        tastePreferences: _splitList(map['tastePreferences']),
        dietaryRestrictions: _splitList(map['dietaryRestrictions']),
        favoriteCuisines: _splitList(map['favoriteCuisines']),
        breakfastReminder: map['breakfastReminder'] ?? false,
        lunchReminder: map['lunchReminder'] ?? false,
        dinnerReminder: map['dinnerReminder'] ?? false,
        breakfastTime: map['breakfastTime'] ?? '07:00',
        lunchTime: map['lunchTime'] ?? '12:00',
        dinnerTime: map['dinnerTime'] ?? '18:30',
      );

  static List<String> _splitList(dynamic val) =>
      (val as String? ?? '').split(',').where((e) => e.isNotEmpty).toList();
}
