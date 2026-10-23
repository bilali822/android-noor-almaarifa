import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatelessWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String text;
  final String tafsirText;
  final VoidCallback onTafsir;

  const VerseCard({
    super.key, 
    required this.surahId, 
    required this.surahName, 
    required this.verseNumber, 
    required this.text, 
    required this.tafsirText,
    required this.onTafsir,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 🌟 جعل حجم الخط متجاوب مع عرض الشاشة
    final quranFontSize = (screenWidth * 0.065).clamp(20.0, 34.0);
    final tafsirFontSize = (screenWidth * 0.045).clamp(14.0, 20.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // 🌟 تحديد أقصى ارتفاع للكارت عشان ميكبرش ويطلع برا الشاشة
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.70, 
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('مساعد القرآن • $surahName • آية $verseNumber', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
            ]),
          ),
          
          const Divider(color: AppColors.border, height: 1),

          // 🌟 محتوى قابل للتمرير (لو النص طويل جداً) لكن الكارت نفسه ثابت الحجم
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // نص الآية بالخط العثماني
                  Text(
                    '﴿ $text ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: quranFontSize,
                      height: 2.2,
                      fontFamily: 'UthmanicHafs',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // التفسير بالخط العثماني (بناءً على طلبك)
                  Text(
                    tafsirText,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: tafsirFontSize,
                      height: 2.0,
                      fontFamily: 'UthmanicHafs', 
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // اسم السورة
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('سورة $surahName - الآية $verseNumber', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
          
          // الأزرار (ثابتة في أسفل الكارت ومضمونة الظهور)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('نسخ', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTafsir, // تفعيل زر التفسير
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text('تفسير', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
