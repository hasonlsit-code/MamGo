import 'package:mamgo/domain/entities/food_entity.dart';

abstract class IFoodRepository {
  List<Food> getAllFoods();
  List<Food> getFoodsByMealType(String mealType);
  List<Food> searchFoods(String query);
}
