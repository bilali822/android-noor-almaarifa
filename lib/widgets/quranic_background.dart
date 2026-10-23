import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية العاجية الأساسية
        Container(color: AppColors.bgDeep),
        
        // الزخرفة الهندسية (النجمة الثمانية)
        Positioned.fill(
          child: CustomPaint(
            painter: _IslamicPatternPainter(),
          ),
        ),
        
        // المحتوى
        child,
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // لون الزخرفة (أخضر زمردي بشفافية خفيفة جداً 3%)
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double spacing = 80.0; // المسافة بين كل نجمة والتانية

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointedStar(canvas, Offset(x, y), 25, paint);
      }
    }
  }

  // دالة رسم النجمة الثمانية (خاتم سليمان)
  void _drawEightPointedStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45) * (3.14159 / 180);
      double x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * _cos(angle);
      double y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) => angle == 0 ? 1 : (angle == 1.5708 ? 0 : (angle == 3.14159 ? -1 : (angle == 4.71239 ? 0 : (angle < 1.5708 ? 0.707 : (angle < 3.14159 ? -0.707 : (angle < 4.71239 ? -0.707 : 0.707))))));
  double _sin(double angle) => angle == 0 ? 0 : (angle == 1.5708 ? 1 : (angle == 3.14159 ? 0 : (angle == 4.71239 ? -1 : (angle < 1.5708 ? 0.707 : (angle < 3.14159 ? 0.707 : (angle < 4.71239 ? -0.707 : -0.707))))));

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
