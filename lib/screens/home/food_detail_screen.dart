import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/food.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_mascot.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  String? _recipe;
  bool _loadingRecipe = false;
  bool _recipeRequested = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _loadingRecipe = true;
      _recipeRequested = true;
    });
    final recipe = await GeminiService.chat(
      'Hãy cho mình công thức nấu ${widget.food.name} với danh sách nguyên liệu đầy đủ và từng bước thực hiện chi tiết nhé!',
    );
    if (mounted) {
      setState(() {
        _recipe = recipe;
        _loadingRecipe = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildHeroBar(context, food),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleRow(food),
                      const SizedBox(height: 18),
                      _statsRow(food),
                      const SizedBox(height: 20),
                      _descriptionCard(food),
                      const SizedBox(height: 26),
                      _tagsRow(food),
                      const SizedBox(height: 28),
                      _recipeSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBar(BuildContext context, Food food) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryDark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            food.imageUrl.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryDark,
                          AppTheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(food.emoji,
                          style: const TextStyle(fontSize: 110)),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: food.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _gradientFallback(food),
                    errorWidget: (_, _, _) => _gradientFallback(food),
                  ),
            // Gradient overlay for readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Bottom label overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      food.mealType == 'breakfast'
                          ? '🌅 Bữa sáng'
                          : food.mealType == 'lunch'
                              ? '☀️ Bữa trưa'
                              : food.mealType == 'dinner'
                                  ? '🌙 Bữa tối'
                                  : '🍽️ Mọi bữa',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black54)
                      ],
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

  Widget _gradientFallback(Food food) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
          child: Text(food.emoji, style: const TextStyle(fontSize: 90))),
    );
  }

  Widget _titleRow(Food food) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                food.cuisines.join(' · '),
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textMedium),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _diffColor(food.difficulty).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _diffColor(food.difficulty).withValues(alpha: 0.3)),
          ),
          child: Text(
            food.difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _diffColor(food.difficulty),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsRow(Food food) {
    return Row(
      children: [
        _statCard(Icons.local_fire_department_rounded,
            '${food.calories}', 'kcal', AppTheme.primary),
        const SizedBox(width: 12),
        _statCard(Icons.schedule_rounded, food.prepTime, 'Thời gian',
            AppTheme.primaryDark),
        const SizedBox(width: 12),
        _statCard(Icons.restaurant_menu_rounded, food.difficulty,
            'Độ khó', AppTheme.accent),
      ],
    );
  }

  Widget _statCard(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _descriptionCard(Food food) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              food.description,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                  height: 1.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagsRow(Food food) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: food.tags.map((tag) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.chipBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _recipeSection() {
    if (!_recipeRequested) {
      return GestureDetector(
        onTap: _loadRecipe,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              const AnimatedMascot(size: 50),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xem công thức đầy đủ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'MămGo AI hướng dẫn từng bước chi tiết',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadingRecipe) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const AnimatedMascot(size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MămGo đang soạn công thức...',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: AppTheme.chipBg,
                      color: AppTheme.primary,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AnimatedMascot(size: 36),
              const SizedBox(width: 10),
              const Text(
                'Công thức từ MămGo AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0F5F0), thickness: 1),
          const SizedBox(height: 12),
          Text(
            _recipe ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Dễ':
        return AppTheme.primary;
      case 'Khó':
        return Colors.redAccent;
      default:
        return AppTheme.accent;
    }
  }
}
