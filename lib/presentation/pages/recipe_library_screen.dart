import 'package:flutter/material.dart';
import 'package:mamgo/data/datasources/recipes_data.dart';
import 'package:mamgo/data/models/recipe.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/core/utils/text_utils.dart';
import 'package:mamgo/presentation/widgets/recipe_card.dart';
import 'package:mamgo/presentation/pages/recipe_detail_screen.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String _cuisine = 'Tất cả';
  final _cuisines = [
    'Tất cả',
    'Việt Nam',
    'Hàn Quốc',
    'Nhật Bản',
    'Phương Tây',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesSearch(Recipe recipe, String q) {
    if (q.isEmpty) return true;

    final searchableFields = [
      TextUtils.normalize(recipe.name),
      TextUtils.normalize(recipe.description),
      TextUtils.normalize(recipe.cuisine),
      ...recipe.tags.map(TextUtils.normalize),
    ];

    return searchableFields.any((field) => field.contains(q));
  }

  List<Recipe> get _filtered {
    final q = TextUtils.normalize(_search);

    return RecipesData.all.where((recipe) {
      final matchesCuisine =
          _cuisine == 'Tất cả' ||
          TextUtils.normalize(recipe.cuisine) == TextUtils.normalize(_cuisine);
      final matchesSearch = _matchesSearch(recipe, q);
      return matchesCuisine && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: const Text(
                '📖 Cẩm nang nấu ăn',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _searchBar(),
                  const SizedBox(height: 14),
                  _cuisineFilter(),
                  const SizedBox(height: 16),
                  Text(
                    '${_filtered.length} công thức',
                    style: const TextStyle(
                      color: AppTheme.textMedium,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _filtered.isEmpty
                ? SliverToBoxAdapter(child: _emptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => RecipeCard(
                        recipe: _filtered[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(recipe: _filtered[i]),
                          ),
                        ),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      onChanged: (v) => setState(() => _search = v.trim()),
      onSubmitted: (v) => setState(() => _search = v.trim()),
      decoration: InputDecoration(
        hintText: 'Tìm tên món, nguyên liệu, kiểu ẩm thực...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMedium),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _search = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6D9D0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6D9D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _cuisineFilter() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _cuisines.map((c) {
          final selected = c == _cuisine;
          return GestureDetector(
            onTap: () => setState(() => _cuisine = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : const Color(0xFFE0D0C8),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                c,
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
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Text('🍳', style: TextStyle(fontSize: 60)),
            SizedBox(height: 12),
            Text(
              'Không tìm thấy công thức phù hợp',
              style: TextStyle(color: AppTheme.textMedium, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
