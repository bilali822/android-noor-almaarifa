import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // اللون الأساسي
        Container(color: AppColors.bgDeep),
        // النقشة الإسلامية المرسومة
        Positioned.fill(
          child: CustomPaint(
            painter: _IslamicPatternPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04) // شفافية عالية جداً
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double spacing = 80.0;

    // رسم شبكة من النجمة الثمانية (Khatam)
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawStar(canvas, Offset(x, y), 25, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * 45 * (3.14159 / 180);
      double px = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * _cos(angle);
      double py = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * _sin(angle);
      if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
    }
    path.close();
    canvas.drawPath(path, paint);

    // رسم الخطوط المتقاطعة لتعطي شكل الزخرفة الإسلامية
    final innerPath = Path();
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 + 22.5) * (3.14159 / 180);
      double px = center.dx + radius * 0.7 * _cos(angle);
      double py = center.dy + radius * 0.7 * _sin(angle);
      if (i == 0) innerPath.moveTo(px, py); else innerPath.lineTo(px, py);
    }
    innerPath.close();
    canvas.drawPath(innerPath, paint);
  }

  // دالة مساعدة لحساب الجيب وجيب التمام
  double _cos(double angle) => [1.0, 0.707, 0.0, -0.707, -1.0, -0.707, 0.0, 0.707][(angle / 0.785).round() % 8];
  double _sin(double angle) => [0.0, 0.707, 1.0, 0.707, 0.0, -0.707, -1.0, -0.707][(angle / 0.785).round() % 8];

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
