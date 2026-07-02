import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/data/models/recipe.dart';
import 'package:mamgo/core/constants/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  _buildImageSection(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              _chip(
                                  Icons.schedule,
                                  '${recipe.prepTime} + ${recipe.cookTime}',
                                  AppTheme.primary),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _chip(Icons.people, '${recipe.servings} người',
                                  AppTheme.secondary),
                              const SizedBox(width: 6),
                              _chip(Icons.bar_chart, recipe.difficulty,
                                  _diffColor(recipe.difficulty)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.chevron_right,
                        color: AppTheme.textMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (recipe.imageUrl.isEmpty) {
      return _emojiFallback();
    }
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      child: CachedNetworkImage(
        imageUrl: recipe.imageUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        placeholder: (context, url) => _shimmerPlaceholder(),
        errorWidget: (context, url, error) => _emojiFallback(),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFEEEEEE),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _emojiFallback() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.accent.withValues(alpha: 0.25),
          ],
        ),
        borderRadius:
            const BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      child: Center(
          child: Text(recipe.emoji, style: const TextStyle(fontSize: 42))),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Dễ':
        return AppTheme.secondary;
      case 'Khó':
        return Colors.redAccent;
      default:
        return AppTheme.accent;
    }
  }
}
