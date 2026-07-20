import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:mamgo/domain/interface_repositories/ifood_repository.dart';

class SearchFoodsService {
  final IFoodRepository repository;
  SearchFoodsService(this.repository);

  List<Food> execute(String query) => repository.searchFoods(query);
}
