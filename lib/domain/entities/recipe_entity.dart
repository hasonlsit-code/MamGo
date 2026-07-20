class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String difficulty;
  final List<String> tags;
  final String emoji;
  final String cuisine;
  final String imageUrl;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.tags,
    required this.emoji,
    required this.cuisine,
    this.imageUrl = '',
  });
}
