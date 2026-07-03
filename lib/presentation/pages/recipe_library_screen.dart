import 'package:flutter/material.dart';
import 'package:mamgo/data/datasources/recipes_data.dart';
import 'package:mamgo/data/models/recipe.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/widgets/recipe_card.dart';
import 'package:mamgo/presentation/pages/recipe_detail_screen.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  String _search = '';
  String _cuisine = 'Tất cả';
  final _cuisines = ['Tất cả', 'Việt Nam', 'Hàn Quốc', 'Nhật Bản', 'Phương Tây'];

  List<Recipe> get _filtered {
    var recipes = RecipesData.all;
    if (_cuisine != 'Tất cả') {
      recipes = recipes.where((r) => r.cuisine == _cuisine).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      recipes = recipes
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q) ||
              r.tags.any((t) => t.contains(q)))
          .toList();
    }
    return recipes;
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
              title: const Text('📖 Cẩm nang nấu ăn',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
                        fontWeight: FontWeight.w500),
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
      onChanged: (v) => setState(() => _search = v),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm công thức...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
        suffixIcon: _search.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMedium),
                onPressed: () => setState(() => _search = ''),
              )
            : null,
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
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFFE0D0C8)),
                boxShadow: selected
                    ? [BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 6, offset: const Offset(0, 2))]
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
            Text('Không tìm thấy công thức phù hợp',
                style: TextStyle(color: AppTheme.textMedium, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
