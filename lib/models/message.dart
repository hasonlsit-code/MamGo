import 'food.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Food>? suggestedFoods;

  const Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedFoods,
  });
}
