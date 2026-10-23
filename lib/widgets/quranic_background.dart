import 'package:flutter/material.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F4EC), // لون البيج
      child: Stack(
        children: [
          // نقشة إسلامية خفيفة جداً
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/islamic_pattern.png',
                repeat: ImageRepeat.repeat,
                scale: 1.2,
                color: const Color(0xFF155E35),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
