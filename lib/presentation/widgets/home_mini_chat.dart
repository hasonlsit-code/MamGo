import 'package:flutter/material.dart';
import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:mamgo/data/datasources/gemini_service.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/pages/food_detail_screen.dart';
import 'package:mamgo/presentation/widgets/animated_mascot.dart';

class HomeMiniChat extends StatefulWidget {
  const HomeMiniChat({super.key});

  @override
  State<HomeMiniChat> createState() => _HomeMiniChatState();
}

class _HomeMiniChatState extends State<HomeMiniChat> {
  final _ctrl = TextEditingController();
  String? _userMsg;
  String? _aiReply;
  bool _loading = false;
  List<Food> _suggestedFoods = [];

  static const _moodChips = [
    ('😊', 'Đang vui'),
    ('😓', 'Hơi stress'),
    ('😴', 'Đang mệt'),
    ('🍽️', 'Đang đói'),
  ];

  Future<void> _ask(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _userMsg = trimmed;
      _aiReply = null;
      _loading = true;
      _suggestedFoods = [];
    });
    _ctrl.clear();

    final reply = await GeminiService.chat(
      '$trimmed (hãy trả lời ngắn gọn khoảng 2-3 câu và gợi ý vài món ăn phù hợp tâm trạng)',
    );
    final foods = _matchFoods(trimmed);

    if (!mounted) return;
    setState(() {
      _aiReply = reply;
      _loading = false;
      _suggestedFoods = foods;
    });
  }

  List<Food> _matchFoods(String query) {
    final q = query.toLowerCase();
    final all = List<Food>.from(FoodsData.all)..shuffle();

    if (q.contains('mệt') || q.contains('stress') || q.contains('áp lực') || q.contains('buồn')) {
      final light = all
          .where((f) =>
              f.tags.contains('light') ||
              f.tags.contains('healthy') ||
              f.tags.contains('fresh'))
          .toList();
      return (light.isEmpty ? all : light).take(3).toList();
    }
    if (q.contains('đói') || q.contains('thèm') || q.contains('bụng')) {
      final hearty = all.where((f) => f.calories > 400).toList();
      return (hearty.isEmpty ? all : hearty).take(3).toList();
    }
    if (q.contains('cay') || q.contains('spicy')) {
      final spicy = all.where((f) => f.tags.contains('spicy')).toList();
      return (spicy.isEmpty ? all : spicy).take(3).toList();
    }
    final hour = DateTime.now().hour;
    if (q.contains('sáng') || hour < 10) {
      return all
          .where((f) => f.mealType == 'breakfast' || f.mealType == 'any')
          .take(3)
          .toList();
    }
    if (q.contains('trưa') || (hour >= 10 && hour < 15)) {
      return all
          .where((f) => f.mealType == 'lunch' || f.mealType == 'any')
          .take(3)
          .toList();
    }
    return all.take(3).toList();
  }

  Future<void> _onFoodTapped(BuildContext ctx, Food food) async {
    // Navigate to detail screen
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );

    // Get AI commentary about the selected food in context
    setState(() => _loading = true);
    final contextMsg = _userMsg ?? 'bình thường';
    final prompt =
        'Người dùng đang cảm thấy "$contextMsg" và chọn xem món ${food.name} ${food.emoji} '
        '(${food.calories} kcal). Nhận xét 1-2 câu: món này có phù hợp không, '
        'nêu 1 lợi ích nhỏ hoặc lưu ý. Nếu không phù hợp, gợi ý kiểu món thay thế.';
    final reply = await GeminiService.chat(prompt);
    if (!mounted) return;
    setState(() {
      _aiReply = reply;
      _loading = false;
    });
  }

  void _reset() {
    setState(() {
      _userMsg = null;
      _aiReply = null;
      _loading = false;
      _suggestedFoods = [];
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.13),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F5F0)),
          _inputRow(),
          if (_userMsg == null) _moodChipsRow() else _conversationArea(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          const AnimatedMascot(size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MămGo AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Luôn sẵn sàng hỗ trợ',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_userMsg != null)
            GestureDetector(
              onTap: _reset,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.chipBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.refresh_rounded,
                    size: 15, color: AppTheme.textMedium),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.14)),
              ),
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Hỏi về ăn gì, hoặc tâm trạng của bạn...',
                  hintStyle:
                      TextStyle(color: AppTheme.textMedium, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                onSubmitted: _ask,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _ask(_ctrl.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodChipsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 7,
        children: _moodChips.map((chip) {
          return GestureDetector(
            onTap: () => _ask('${chip.$1} ${chip.$2}'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${chip.$1} ${chip.$2}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _conversationArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User bubble
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.62,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  _userMsg!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // AI reply
          if (_loading)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                const Text('MămGo đang suy nghĩ...',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textMedium)),
              ],
            )
          else if (_aiReply != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.1)),
              ),
              child: Text(
                _aiReply!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textDark, height: 1.5),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_suggestedFoods.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedFoods.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final food = _suggestedFoods[i];
                    return GestureDetector(
                      onTap: () => _onFoodTapped(ctx, food),
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  AppTheme.primary.withValues(alpha: 0.18)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
