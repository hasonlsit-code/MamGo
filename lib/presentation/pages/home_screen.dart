import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/data/models/food.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/bot_settings_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/widgets/animated_mascot.dart';
import 'package:mamgo/presentation/widgets/floating_bot.dart';
import 'package:mamgo/presentation/widgets/food_card.dart';
import 'package:mamgo/presentation/pages/chatbot_screen.dart';
import 'package:mamgo/presentation/pages/meal_analysis_screen.dart';
import 'package:mamgo/presentation/pages/recipe_library_screen.dart';
import 'package:mamgo/presentation/pages/notification_settings_screen.dart';
import 'package:mamgo/presentation/pages/notifications_screen.dart';
import 'package:mamgo/presentation/pages/food_detail_screen.dart';
import 'package:mamgo/presentation/pages/profile_screen.dart';

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
    final user = context.read<AuthProvider>().user;
    final pref = context.read<UserPreferenceProvider>().preference;
    final name = (user?.name.isNotEmpty == true)
        ? user!.name
        : (pref?.name.isNotEmpty == true ? pref!.name : 'bạn');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _HealthGreetingDialog(name: name),
    );
  }

  static const _navItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
    BottomNavigationBarItem(
        icon: Icon(Icons.lightbulb_outline_rounded), label: 'Đo lường'),
    BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_rounded), label: 'Cẩm nang'),
    BottomNavigationBarItem(
        icon: Icon(Icons.smart_toy_outlined), label: 'Chatbot'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded), label: 'Hồ sơ'),
  ];

  List<Widget> get _screens => [
        _HomeTab(onSwitchTab: (i) => setState(() => _tab = i)),
        const MealAnalysisScreen(),
        const RecipeLibraryScreen(),
        const ChatbotScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final botEnabled = context.watch<BotSettingsProvider>().enabled;
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          // MamGo bot nổi xuyên suốt app (ẩn ở tab Chatbot để tránh trùng lặp)
          Positioned(
            right: 16,
            bottom: 20,
            child: SafeArea(
              child: Visibility(
                visible: botEnabled && _tab != 3,
                maintainState: true,
                child: const FloatingBot(),
              ),
            ),
          ),
        ],
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

