import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/data/datasources/foods_data.dart';
import 'package:mamgo/data/datasources/notification_log_service.dart';
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
  final String? chatbotPayload;
  const HomeScreen({super.key, this.initialTab = 0, this.chatbotPayload});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _tab;
  // Vị trí icon MamGo bot do người dùng kéo thả (null = góc dưới phải mặc định)
  Offset? _botOffset;
  // Điểm ngón tay chạm bên trong icon lúc bắt đầu kéo
  Offset _botGrab = Offset.zero;
  static const _botSize = 58.0;

  String? _activePayload;
  Timer? _inAppNotificationTimer;
  // Các "key" (ngày_loại) đã kích hoạt hôm nay, tránh bắn trùng nhiều lần
  // trong cùng 1 phút do timer kiểm tra mỗi 10 giây.
  final Set<String> _firedKeys = {};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _activePayload = widget.chatbotPayload;
    _startInAppNotificationTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showProPromo();
      });
    });
  }

  @override
  void dispose() {
    _inAppNotificationTimer?.cancel();
    super.dispose();
  }

  void _startInAppNotificationTimer() {
    _inAppNotificationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) {
      if (mounted) _checkInAppNotifications();
    });
  }

  void _checkInAppNotifications() {
    // now = đồng hồ thật của máy tại đúng thời điểm kiểm tra → mọi log ghi
    // ra đều khớp với thời gian đang hiển thị trên điện thoại.
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    // Dọn key của các ngày cũ, chỉ giữ lại key hôm nay
    _firedKeys.removeWhere((k) => !k.startsWith(todayStr));

    bool isTimeMatch(int hour, int minute) =>
        now.hour == hour && now.minute == minute;

    // Chúc buổi sáng (giờ cố định 06:30, khớp thông báo hệ thống mặc định)
    if (isTimeMatch(6, 30)) {
      final key = '${todayStr}_morning';
      if (_firedKeys.add(key)) {
        NotificationLogService.log(
          emoji: '☀️',
          title: 'Chào buổi sáng!',
          body:
              'Chúc bạn một ngày tốt lành! Nhớ ăn uống đầy đủ để khỏe mạnh nhé 🍀',
          time: now,
        );
      }
    }

    final pref = context.read<UserPreferenceProvider>().preference;
    if (pref == null) return;

    bool matchesSetting(String timeStr) {
      final parts = timeStr.split(':');
      if (parts.length < 2) return false;
      return isTimeMatch(
        int.tryParse(parts[0]) ?? -1,
        int.tryParse(parts[1]) ?? -1,
      );
    }

    String? triggeredMeal;
    String? triggeredPayload;
    String? mealName;

    if (pref.breakfastReminder && matchesSetting(pref.breakfastTime)) {
      triggeredMeal = 'breakfast';
      triggeredPayload = 'meal_breakfast';
      mealName = 'bữa sáng';
    } else if (pref.lunchReminder && matchesSetting(pref.lunchTime)) {
      triggeredMeal = 'lunch';
      triggeredPayload = 'meal_lunch';
      mealName = 'bữa trưa';
    } else if (pref.dinnerReminder && matchesSetting(pref.dinnerTime)) {
      triggeredMeal = 'dinner';
      triggeredPayload = 'meal_dinner';
      mealName = 'bữa tối';
    }

    if (triggeredMeal != null && triggeredPayload != null && mealName != null) {
      final key = '${todayStr}_$triggeredMeal';
      if (_firedKeys.add(key)) {
        NotificationLogService.log(
          emoji: '🍽️',
          title: 'Đến giờ $mealName rồi!',
          body: 'MămGo có nhiều gợi ý ngon cho bạn hôm nay! 😋',
          time: now,
        );
        _showInAppMealNotification(mealName, triggeredPayload);
      }
    }
  }

  void _showInAppMealNotification(String mealName, String payload) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔔', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Đến giờ $mealName rồi!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'MămGo đã chuẩn bị sẵn các gợi ý món ăn dinh dưỡng dành riêng cho bạn. Trò chuyện với Bot để xem gợi ý nhé!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Để sau',
                          style: TextStyle(color: AppTheme.textMedium),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _activePayload = payload;
                            _tab = 3; // Switch to Chatbot tab
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xem gợi ý',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProPromo() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _ProPromoDialog(
        onUpgrade: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Gói Pro sắp ra mắt, hãy chờ đón nhé!'),
            ),
          );
        },
      ),
    );
  }

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
    BottomNavigationBarItem(
      icon: Icon(Icons.lightbulb_outline_rounded),
      label: 'Đo lường',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_rounded),
      label: 'Cẩm nang',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.smart_toy_outlined),
      label: 'Chatbot',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      label: 'Hồ sơ',
    ),
  ];

  List<Widget> get _screens => [
    _HomeTab(onSwitchTab: (i) => setState(() => _tab = i)),
    const MealAnalysisScreen(),
    const RecipeLibraryScreen(),
    ChatbotScreen(
      initialPayload: _activePayload,
      onPayloadConsumed: () {
        setState(() {
          _activePayload = null;
        });
      },
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final botEnabled = context.watch<BotSettingsProvider>().enabled;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          // Mặc định góc dưới phải; sau đó theo vị trí người dùng kéo thả
          final pos =
              _botOffset ??
              Offset(
                box.maxWidth - _botSize - 16,
                box.maxHeight - _botSize - 20,
              );
          return Stack(
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
              // MamGo bot nổi xuyên suốt app (ẩn ở tab Chatbot để tránh trùng
              // lặp). Kéo thả tự do, tự giới hạn trong màn hình.
              Positioned(
                left: pos.dx,
                top: pos.dy,
                child: Visibility(
                  visible: botEnabled && _tab != 3,
                  maintainState: true,
                  child: GestureDetector(
                    onPanStart: (d) => _botGrab = d.localPosition,
                    // Bám theo tọa độ ngón tay 1:1 (không cộng dồn delta
                    // để tránh trễ khi kéo nhanh)
                    onPanUpdate: (d) => setState(() {
                      final next = d.globalPosition - _botGrab;
                      _botOffset = Offset(
                        next.dx.clamp(4.0, box.maxWidth - _botSize - 4),
                        next.dy.clamp(topPad + 4, box.maxHeight - _botSize - 4),
                      );
                    }),
                    child: const FloatingBot(),
                  ),
                ),
              ),
            ],
          );
        },
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
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
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
              child: _NextMealCard(
                breakfast: pref?.breakfastTime ?? '07:00',
                lunch: pref?.lunchTime ?? '12:00',
                dinner: pref?.dinnerTime ?? '18:30',
              ),
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
              height: 256,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 12,
                ),
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
                  builder: (_) => const NotificationSettingsScreen(),
                ),
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
                            style: TextStyle(color: AppTheme.primary),
                          ),
                          TextSpan(
                            text: 'Go',
                            style: TextStyle(color: AppTheme.orange),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Ăn đúng giờ, sống khỏe mỗi ngày',
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 12,
                      ),
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
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
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
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.textDark,
                size: 24,
              ),
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

  // ── Banner giới thiệu gói Pro ──────────────────────────────────────────────
  Widget _buildProBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Gói Pro sắp ra mắt, hãy chờ đón nhé!'),
        ),
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
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 30,
              ),
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
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFE082),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đăng ký gói Pro ngay để mở khóa phân tích dinh dưỡng '
                    'không giới hạn, thực đơn cá nhân hóa & nhiều hơn nữa!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < meals.length - 1
                  ? const Border(bottom: BorderSide(color: Color(0xFFEFF3F9)))
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
                      color: AppTheme.textDark,
                      fontSize: 14,
                    ),
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
    final mealType = hour < 10
        ? 'breakfast'
        : hour < 15
        ? 'lunch'
        : 'dinner';

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
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
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
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}

