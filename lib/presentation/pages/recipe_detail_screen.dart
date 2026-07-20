import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/data/models/recipe.dart';
import 'package:mamgo/core/constants/app_theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(),
                  const SizedBox(height: 20),
                  _description(),
                  const SizedBox(height: 24),
                  _ingredients(),
                  const SizedBox(height: 24),
                  _steps(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.imageUrl.isEmpty
            ? _gradientWithEmoji()
            : Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: recipe.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _gradientWithEmoji(),
                    errorWidget: (_, _, _) => _gradientWithEmoji(),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0xBB000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        title: Text(
          recipe.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 54, bottom: 14),
      ),
    );
  }

  Widget _gradientWithEmoji() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.9),
            AppTheme.accent.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(recipe.emoji, style: const TextStyle(fontSize: 90)),
        ],
      ),
    );
  }

  Widget _infoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem('⏱️', 'Sơ chế', recipe.prepTime),
          _divider(),
          _infoItem('🔥', 'Nấu', recipe.cookTime),
          _divider(),
          _infoItem('👥', 'Khẩu phần', '${recipe.servings} người'),
          _divider(),
          _infoItem('📊', 'Độ khó', recipe.difficulty),
        ],
      ),
    );
  }

  Widget _infoItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: const Color(0xFFEEE0D8));
  }

  Widget _description() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recipe.description,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredients() {
    return _section(
      '🛒 Nguyên liệu',
      Column(
        children: recipe.ingredients.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(entry.value,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textDark, height: 1.4)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _steps() {
    return _section(
      '👨‍🍳 Cách làm',
      Column(
        children: recipe.steps.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          return StepTile(index: idx, text: entry.value);
        }).toList(),
      ),
    );
  }

  Widget _section(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark)),
        const SizedBox(height: 14),
        content,
      ],
    );
  }
}

class StepTile extends StatefulWidget {
  final int index;
  final String text;

  const StepTile({super.key, required this.index, required this.text});

  @override
  State<StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> {
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _extractTimeInSeconds(widget.text);
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _extractTimeInSeconds(String text) {
    int seconds = 0;
    
    // Minutes
    final minRegex = RegExp(r'(?:(\d+)\s*-\s*)?(\d+)\s*phút');
    final minMatch = minRegex.firstMatch(text.toLowerCase());
    if (minMatch != null) {
      String numStr = minMatch.group(2) ?? minMatch.group(1)!;
      seconds += int.parse(numStr) * 60;
    }

    // Hours
    final hourRegex = RegExp(r'(?:(\d+)\s*-\s*)?(\d+)\s*(tiếng|giờ)');
    final hourMatch = hourRegex.firstMatch(text.toLowerCase());
    if (hourMatch != null) {
      String numStr = hourMatch.group(2) ?? hourMatch.group(1)!;
      seconds += int.parse(numStr) * 3600;
    }

    // Seconds
    final secRegex = RegExp(r'(?:(\d+)\s*-\s*)?(\d+)\s*giây');
    final secMatch = secRegex.firstMatch(text.toLowerCase());
    if (secMatch != null) {
      String numStr = secMatch.group(2) ?? secMatch.group(1)!;
      seconds += int.parse(numStr);
    }

    return seconds;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      if (_remainingSeconds == 0) {
        _remainingSeconds = _totalSeconds; // Reset if finished
      }
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
        }
      });
    }
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '00:00';
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasTimer = _totalSeconds > 0;
    final isFinished = hasTimer && _remainingSeconds == 0 && !_isRunning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isFinished ? AppTheme.success : AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${widget.index}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFinished ? AppTheme.success.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFinished ? AppTheme.success.withValues(alpha: 0.5) : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.text,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark,
                          height: 1.5)),
                  if (hasTimer) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleTimer,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isRunning 
                                ? AppTheme.orange.withValues(alpha: 0.1) 
                                : AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isRunning ? AppTheme.orange : AppTheme.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isRunning ? Icons.pause_rounded : (isFinished ? Icons.refresh_rounded : Icons.play_arrow_rounded),
                                  size: 16,
                                  color: _isRunning ? AppTheme.orange : AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _isRunning ? AppTheme.orange : AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isFinished) ...[
                          const SizedBox(width: 10),
                          const Text(
                            'Hoàn thành! 🎉',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
