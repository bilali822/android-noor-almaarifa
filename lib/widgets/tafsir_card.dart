import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TafsirCard extends StatelessWidget {
  final String bookName;
  final String text;

  const TafsirCard({
    super.key,
    required this.bookName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت (اسم التفسير)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  bookName,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          
          // نص التفسير
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18, // مقاس مناسب للقراءة
                height: 1.8,  // مسافة مريحة بين السطور
                fontFamily: 'UthmanicHafs', // نفس خط الآيات
              ),
            ),
          ),
        ],
      ),
    );
  }
}