// ─── Thẻ bữa tiếp theo: tự tick đếm ngược giờ:phút:giây mỗi giây ──────────────

class _NextMealCard extends StatefulWidget {
  final String breakfast;
  final String lunch;
  final String dinner;
  const _NextMealCard({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  @override
  State<_NextMealCard> createState() => _NextMealCardState();
}

class _NextMealCardState extends State<_NextMealCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick mỗi giây để đồng hồ đếm ngược chạy thật (giờ:phút:giây) theo
    // đúng đồng hồ máy, không phải giá trị tính 1 lần rồi đứng yên.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = _NextMealInfo.compute(
      DateTime.now(),
      breakfast: widget.breakfast,
      lunch: widget.lunch,
      dinner: widget.dinner,
    );

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
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
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
                        const SizedBox(height: 5),
                        // Đồng hồ đếm ngược tích tắc giờ:phút:giây
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 13,
                                color: AppTheme.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal.digitalCountdown,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.orange,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: meal.progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFFFE5CC),
                            valueColor: const AlwaysStoppedAnimation(
                              AppTheme.orange,
                            ),
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
                        color: const Color(0xFFFFF3E5),
                      ),
                      errorWidget: (_, _, _) => Container(
                        width: 58,
                        height: 58,
                        color: const Color(0xFFFFF3E5),
                        child: const Center(
                          child: Text('🥗', style: TextStyle(fontSize: 28)),
                        ),
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
}

