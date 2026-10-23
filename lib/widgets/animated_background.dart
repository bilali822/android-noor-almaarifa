import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BackgroundPainter(_controller.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double time;
  _BackgroundPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // اللون الأساسي للخلفية (كحلي غامق جداً)
    final bgPaint = Paint()..color = const Color(0xFF0B101E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // توهج 1 (أزرق داكن)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.2 + sin(time * 2 * pi) * 50,
        size.height * 0.3 + cos(time * 2 * pi) * 50,
      ),
      size.width * 0.4,
      const Color(0xFF1E293B),
    );

    // توهج 2 (ذهبي خافت جداً - عشان يدي فخامة)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.8 + cos(time * 2 * pi) * 60,
        size.height * 0.7 + sin(time * 2 * pi) * 60,
      ),
      size.width * 0.35,
      const Color(0xFFD4AF37).withOpacity(0.08),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
