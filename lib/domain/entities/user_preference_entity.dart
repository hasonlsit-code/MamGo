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
}
