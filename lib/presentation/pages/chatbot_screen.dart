import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/data/models/food.dart';
import 'package:mamgo/data/models/message.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/food_detail_screen.dart';
import 'package:mamgo/data/datasources/gemini_service.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/widgets/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  /// true khi mở dạng popup từ MamGo bot nổi (hiện nút đóng).
  final bool isPopup;
  const ChatbotScreen({super.key, this.isPopup = false});

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
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
    (
      '😊 Vui vẻ',
      <String>[],
      <String>[],
      'Yeah, tâm trạng tốt thì ăn gì cũng ngon! 🎉 '
          'Đây là những món mình chọn riêng để bữa ăn của bạn thêm trọn vẹn nè 😋\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
    (
      '😰 Căng thẳng',
      ['light', 'fresh', 'soup'],
      ['spicy', 'crispy'],
      'Hít thở sâu nào bạn ơi 🌿 Lúc căng thẳng nên ăn món thanh đạm, dễ chịu — '
          'tránh đồ cay và chiên rán nha. Thử mấy món này cho nhẹ bụng nè 💙\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
    (
      '💼 Bận rộn',
      ['quick'],
      <String>[],
      'Bận rộn thì để mình lo! ⚡ Đây là các món nhanh gọn, dễ làm '
          'mà vẫn đủ chất cho bạn nè 🍱\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
    (
      '🥗 Muốn healthy',
      ['healthy', 'fresh', 'light'],
      ['rich', 'crispy'],
      'Quá chuẩn luôn! 🥗 Đây là những món healthy ít calo, tươi xanh '
          'giúp bạn khỏe đẹp mỗi ngày nè ✨\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
    (
      '😋 Đói bụng',
      <String>[],
      <String>[],
      'Đói thì phải ăn no nê liền! 😋 Đây là mấy món "chắc bụng" '
          'mình gợi ý cho bạn nè 🍚\n\n'
          'Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!'
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendGreeting());
  }

  void _sendGreeting() {
    final pref = context.read<UserPreferenceProvider>().preference;
    GeminiService.initialize(pref);
    final name = pref?.name ?? 'bạn';
    _addBot('Xin chào $name! 👋 Mình là MamGo bot đây!\n\n'
        'Hôm nay bạn đang cảm thấy thế nào? Chọn nhanh bên dưới '
        'hoặc kể cho mình nghe nhé 💙');
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

  List<Food> _foodsForMood(List<String> prefer, List<String> avoid,
      {bool isHungry = false}) {
    final pref = context.read<UserPreferenceProvider>().preference;
    var list = FoodsData.all
        .where((f) => !f.tags.any(avoid.contains))
        .toList()
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
      _messages.add(Message(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          suggestedFoods: foods));
    });
    _scrollDown();
  }

  void _addUser(String text) {
    setState(() {
      _messages.add(
          Message(text: text, isUser: true, timestamp: DateTime.now()));
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
            'Hãy đồng cảm ngắn gọn, khuyên kiểu món nên ăn/nên tránh phù hợp '
            'với trạng thái đó, và kết thúc bằng câu: '
            '"Nếu cần hỗ trợ gì thêm hãy nhắn cho mình biết nhé!"'
        : text;

    setState(() => _typing = true);
    final reply = await GeminiService.chat(prompt);
    if (!mounted) return;
    setState(() => _typing = false);
    _addBot(reply, foods: _matchFoods(text, reply));
  }

  List<Food> _matchFoods(String userMsg, String aiReply) {
    final q = '${userMsg.toLowerCase()} ${aiReply.toLowerCase()}';
    final all = List<Food>.from(FoodsData.all)..shuffle();

    // Try to find foods mentioned by name in the reply
    final mentioned = all
        .where((f) => q.contains(f.name.toLowerCase()))
        .take(3)
        .toList();
    if (mentioned.length >= 2) return mentioned;

    // Mood/keyword matching
    if (q.contains('mệt') ||
        q.contains('stress') ||
        q.contains('áp lực') ||
        q.contains('buồn')) {
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
    if (q.contains('vui') || q.contains('hạnh phúc') || q.contains('tốt')) {
      return all.take(3).toList();
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
    if (q.contains('tối') || hour >= 18) {
      return all
          .where((f) => f.mealType == 'dinner' || f.mealType == 'any')
          .take(3)
          .toList();
    }
    return all.take(3).toList();
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
        .lastWhere((m) => m.isUser && m.text != '${food.emoji} ${food.name}',
            orElse: () => Message(
                text: '', isUser: true, timestamp: DateTime.now()))
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
              child: const Text('🤖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MamGo bot',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                Text('Trợ lý ẩm thực AI',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
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
              final pref =
                  context.read<UserPreferenceProvider>().preference;
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
                    color: AppTheme.primary.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: Text(_moodOptions[i].$1,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🤖', style: TextStyle(fontSize: 80)),
          SizedBox(height: 12),
          Text('MamGo đang khởi động...',
              style: TextStyle(color: AppTheme.textMedium, fontSize: 16)),
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
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6, offset: const Offset(0, 2))
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
        width: 8, height: 8,
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
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(action.$1,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
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
                hintStyle: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
