import 'package:flutter/material.dart';

class AnimatedMascot extends StatefulWidget {
  final double size;
  const AnimatedMascot({super.key, this.size = 52});

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _rotate = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Transform.rotate(
          angle: _rotate.value,
          child: child,
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 28)),
            ),
          ),
        ),
      ),
    );
  }
}
