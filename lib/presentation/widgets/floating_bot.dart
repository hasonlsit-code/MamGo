import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/pages/chatbot_screen.dart';

/// Trợ lý nổi "MamGo bot": icon chatbot dễ thương hiển thị xuyên suốt app.
/// Khi xuất hiện lần đầu sẽ tự chào 5 giây rồi ẩn lời chào;
/// nhấn vào icon sẽ mở popup màn chat.
class FloatingBot extends StatefulWidget {
  const FloatingBot({super.key});

  @override
  State<FloatingBot> createState() => _FloatingBotState();
}

class _FloatingBotState extends State<FloatingBot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _float;
  bool _showBubble = true;
  Timer? _bubbleTimer;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
    // Lời chào tự tắt sau 5 giây
    _bubbleTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showBubble = false);
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _openChat() {
    setState(() => _showBubble = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            child: const ChatbotScreen(isPopup: true),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bong bóng lời chào
          AnimatedOpacity(
            opacity: _showBubble ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: AnimatedScale(
              scale: _showBubble ? 1 : 0.85,
              duration: const Duration(milliseconds: 350),
              alignment: Alignment.centerRight,
              child: _showBubble
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 210),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(4),
                        ),
                        border: Border.all(
                            color:
                                AppTheme.primary.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Mình là MamGo bot, cần gì hãy nói mình nhé! 👋',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Icon bot
          GestureDetector(
            onTap: _openChat,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppTheme.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 28),
                  ),
                  // Chấm "đang online"
                  Positioned(
                    top: 3,
                    right: 5,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
