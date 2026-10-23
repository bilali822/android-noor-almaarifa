import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. لون البيج الفاتح (خلفية التصميم)
        Container(color: const Color(0xFFF7F4EC)),
        
        // 2. النقشة الإسلامية (مكررة - مكبّرة - بلون بني فاتح)
        Positioned.fill(
          child: Image.asset(
            'assets/images/islamic_pattern.png',
            repeat: ImageRepeat.repeat,
            scale: 1.5, // 🌟 تكبير النقشة عشان تبان زي التصميم
            color: const Color(0xFFD4C4B0), // 🌟 لون بني/بيج غامق دافئ
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        
        // 3. المحتوى
        child,
      ],
    );
  }
}
