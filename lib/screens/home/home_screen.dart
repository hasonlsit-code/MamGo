import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/foods_data.dart';
import '../../data/recipes_data.dart';
import '../../models/food.dart';
import '../../providers/user_preference_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_mascot.dart';
import '../../widgets/food_card.dart';
import '../../widgets/home_mini_chat.dart';
import '../../widgets/recipe_card.dart';
import '../chatbot/chatbot_screen.dart';
import '../recipes/recipe_detail_screen.dart';
import '../recipes/recipe_library_screen.dart';
import '../settings/notification_settings_screen.dart';
import 'food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showHealthGreeting();
      });
    });
  }

  void _showHealthGreeting() {
    final pref = context.read<UserPreferenceProvider>().preference;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _HealthGreetingDialog(name: pref?.name ?? 'bạn'),
    );
  }

  static const _navItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
    BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_rounded), label: 'MamGo'),
    BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_rounded), label: 'Thư viện'),
    BottomNavigationBarItem(
        icon: Icon(Icons.notifications_rounded), label: 'Nhắc nhở'),
  ];

  List<Widget> get _screens => [
        _HomeTab(onSwitchTab: (i) => setState(() => _tab = i)),
        const ChatbotScreen(),
        const RecipeLibraryScreen(),
        const NotificationSettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.backgroundGradient,
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: IndexedStack(index: _tab, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMedium,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: _navItems,
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final void Function(int) onSwitchTab;
  const _HomeTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<UserPreferenceProvider>().preference;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';
    final mealType =
        hour < 10 ? 'breakfast' : hour < 15 ? 'lunch' : 'dinner';
    final mealLabel =
        hour < 10 ? 'bữa sáng' : hour < 15 ? 'bữa trưa' : 'bữa tối';

    List<Food> suggestions = FoodsData.all
        .where((f) => f.mealType == mealType || f.mealType == 'any')
        .toList();
    if (pref != null) {
      suggestions.sort((a, b) {
        int scoreA = _score(a, pref.tastePreferences, pref.favoriteCuisines);
        int scoreB = _score(b, pref.tastePreferences, pref.favoriteCuisines);
        return scoreB.compareTo(scoreA);
      });
    }
    final top = suggestions.take(8).toList();
    final recipes = RecipesData.all.take(5).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, pref?.name ?? 'bạn', greeting),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mini Chat ────────────────────────────────
              const SizedBox(height: 16),
              const HomeMiniChat(),

              // ── Meal banner ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _mealBanner(mealLabel, mealType),
              ),

              // ── Food suggestions ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: _sectionHeader(
                    context, 'Gợi ý $mealLabel hôm nay 🍽️'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 248,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: top.length,
                  itemBuilder: (_, i) => FoodCard(
                    food: top[i],
                    onTap: () => Navigator.push(
                      context,
                      _premiumRoute(FoodDetailScreen(food: top[i])),
                    ),
                  ),
                ),
              ),

              // ── Recipe library ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                child: _sectionHeader(
                  context,
                  '📖 Thư viện công thức',
                  onSeeAll: () => onSwitchTab(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recipes
                      .map((r) => RecipeCard(
                            recipe: r,
                            onTap: () => Navigator.push(
                              context,
                              _premiumRoute(RecipeDetailScreen(recipe: r)),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ],
    );
  }

  PageRouteBuilder _premiumRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, String name, String greeting) {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles (premium feel)
            Positioned(
              top: -30,
              right: 70,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: -18,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              left: 180,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _formatDate(DateTime.now()),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$greeting,',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const AnimatedMascot(size: 66),
                  ],
                ),
              ),
            ),
          ],
        ),
        title: const Text(
          'MămGo',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
      ),
    );
  }

  Widget _mealBanner(String label, String mealType) {
    final emojis = {
      'breakfast': '🌅',
      'lunch': '☀️',
      'dinner': '🌙'
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emojis[mealType] ?? '🍽️',
              style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đến giờ $label!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text(
                  'MămGo đã chuẩn bị gợi ý ngon cho bạn 😋',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title,
      {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
            letterSpacing: 0.1,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const days = [
      'CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'
    ];
    const months = [
      '', 'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5',
      'tháng 6', 'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10',
      'tháng 11', 'tháng 12'
    ];
    return '${days[d.weekday % 7]}, ${d.day} ${months[d.month]}';
  }

  int _score(Food food, List<String> tastes, List<String> cuisines) {
    int s = 0;
    for (final t in tastes) {
      if (food.tags.contains(t)) s += 2;
    }
    for (final c in cuisines) {
      if (food.cuisines.contains(c)) s += 3;
    }
    return s;
  }
}

// ─── Health Greeting Dialog ───────────────────────────────────────────────────

class _HealthGreetingDialog extends StatefulWidget {
  final String name;
  const _HealthGreetingDialog({required this.name});

  @override
  State<_HealthGreetingDialog> createState() => _HealthGreetingDialogState();
}

class _HealthGreetingDialogState extends State<_HealthGreetingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _showOptions = false;
  int? _selected;

  static const _options = [
    {
      'emoji': '💪',
      'label': 'Rất khỏe!',
      'reply': 'Tuyệt vời! Hãy ăn thật ngon hôm nay nhé 🎉'
    },
    {
      'emoji': '😊',
      'label': 'Bình thường',
      'reply': 'Ổn thôi cũng tốt! MămGo lo bữa ăn cho bạn 😊'
    },
    {
      'emoji': '😴',
      'label': 'Hơi mệt',
      'reply': 'Nghỉ ngơi chút nhé! MămGo gợi ý món bổ dưỡng 🍲'
    },
    {
      'emoji': '🤒',
      'label': 'Không khỏe',
      'reply': 'Chúc bạn mau khỏe! Hãy ăn nhẹ và nghỉ ngơi 🌿'
    },
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showOptions = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedMascot(size: 96),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Xin chào ',
                            style: TextStyle(
                                fontSize: 20, color: AppTheme.textDark),
                          ),
                          TextSpan(
                            text: widget.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          const TextSpan(
                            text: '! 👋',
                            style: TextStyle(
                                fontSize: 20, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hôm nay bạn cảm thấy thế nào?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.textMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _selected != null
                  ? _buildReply()
                  : _showOptions
                      ? _buildOptions()
                      : const SizedBox(
                          height: 60,
                          child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary),
                          ),
                        ),
            ),
            if (_selected == null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Bỏ qua',
                    style: TextStyle(
                        color: AppTheme.textMedium, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Wrap(
      key: const ValueKey('options'),
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_options.length, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => _selected = i);
            Future.delayed(const Duration(milliseconds: 1600), () {
              if (mounted) Navigator.of(context).pop();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.chipBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_options[i]['emoji']!,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  _options[i]['label']!,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReply() {
    return Container(
      key: const ValueKey('reply'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.chipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Text(_options[_selected!]['emoji']!,
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _options[_selected!]['reply']!,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
