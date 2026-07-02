import 'package:mamgo/data/models/food.dart';

abstract class IFoodRepository {
  List<Food> getAllFoods();
  List<Food> getFoodsByMealType(String mealType);
  List<Food> searchFoods(String query);
}
