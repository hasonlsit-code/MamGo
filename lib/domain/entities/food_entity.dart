class Food {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final List<String> cuisines;
  final int calories;
  final String prepTime;
  final String difficulty;
  final String emoji;
  final String mealType; // breakfast | lunch | dinner | any
  final String imageUrl;

  const Food({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.cuisines,
    required this.calories,
    required this.prepTime,
    required this.difficulty,
    required this.emoji,
    required this.mealType,
    this.imageUrl = '',
  });
}
