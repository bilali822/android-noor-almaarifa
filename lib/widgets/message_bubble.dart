import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text; final bool isUser;
  const MessageBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), 
                  topRight: const Radius.circular(16), 
                  bottomRight: Radius.circular(isUser ? 4 : 16), 
                  bottomLeft: Radius.circular(isUser ? 16 : 4)
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
              ),
              child: Text(text, textDirection: TextDirection.rtl, style: TextStyle(color: isUser ? Colors.white : AppColors.text, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
