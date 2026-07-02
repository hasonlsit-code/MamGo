import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/data/models/food.dart';
import 'package:mamgo/core/constants/app_theme.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback? onTap;

  const FoodCard({super.key, required this.food, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 13, color: AppTheme.primary),
                            const SizedBox(width: 2),
                            Text(
                              '${food.calories} kcal',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 13, color: AppTheme.textMedium),
                            const SizedBox(width: 2),
                            Text(
                              food.prepTime,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _difficultyColor(food.difficulty)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _difficultyColor(food.difficulty)
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            food.difficulty,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _difficultyColor(food.difficulty),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    if (food.imageUrl.isEmpty) {
      return _emojiFallback();
    }
    return CachedNetworkImage(
      imageUrl: food.imageUrl,
      height: 118,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => _shimmerPlaceholder(),
      errorWidget: (context, url, error) => _emojiFallback(),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      height: 118,
      color: const Color(0xFFEEEEEE),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
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
      height: 118,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(food.emoji, style: const TextStyle(fontSize: 52)),
      ),
    );
  }

  Color _difficultyColor(String d) {
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
