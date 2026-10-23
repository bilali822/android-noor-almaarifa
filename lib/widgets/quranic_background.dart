import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuranicBackground extends StatelessWidget {
  final Widget child;
  const QuranicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.bgDeep),
        // نقشة إسلامية خفيفة جداً في الخلفية
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/arabesque.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