// ─── Thông tin bữa tiếp theo ──────────────────────────────────────────────────

class _NextMealInfo {
  final String label; // SÁNG | TRƯA | TỐI
  final String mealName; // bữa sáng | bữa trưa | bữa tối
  final String time; // HH:mm
  final String countdown; // "2h 18m"
  final String digitalCountdown; // "02:18:07" — tích tắc từng giây
  final double progress; // 0..1 giữa bữa trước và bữa tiếp theo
  final String photoUrl;

  const _NextMealInfo({
    required this.label,
    required this.mealName,
    required this.time,
    required this.countdown,
    required this.digitalCountdown,
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
    final seconds = remaining.inSeconds % 60;
    final countdown = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    final digitalCountdown =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final total = next.$4.difference(prev).inMinutes;
    final elapsed = now.difference(prev).inMinutes;
    final progress = total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);

    return _NextMealInfo(
      label: next.$1,
      mealName: next.$2,
      time: next.$3,
      countdown: countdown,
      digitalCountdown: digitalCountdown,
      progress: progress,
      photoUrl: _photos[next.$1]!,
    );
  }
}

// ─── Pro Promo Dialog ─────────────────────────────────────────────────────────

class _ProPromoDialog extends StatefulWidget {
  final VoidCallback onUpgrade;
  const _ProPromoDialog({required this.onUpgrade});

  @override
  State<_ProPromoDialog> createState() => _ProPromoDialogState();
}

class _ProPromoDialogState extends State<_ProPromoDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  static const _benefits = [
    (Icons.camera_alt_rounded, 'Phân tích bữa ăn AI không giới hạn'),
    (Icons.restaurant_menu_rounded, 'Thực đơn cá nhân hoá theo khẩu vị'),
    (Icons.smart_toy_rounded, 'Trò chuyện ưu tiên với MamGo bot'),
    (Icons.block_rounded, 'Trải nghiệm hoàn toàn không quảng cáo'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      clipBehavior: Clip.none,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Thẻ nội dung chính
              Container(
                margin: const EdgeInsets.only(top: 34),
                padding: const EdgeInsets.fromLTRB(24, 46, 24, 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1E88E5),
                      Color(0xFFFF8A00),
                    ],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFFFE082),
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'ƯU ĐÃI THÀNH VIÊN MỚI',
                            style: TextStyle(
                              color: Color(0xFFFFE082),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                        children: [
                          TextSpan(
                            text: 'MamGo ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Pro',
                            style: TextStyle(color: Color(0xFFFFE082)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mở khoá toàn bộ trải nghiệm ẩm thực\nAI cá nhân hoá dành riêng cho bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _benefits
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      b.$1,
                                      color: const Color(0xFFFFE082),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        b.$2,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '19.000đ',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '9.000đ',
                          style: TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 3, left: 3),
                          child: Text(
                            '/ tháng',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onUpgrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Nâng cấp ngay ✨',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Để sau',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge vương miện nổi phía trên thẻ
              const Positioned(
                top: -4,
                left: 0,
                right: 0,
                child: Center(child: _CrownBadge()),
              ),
              // Nút đóng
              Positioned(
                top: 44,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrownBadge extends StatelessWidget {
  const _CrownBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFFFE082), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.workspace_premium_rounded,
          color: Color(0xFFFFA000),
          size: 38,
        ),
      ),
    );
  }
}
