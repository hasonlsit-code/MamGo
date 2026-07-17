import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:mamgo/domain/interface_repositories/ifood_repository.dart';

class FoodRepositoryImpl implements IFoodRepository {
  @override
  List<Food> getAllFoods() => FoodsData.all;

  @override
  List<Food> getFoodsByMealType(String mealType) => FoodsData.all
      .where((f) => f.mealType == mealType || f.mealType == 'any')
      .toList();

  @override
  List<Food> searchFoods(String query) {
    final q = query.toLowerCase();
    return FoodsData.all
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.tags.any((t) => t.contains(q)),
        )
        .toList();
  }
}
