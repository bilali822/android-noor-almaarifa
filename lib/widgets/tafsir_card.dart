import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TafsirCard extends StatelessWidget {
  final String bookName;
  final String tafsirText;

  const TafsirCard({super.key, required this.bookName, required this.tafsirText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tafsirFontSize = (screenWidth * 0.045).clamp(16.0, 22.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان التفسير
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(bookName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          
          // نص التفسير بالخط العثماني
          Text(
            tafsirText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: AppColors.text,
              fontSize: tafsirFontSize,
              height: 2.0,
              fontFamily: 'UthmanicHafs', // 🌟 الخط العثماني
            ),
          ),
        ],
      ),
    );
  }
}
