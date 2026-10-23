import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. اللون الأساسي (بيج)
        Container(color: AppColors.bgDeep),
        
        // 2. النقشة الإسلامية (شفافية 20% ولون رمادي)
        Positioned.fill(
          child: Opacity(
            opacity: 0.20, // 🌟 رفعنا الشفافية عشان تبان
            child: Image.asset(
              'assets/images/islamic_pattern.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              // 🌟 شلنا colorBlendMode عشان الصورة تظهر بألوانها الطبيعية
            ),
          ),
        ),
        
        // 3. المحتوى
        child,
      ],
    );
  }
}
