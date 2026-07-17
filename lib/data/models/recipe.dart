import 'package:mamgo/domain/entities/recipe_entity.dart';

export 'package:mamgo/domain/entities/recipe_entity.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.ingredients,
    required super.steps,
    required super.prepTime,
    required super.cookTime,
    required super.servings,
    required super.difficulty,
    required super.tags,
    required super.emoji,
    required super.cuisine,
    super.imageUrl = '',
  });
}
