import 'package:mamgo/data/models/food.dart';
import 'package:mamgo/domain/interface_repositories/ifood_repository.dart';

class GetFoodSuggestionsUseCase {
  final IFoodRepository repository;
  GetFoodSuggestionsUseCase(this.repository);

  List<Food> execute(String mealType) =>
      repository.getFoodsByMealType(mealType);
}