class _HomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _HomeTab({required this.onSwitchTab});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pref = context.watch<UserPreferenceProvider>().preference;
    final name = (user?.name.isNotEmpty == true)
        ? user!.name
        : (pref?.name.isNotEmpty == true ? pref!.name : 'bạn');

    final now = DateTime.now();
    final meal = _NextMealInfo.compute(
      now,
      breakfast: pref?.breakfastTime ?? '07:00',
      lunch: pref?.lunchTime ?? '12:00',
      dinner: pref?.dinnerTime ?? '18:30',
    );

    final suggestions = _buildSuggestions(pref);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, name),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _buildNextMealCard(meal),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProBanner(context),
            ),
            const SizedBox(height: 24),
            _sectionHeader(
              icon: Icons.restaurant_menu_rounded,
              iconColor: AppTheme.success,
              title: 'Gợi ý món ngon cho bạn',
              actionLabel: 'Xem tất cả',
              onAction: () => widget.onSwitchTab(2),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 248,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                itemBuilder: (_, i) => FoodCard(
                  food: suggestions[i],
                  onTap: () => Navigator.push(
                    context,
                    _premiumRoute(FoodDetailScreen(food: suggestions[i])),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader(
              icon: Icons.schedule_rounded,
              iconColor: AppTheme.orange,
              title: 'Lịch ăn hôm nay',
              actionLabel: 'Điều chỉnh nhắc nhở',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTodaySchedule(now, pref),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ── Header: logo + tên app + chuông + lời chào ─────────────────────────────
  Widget _buildHeader(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chúc bạn buổi sáng tốt lành!'
        : hour < 18
            ? 'Chúc bạn buổi chiều vui vẻ!'
            : 'Chúc bạn buổi tối ấm áp!';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnimatedMascot(size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        children: [
                          TextSpan(
                              text: 'Mam',
                              style: TextStyle(color: AppTheme.primary)),
                          TextSpan(
                              text: 'Go',
                              style: TextStyle(color: AppTheme.orange)),
                        ],
                      ),
                    ),
                    const Text(
                      'Ăn đúng giờ, sống khỏe mỗi ngày',
                      style: TextStyle(
                          color: AppTheme.textMedium, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildBell(),
            ],
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 22, color: AppTheme.textDark),
              children: [
                const TextSpan(text: 'Xin chào, '),
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const TextSpan(text: ' 👋'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            greeting,
            style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBell() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.notifications_none_rounded,
                  color: AppTheme.textDark, size: 24),
            ),
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Thẻ bữa tiếp theo (gradient cam) ───────────────────────────────────────
  Widget _buildNextMealCard(_NextMealInfo meal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Khối giờ ăn bên trái
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.orangeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Bữa tiếp theo',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  meal.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  meal.time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Nội dung bên phải
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Còn ${meal.countdown} nữa là đến ${meal.mealName}',
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Đừng quên ăn đúng giờ nhé!',
                          style: TextStyle(
                              color: AppTheme.textMedium, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: meal.progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFFFE5CC),
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: meal.photoUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                          width: 58,
                          height: 58,
                          color: const Color(0xFFFFF3E5)),
                      errorWidget: (_, _, _) => Container(
                        width: 58,
                        height: 58,
                        color: const Color(0xFFFFF3E5),
                        child: const Center(
                            child:
                                Text('🥗', style: TextStyle(fontSize: 28))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner giới thiệu gói Pro ──────────────────────────────────────────────
  Widget _buildProBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🎉 Gói Pro sắp ra mắt, hãy chờ đón nhé!')),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFFFF8A00)],
            stops: [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'MamGo Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFFFFE082), size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đăng ký gói Pro ngay để mở khóa phân tích dinh dưỡng '
                    'không giới hạn, thực đơn cá nhân hóa & nhiều hơn nữa!',
                    style: TextStyle(
                        color: Colors.white, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Nâng cấp ngay ✨',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lịch ăn hôm nay ────────────────────────────────────────────────────────
  Widget _buildTodaySchedule(DateTime now, dynamic pref) {
    final meals = [
      ('Bữa sáng', pref?.breakfastTime ?? '07:00'),
      ('Bữa trưa', pref?.lunchTime ?? '12:00'),
      ('Bữa tối', pref?.dinnerTime ?? '18:30'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Column(
        children: List.generate(meals.length, (i) {
          final (label, time) = meals[i];
          final t = _NextMealInfo.parseToday(now, time);
          final done = now.isAfter(t);
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < meals.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Color(0xFFEFF3F9)))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: done ? AppTheme.success : AppTheme.textMedium,
                  size: 22,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        color: AppTheme.textDark, fontSize: 14),
                  ),
                ),
                Text(
                  done ? 'Đã hoàn thành' : 'Sắp tới',
                  style: TextStyle(
                    color: done ? AppTheme.success : AppTheme.orange,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Tiện ích ───────────────────────────────────────────────────────────────
  List<Food> _buildSuggestions(dynamic pref) {
    final hour = DateTime.now().hour;
    final mealType =
        hour < 10 ? 'breakfast' : hour < 15 ? 'lunch' : 'dinner';

    List<Food> list = FoodsData.all
        .where((f) => f.mealType == mealType || f.mealType == 'any')
        .toList();

    int score(Food f) {
      int s = 0;
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
    return list.take(8).toList();
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.primary, size: 18),
                ],
              ),
            ),
        ],
      ),
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
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}

// ─── Thông tin bữa tiếp theo ──────────────────────────────────────────────────

class _NextMealInfo {
  final String label; // SÁNG | TRƯA | TỐI
  final String mealName; // bữa sáng | bữa trưa | bữa tối
  final String time; // HH:mm
  final String countdown; // "2h 18m"
  final double progress; // 0..1 giữa bữa trước và bữa tiếp theo
  final String photoUrl;

  const _NextMealInfo({
    required this.label,
    required this.mealName,
    required this.time,
    required this.countdown,
    required this.progress,
    required this.photoUrl,
  });

  // Ảnh thật minh họa cho từng bữa
  static const _photos = {
    'SÁNG':
        'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=300&h=300&fit=crop&q=80',
    'TRƯA':
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&h=300&fit=crop&q=80',
    'TỐI':
        'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=300&h=300&fit=crop&q=80',
  };

  static DateTime parseToday(DateTime now, String hhmm) {
    final parts = hhmm.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  static _NextMealInfo compute(
    DateTime now, {
    required String breakfast,
    required String lunch,
    required String dinner,
  }) {
    final meals = [
      ('SÁNG', 'bữa sáng', breakfast, parseToday(now, breakfast)),
      ('TRƯA', 'bữa trưa', lunch, parseToday(now, lunch)),
      ('TỐI', 'bữa tối', dinner, parseToday(now, dinner)),
    ];

    (String, String, String, DateTime)? next;
    DateTime prev = DateTime(now.year, now.month, now.day); // 00:00
    for (final m in meals) {
      if (m.$4.isAfter(now)) {
        next = m;
        break;
      }
      prev = m.$4;
    }
    // Đã qua bữa tối → bữa tiếp theo là bữa sáng ngày mai
    next ??= (
      'SÁNG',
      'bữa sáng',
      breakfast,
      parseToday(now, breakfast).add(const Duration(days: 1)),
    );

    final remaining = next.$4.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final countdown = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    final total = next.$4.difference(prev).inMinutes;
    final elapsed = now.difference(prev).inMinutes;
    final progress =
        total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);

    return _NextMealInfo(
      label: next.$1,
      mealName: next.$2,
      time: next.$3,
      countdown: countdown,
      progress: progress,
      photoUrl: _photos[next.$1]!,
    );
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
