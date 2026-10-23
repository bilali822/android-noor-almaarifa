import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SurahCard extends StatelessWidget {
  final String surahName;
  final String fullText;

  const SurahCard({super.key, required this.surahName, required this.fullText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الكارت
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text('سورة $surahName', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          
          // نص السورة الكامل بالخط العثماني
          SelectableText(
            fullText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 26,
              height: 2.4, // مسافة واسعة لاستيعاب التشكيل
              fontFamily: 'UthmanicHafs',
            ),
          ),
        ],
      ),
    );
  }
}
