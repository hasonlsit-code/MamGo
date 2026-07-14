import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamgo/data/models/user_preference.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController();
  final Set<String> _tastes = {};

  @override
  void initState() {
    super.initState();
    // Điền sẵn tên từ tài khoản đã đăng ký
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && user.name.isNotEmpty && _nameCtrl.text.isEmpty) {
        _nameCtrl.text = user.name;
      }
    });
  }

  final Set<String> _diets = {};
  final Set<String> _cuisines = {};

  static const _tasteOptions = [
    ('Cay 🌶️', 'spicy'), ('Ngọt 🍯', 'sweet'), ('Mặn 🧂', 'savory'),
    ('Chua 🍋', 'sour'), ('Thanh nhẹ 🌿', 'light'), ('Béo 🥑', 'rich'),
    ('Hải sản 🦐', 'seafood'), ('Chay 🥬', 'vegetarian'),
  ];

  static const _dietOptions = [
    'Không hạn chế ✅', 'Chay 🥬', 'Không hải sản 🚫🦐',
    'Không thịt đỏ 🚫🥩', 'Ít calo ⚖️',
  ];

  static const _cuisineOptions = [
    'Việt Nam 🇻🇳', 'Hàn Quốc 🇰🇷', 'Nhật Bản 🇯🇵',
    'Trung Quốc 🇨🇳', 'Thái Lan 🇹🇭', 'Phương Tây 🌍',
  ];

  void _next() {
    if (_page == 0 && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn!')),
      );
      return;
    }
    if (_page < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final pref = UserPreference(
      name: _nameCtrl.text.trim(),
      tastePreferences: _tastes.toList(),
      dietaryRestrictions: _diets.toList(),
      favoriteCuisines: _cuisines
          .map((c) => c.split(' ').first)
          .toList(),
    );
    final email = context.read<AuthProvider>().user?.email ?? '';
    await context.read<UserPreferenceProvider>().save(pref, email);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F0), Color(0xFFFFE8D6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              _buildNavButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _page ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _page ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text(
            'Xin chào!\nBạn tên là gì?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold,
              color: AppTheme.textDark, height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'MămGo sẽ gợi ý món ăn phù hợp nhất với khẩu vị của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 36),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Nhập tên của bạn...',
              prefixIcon: Icon(Icons.person, color: AppTheme.primary),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('😋', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Khẩu vị của bạn?',
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chọn những vị bạn thích (có thể chọn nhiều)',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tasteOptions.map((t) {
              final selected = _tastes.contains(t.$2);
              return GestureDetector(
                onTap: () => setState(() =>
                    selected ? _tastes.remove(t.$2) : _tastes.add(t.$2)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : const Color(0xFFE0D0C8)),
                    boxShadow: selected
                        ? [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Text(
                    t.$1,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🌏', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Ẩm thực yêu thích?',
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chọn nền ẩm thực bạn thích',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _cuisineOptions.map((c) {
              final selected = _cuisines.contains(c);
              return GestureDetector(
                onTap: () => setState(() =>
                    selected ? _cuisines.remove(c) : _cuisines.add(c)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : const Color(0xFFE0D0C8)),
                    boxShadow: selected
                        ? [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Chế độ ăn',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _dietOptions.map((d) {
              final selected = _diets.contains(d);
              return GestureDetector(
                onTap: () => setState(() =>
                    selected ? _diets.remove(d) : _diets.add(d)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.secondary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: selected
                            ? AppTheme.secondary
                            : const Color(0xFFE0D0C8)),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          if (_page > 0)
            TextButton.icon(
              onPressed: () => _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut),
              icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
              label: const Text('Quay lại',
                  style: TextStyle(color: AppTheme.primary)),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _next,
            child: Text(_page == 2 ? 'Bắt đầu! 🚀' : 'Tiếp theo →'),
          ),
        ],
      ),
    );
  }
}
