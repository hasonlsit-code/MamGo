import 'package:flutter/material.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/data/models/message.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/food_detail_screen.dart';
import 'package:mamgo/data/datasources/gemini_service.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/core/utils/text_utils.dart';
import 'package:mamgo/presentation/widgets/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  /// true khi mở dạng popup từ MamGo bot nổi (hiện nút đóng).
  final bool isPopup;
  final String? initialPayload;
  final VoidCallback? onPayloadConsumed;

  const ChatbotScreen({
    super.key,
    this.isPopup = false,
    this.initialPayload,
    this.onPayloadConsumed,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messages = <Message>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  // Chưa thu thập trạng thái của người dùng → hỏi tâm trạng trước
  bool _moodCollected = false;

  static const _quickActions = [
    ('🌅 Ăn sáng', 'Gợi ý bữa sáng cho mình'),
    ('☀️ Ăn trưa', 'Gợi ý bữa trưa cho mình'),
    ('🌙 Ăn tối', 'Gợi ý bữa tối cho mình'),
    ('🌶️ Món cay', 'Gợi ý món cay ngon'),
    ('🥗 Nhẹ nhàng', 'Gợi ý món nhẹ ít calo'),
    ('🎲 Bất ngờ!', 'Gợi ý ngẫu nhiên'),
  ];

  // Trạng thái → (nhãn chip, tag ưu tiên, tag nên tránh, lời đáp thân thiện)
  static const _moodOptions = [
    (
      '😴 Mệt mỏi',
      ['soup', 'warm', 'light'],
      ['spicy', 'rich', 'crispy'],
      'Mình hiểu rồi 🥺 Khi mệt mỏi bạn nên tránh đồ cay nóng, nhiều dầu mỡ nha. '
          'Đây là các món thanh nhẹ, dễ tiêu giúp bạn nạp lại năng lượng nè 💪\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
    (
      '😊 Vui vẻ',
      <String>[],
      <String>[],
      'Yeah, tâm trạng tốt thì ăn gì cũng ngon! 🎉 '
          'Đây là những món mình chọn riêng để bữa ăn của bạn thêm trọn vẹn nè 😋\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
    (
      '😰 Căng thẳng',
      ['light', 'fresh', 'soup'],
      ['spicy', 'crispy'],
      'Hít thở sâu nào bạn ơi 🌿 Lúc căng thẳng nên ăn món thanh đạm, dễ chịu — '
          'tránh đồ cay và chiên rán nha. Thử mấy món này cho nhẹ bụng nè 💙\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
    (
      '💼 Bận rộn',
      ['quick'],
      <String>[],
      'Bận rộn thì để mình lo! ⚡ Đây là các món nhanh gọn, dễ làm '
          'mà vẫn đủ chất cho bạn nè 🍱\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
    (
      '🥗 Muốn healthy',
      ['healthy', 'fresh', 'light'],
      ['rich', 'crispy'],
      'Quá chuẩn luôn! 🥗 Đây là những món healthy ít calo, tươi xanh '
          'giúp bạn khỏe đẹp mỗi ngày nè ✨\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
    (
      '😋 Đói bụng',
      <String>[],
      <String>[],
      'Đói thì phải ăn no nê liền! 😋 Đây là mấy món "chắc bụng" '
          'mình gợi ý cho bạn nè 🍚\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendGreeting());
  }

  @override
  void didUpdateWidget(covariant ChatbotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPayload != oldWidget.initialPayload &&
        widget.initialPayload != null) {
      _messages.clear();
      _sendGreeting();
    }
  }

  String _getTimeBasedGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Chào buổi sáng $name! 🌅 Chúc bạn một ngày mới đầy năng lượng. Bạn đã ăn sáng chưa? Nhớ nạp đủ năng lượng cho ngày mới nhé! 🍀\n\nHôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình hoặc chọn nhanh tâm trạng phía dưới nha!';
    } else if (hour >= 11 && hour < 14) {
      return 'Chào buổi trưa $name! ☀️ Đã đến giờ nghỉ ngơi và ăn trưa rồi. Hôm nay bạn muốn dùng món gì để nạp lại năng lượng? 🍱\n\nHôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình hoặc chọn nhanh tâm trạng phía dưới nha!';
    } else if (hour >= 14 && hour < 18) {
      return 'Chào buổi chiều $name! 🍃 Bạn đã có một ngày làm việc hiệu quả chứ? Hãy uống một chút nước hoặc ăn nhẹ để giữ tỉnh táo nhé! 🍉\n\nHôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình hoặc chọn nhanh tâm trạng phía dưới nha!';
    } else if (hour >= 18 && hour < 22) {
      return 'Chào buổi tối $name! 🌙 Đã đến giờ ăn tối rồi. Bạn muốn mình gợi ý món ăn tối ngon miệng và ấm cúng cho gia đình không? 🍲\n\nHôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình hoặc chọn nhanh tâm trạng phía dưới nha!';
    } else {
      return 'Chào bạn $name! 🌌 Đã khá muộn rồi, bạn nên nghỉ ngơi sớm nhé. Nếu có đói bụng thì chỉ nên ăn nhẹ món dễ tiêu thôi nha! 💤\n\nHôm nay bạn cảm thấy thế nào? Hãy chia sẻ với mình hoặc chọn nhanh tâm trạng phía dưới nha!';
    }
  }

  List<Food> _foodsForMealType(String type) {
    final pref = context.read<UserPreferenceProvider>().preference;
    var list =
        FoodsData.all
            .where(
              (f) =>
                  f.mealType.toLowerCase() == type.toLowerCase() ||
                  f.mealType.toLowerCase() == 'any',
            )
            .toList()
          ..shuffle();
    if (pref != null) {
      int score(Food f) {
        int s = 0;
        for (final t in pref.tastePreferences) {
          if (f.tags.contains(t)) s += 2;
        }
        for (final c in pref.favoriteCuisines) {
          if (f.cuisines.contains(c)) s += 3;
        }
        return s;
      }

      list.sort((a, b) => score(b).compareTo(score(a)));
    }
    return list.take(3).toList();
  }

  void _sendGreeting() {
    final pref = context.read<UserPreferenceProvider>().preference;
    GeminiService.initialize(pref);
    final name = pref?.name ?? 'bạn';

    String message;
    List<Food>? suggestedFoods;

    if (widget.initialPayload != null) {
      switch (widget.initialPayload) {
        case 'morning_greeting':
          message =
              'Chào buổi sáng $name! ☀️ Chúc bạn một ngày mới tốt lành! Nhớ ăn uống đầy đủ để khỏe mạnh nhé 🍀';
          break;
        case 'meal_breakfast':
          message =
              '🍽️ Đến giờ ăn sáng rồi $name ơi!\n\nBữa sáng vô cùng quan trọng để bắt đầu một ngày mới. MămGo gợi ý cho bạn một vài món ăn sáng bổ dưỡng và ngon miệng bên dưới nè, thử xem sao nhé! 🍳';
          suggestedFoods = _foodsForMealType('breakfast');
          break;
        case 'meal_lunch':
          message =
              '🍽️ Đến giờ ăn trưa rồi $name ơi!\n\nHãy tạm gác công việc để nạp năng lượng nhé. Mình có sẵn các gợi ý món ăn trưa thơm ngon cho bạn nạp năng lượng đây! 😋';
          suggestedFoods = _foodsForMealType('lunch');
          break;
        case 'meal_dinner':
          message =
              '🍽️ Đến giờ ăn tối rồi $name ơi!\n\nSau một ngày dài bận rộn, hãy thưởng thức bữa tối thật ngon miệng để hồi sức nhé. Hôm nay bạn thích món ăn nào dưới đây? 🍲';
          suggestedFoods = _foodsForMealType('dinner');
          break;
        default:
          message = _getTimeBasedGreeting(name);
      }
      widget.onPayloadConsumed?.call();
    } else {
      message = _getTimeBasedGreeting(name);
    }

    _addBot(message, foods: suggestedFoods);
  }

  // ── Thu thập trạng thái & gợi ý món theo tâm trạng ──────────────────────────
  void _selectMood(int index) {
    final (label, prefer, avoid, reply) = _moodOptions[index];
    _addUser(label);
    setState(() {
      _moodCollected = true;
      _typing = true;
    });
    // Giả lập bot "đang gõ" một nhịp ngắn cho tự nhiên
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _typing = false);
      _addBot(reply, foods: _foodsForMood(prefer, avoid, isHungry: index == 5));
    });
  }

  List<Food> _foodsForMood(
    List<String> prefer,
    List<String> avoid, {
    bool isHungry = false,
  }) {
    final pref = context.read<UserPreferenceProvider>().preference;
    var list = FoodsData.all.where((f) => !f.tags.any(avoid.contains)).toList()
      ..shuffle();
    if (isHungry) {
      final hearty = list.where((f) => f.calories >= 400).toList();
      if (hearty.isNotEmpty) list = hearty;
    }

    int score(Food f) {
      int s = 0;
      for (final t in prefer) {
        if (f.tags.contains(t)) s += 5;
      }
      if (pref != null) {
        for (final t in pref.tastePreferences) {
          if (f.tags.contains(t)) s += 2;
        }
        for (final c in pref.favoriteCuisines) {
          if (f.cuisines.contains(c)) s += 3;
        }
      }
      return s;
    }

    list.sort((a, b) => score(b).compareTo(score(a)));
    return list.take(3).toList();
  }

  void _addBot(String text, {List<Food>? foods}) {
    setState(() {
      _messages.add(
        Message(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          suggestedFoods: foods,
        ),
      );
    });
    _scrollDown();
  }

  void _addUser(String text) {
    setState(() {
      _messages.add(
        Message(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollDown();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    _addUser(text);

    // Tin nhắn đầu tiên = người dùng tự mô tả trạng thái của mình
    final isMoodShare = !_moodCollected;
    if (isMoodShare) setState(() => _moodCollected = true);

    final prompt = isMoodShare
        ? 'Người dùng vừa chia sẻ trạng thái hiện tại: "$text". '
              'Hãy đồng cảm ngắn gọn, khuyên kiểu món nên ăn/nên tránh phù hợp với trạng thái đó, '
              'gợi ý một món ăn cụ thể phù hợp nhất và hướng dẫn nấu chi tiết các bước (gồm nguyên liệu và các bước thực hiện).'
        : text;

    setState(() => _typing = true);
    final reply = await GeminiService.chat(prompt);
    if (!mounted) return;
    setState(() => _typing = false);
    _addBot(reply, foods: _matchFoods(text, reply));
  }

  List<Food> _matchFoods(String userMsg, String aiReply) {
    final q = '${userMsg} ${aiReply}';
    final normalizedQ = TextUtils.normalize(q);
    final all = List<Food>.from(FoodsData.all);

    final mentioned = all
        .where((f) => normalizedQ.contains(TextUtils.normalize(f.name)))
        .toList();
    if (mentioned.isNotEmpty) {
      return mentioned.take(3).toList();
    }

    final isSeafoodQuery =
        normalizedQ.contains('ca') ||
        normalizedQ.contains('fish') ||
        normalizedQ.contains('seafood') ||
        normalizedQ.contains('hai san') ||
        normalizedQ.contains('tom') ||
        normalizedQ.contains('cua');

    if (isSeafoodQuery) {
      final seafood = all
          .where(
            (f) =>
                f.tags.contains('seafood') ||
                TextUtils.normalize(f.description).contains('ca') ||
                TextUtils.normalize(f.description).contains('tom') ||
                TextUtils.normalize(f.description).contains('cua') ||
                TextUtils.normalize(f.description).contains('hai san'),
          )
          .toList();
      if (seafood.isNotEmpty) {
        return seafood.take(3).toList();
      }
    }

    if (normalizedQ.contains('met') ||
        normalizedQ.contains('stress') ||
        normalizedQ.contains('ap luc') ||
        normalizedQ.contains('buon')) {
      final light = all
          .where(
            (f) =>
                f.tags.contains('light') ||
                f.tags.contains('healthy') ||
                f.tags.contains('fresh'),
          )
          .toList();
      return (light.isEmpty ? const <Food>[] : light).take(3).toList();
    }
    if (normalizedQ.contains('doi') ||
        normalizedQ.contains('them') ||
        normalizedQ.contains('bung')) {
      final hearty = all.where((f) => f.calories > 400).toList();
      return (hearty.isEmpty ? const <Food>[] : hearty).take(3).toList();
    }
    if (normalizedQ.contains('cay') || normalizedQ.contains('spicy')) {
      final spicy = all.where((f) => f.tags.contains('spicy')).toList();
      return (spicy.isEmpty ? const <Food>[] : spicy).take(3).toList();
    }

    final hour = DateTime.now().hour;
    if (normalizedQ.contains('sang') || hour < 10) {
      return all
          .where((f) => f.mealType == 'breakfast' || f.mealType == 'any')
          .take(3)
          .toList();
    }
    if (normalizedQ.contains('trua') || (hour >= 10 && hour < 15)) {
      return all
          .where((f) => f.mealType == 'lunch' || f.mealType == 'any')
          .take(3)
          .toList();
    }
    if (normalizedQ.contains('toi') || hour >= 18) {
      return all
          .where((f) => f.mealType == 'dinner' || f.mealType == 'any')
          .take(3)
          .toList();
    }

    return const <Food>[];
  }

  Future<void> _onFoodTapped(Food food) async {
    // Navigate to detail screen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );

    // Show user "selected" message and get AI commentary
    _addUser('${food.emoji} ${food.name}');
    setState(() => _typing = true);

    final lastUserMsg = _messages
        .lastWhere(
          (m) => m.isUser && m.text != '${food.emoji} ${food.name}',
          orElse: () =>
              Message(text: '', isUser: true, timestamp: DateTime.now()),
        )
        .text;

    final prompt =
        'Người dùng vừa chọn xem món ${food.name} ${food.emoji} (${food.calories} kcal, ${food.difficulty}). '
        'Dựa trên ngữ cảnh trước đó: "$lastUserMsg". '
        'Nhận xét cực ngắn 1-2 câu: món này có phù hợp không, 1 lợi ích nhỏ hoặc lưu ý khi ăn. '
        'Nếu không phù hợp lắm, gợi ý ngắn 1 món khác tốt hơn.';

    final reply = await GeminiService.chat(prompt);
    if (!mounted) return;
    setState(() => _typing = false);
    _addBot(reply);
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset('chatbot.png', width: 28, height: 28),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MamGo bot',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Trợ lý ẩm thực AI',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Cuộc hội thoại mới',
            onPressed: () {
              setState(() {
                _messages.clear();
                _moodCollected = false;
              });
              final pref = context.read<UserPreferenceProvider>().preference;
              GeminiService.reset(pref);
              _sendGreeting();
            },
          ),
          if (widget.isPopup)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: 'Đóng',
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_typing && i == _messages.length) {
                        return _typingIndicator();
                      }
                      return ChatBubble(
                        message: _messages[i],
                        onFoodTap: _onFoodTapped,
                      );
                    },
                  ),
          ),
          _moodCollected ? _quickActionsBar() : _moodChipsBar(),
          _inputBar(),
        ],
      ),
    );
  }

  /// Chip chọn trạng thái khi mới vào chat (người dùng cũng có thể tự nhập).
  Widget _moodChipsBar() {
    return Container(
      height: 46,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _moodOptions.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => _selectMood(i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.1),
                    AppTheme.orange.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Center(
                child: Text(
                  _moodOptions[i].$1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('chatbot.png', width: 80, height: 80),
          const SizedBox(height: 12),
          const Text(
            'MamGo đang khởi động...',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset('chatbot.png', width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + i * 150),
      builder: (_, v, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.4 + 0.6 * v),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _quickActionsBar() {
    return Container(
      height: 46,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _quickActions.length,
        itemBuilder: (_, i) {
          final action = _quickActions[i];
          return GestureDetector(
            onTap: () => _send(action.$2),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  action.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Hỏi MamGo về ăn uống...',
                hintStyle: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F0EB),
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: _send,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(_ctrl.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
