import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(),
          if (!isUser) const SizedBox(width: 12),
          Flexible(child: _bubble()),
          if (isUser) const SizedBox(width: 12),
          if (isUser) _avatar(),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? AppColors.surface : AppColors.primary.withOpacity(0.15),
        border: Border.all(color: isUser ? AppColors.border : AppColors.primary, width: 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        isUser ? Icons.person_outline : Icons.auto_awesome,
        color: isUser ? AppColors.textMuted : AppColors.primary,
        size: 18,
      ),
    );
  }

  Widget _bubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.surface,
        border: isUser ? null : Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            text,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isUser ? AppColors.bgDeep : AppColors.text,
              fontSize: 15,
              height: 1.8,
              fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              color: isUser ? AppColors.bgDeep.withOpacity(0.6) : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
