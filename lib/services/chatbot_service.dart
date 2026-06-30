import '../data/foods_data.dart';
import '../models/food.dart';
import '../models/user_preference.dart';

class ChatbotService {
  static String greet(String name) =>
      'Xin chào $name! 👋\nTôi là MamGo - trợ lý ẩm thực của bạn! 🤖\n\nHôm nay tôi có thể giúp gì cho bạn?';

  static String respond(String input, UserPreference? pref) {
    final msg = input.toLowerCase().trim();

    if (_contains(msg, ['xin chào', 'hello', 'hi', 'chào'])) {
      return 'Xin chào! Tôi là MamGo! 🤖\nBạn muốn ăn gì hôm nay?';
    }
    if (_contains(msg, ['sáng', 'bữa sáng', 'ăn sáng', 'breakfast'])) {
      return _suggestMeal('breakfast', pref, 'bữa sáng');
    }
    if (_contains(msg, ['trưa', 'bữa trưa', 'ăn trưa', 'lunch'])) {
      return _suggestMeal('lunch', pref, 'bữa trưa');
    }
    if (_contains(msg, ['tối', 'bữa tối', 'ăn tối', 'dinner'])) {
      return _suggestMeal('dinner', pref, 'bữa tối');
    }
    if (_contains(msg, ['cay', 'spicy'])) {
      return _suggestByTag('spicy', 'cay nồng');
    }
    if (_contains(msg, ['ngọt', 'sweet'])) {
      return _suggestByTag('sweet', 'ngọt ngào');
    }
    if (_contains(msg, ['chay', 'vegetarian', 'rau'])) {
      return _suggestByTag('vegetarian', 'chay');
    }
    if (_contains(msg, ['hải sản', 'seafood', 'tôm', 'cua', 'cá'])) {
      return _suggestByTag('seafood', 'hải sản');
    }
    if (_contains(msg, ['nhẹ', 'ít calo', 'healthy', 'lành mạnh'])) {
      return _suggestByTag('light', 'nhẹ nhàng, ít calo');
    }
    if (_contains(msg, ['ngẫu nhiên', 'random', 'tùy'])) {
      return _randomSuggest(pref);
    }
    if (_contains(msg, ['công thức', 'nấu', 'recipe'])) {
      return 'Bạn muốn học nấu món nào? 👨‍🍳\nHãy vào tab **Thư viện** để xem đầy đủ công thức nhé!';
    }
    if (_contains(msg, ['cảm ơn', 'thanks', 'thank you'])) {
      return 'Không có gì! Chúc bạn ngon miệng! 😋🍽️';
    }
    if (_contains(msg, ['tạm biệt', 'bye'])) {
      return 'Tạm biệt! Hẹn gặp lại bạn bữa sau! 👋';
    }

    return _randomSuggest(pref);
  }

  static String _suggestMeal(
      String mealType, UserPreference? pref, String label) {
    var foods = FoodsData.all
        .where((f) => f.mealType == mealType || f.mealType == 'any')
        .toList();

    if (pref != null) {
      foods.sort((a, b) =>
          _score(b, pref).compareTo(_score(a, pref)));
    }

    final top = foods.take(3).toList();
    if (top.isEmpty) return 'Không tìm thấy gợi ý phù hợp 😅';

    final buf = StringBuffer('Gợi ý $label cho bạn hôm nay:\n\n');
    for (final f in top) {
      buf.writeln('${f.emoji} **${f.name}**');
      buf.writeln('   ${f.calories} kcal • ${f.prepTime}\n');
    }
    buf.write('Chúc ngon miệng! 😋');
    return buf.toString();
  }

  static String _suggestByTag(String tag, String label) {
    final foods =
        FoodsData.all.where((f) => f.tags.contains(tag)).take(3).toList();
    if (foods.isEmpty) return 'Hmm, tôi chưa có gợi ý món $label nào phù hợp!';

    final buf = StringBuffer('Các món $label tôi nghĩ bạn sẽ thích:\n\n');
    for (final f in foods) {
      buf.writeln('${f.emoji} **${f.name}**\n   ${f.description.substring(0, (f.description.length > 60) ? 60 : f.description.length)}...\n');
    }
    return buf.toString();
  }

  static String _randomSuggest(UserPreference? pref) {
    final all = List<Food>.from(FoodsData.all)..shuffle();
    final pick = all.take(3).toList();
    final buf = StringBuffer('Tôi ngẫu nhiên gợi ý bạn thử:\n\n');
    for (final f in pick) {
      buf.writeln('${f.emoji} **${f.name}** (${f.calories} kcal)\n');
    }
    buf.write('Có gợi ý nào hợp khẩu vị không? 😄');
    return buf.toString();
  }

  static int _score(Food f, UserPreference p) {
    int s = 0;
    for (final t in p.tastePreferences) {
      if (f.tags.contains(t.toLowerCase())) s += 2;
    }
    for (final c in p.favoriteCuisines) {
      if (f.cuisines.contains(c)) s += 3;
    }
    return s;
  }

  static bool _contains(String msg, List<String> keywords) =>
      keywords.any((k) => msg.contains(k));
}
