import 'package:flutter/material.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:mamgo/data/models/message.dart';
import 'package:mamgo/core/constants/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final void Function(Food)? onFoodTap;

  const ChatBubble({super.key, required this.message, this.onFoodTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _avatar(false),
                const SizedBox(width: 8),
              ],
              Flexible(child: _bubble(isUser)),
              if (isUser) ...[
                const SizedBox(width: 8),
                _avatar(true),
              ],
            ],
          ),
          if (!isUser && (message.suggestedFoods?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 10),
              child: _foodChips(),
            ),
        ],
      ),
    );
  }

  Widget _avatar(bool isUser) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isUser 
            ? const Text('😊', style: TextStyle(fontSize: 18))
            : ClipOval(child: Image.asset('chatbot.png', width: 28, height: 28, fit: BoxFit.cover)),
      ),
    );
  }

  Widget _bubble(bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildText(message.text, isUser),
    );
  }

  Widget _foodChips() {
    final foods = message.suggestedFoods!;
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: foods.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final food = foods[i];
          return GestureDetector(
            onTap: () => onFoodTap?.call(food),
            child: Container(
              width: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.09),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(food.emoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.chipBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${food.calories} kcal',
                      style: const TextStyle(
                          fontSize: 9, color: AppTheme.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildText(String text, bool isUser) {
    final parts = text.split('**');
    if (parts.length == 1) {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : AppTheme.textDark,
          fontSize: 14,
          height: 1.5,
        ),
      );
    }
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
          color: isUser ? Colors.white : AppTheme.textDark,
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}
