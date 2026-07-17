import 'package:mamgo/domain/entities/user_preference_entity.dart';

export 'package:mamgo/domain/entities/user_preference_entity.dart';

class UserPreferenceModel extends UserPreference {
  const UserPreferenceModel({
    required super.name,
    required super.tastePreferences,
    required super.dietaryRestrictions,
    required super.favoriteCuisines,
    super.breakfastReminder = false,
    super.lunchReminder = false,
    super.dinnerReminder = false,
    super.breakfastTime = '07:00',
    super.lunchTime = '12:00',
    super.dinnerTime = '18:30',
  });

  UserPreferenceModel copyWith({
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
    return UserPreferenceModel(
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

  factory UserPreferenceModel.fromMap(Map<String, dynamic> map) =>
      UserPreferenceModel(
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
