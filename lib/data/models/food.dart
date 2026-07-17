import 'package:mamgo/domain/entities/food_entity.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.name,
    required super.description,
    required super.tags,
    required super.cuisines,
    required super.calories,
    required super.prepTime,
    required super.difficulty,
    required super.emoji,
    required super.mealType,
    super.imageUrl = '',
  });
}
