import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../widgets/verse_card.dart';
import '../widgets/tafsir_card.dart';

class TafsirViewScreen extends StatefulWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String verseText;
  final List<Map<String, String>> tafsirList;

  const TafsirViewScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    required this.tafsirList,
  });

  @override
  State<TafsirViewScreen> createState() => _TafsirViewScreenState();
}

class _TafsirViewScreenState extends State<TafsirViewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // 🌟 دالة مشاركة التفسير والآية كصورة
  Future<void> _shareTafsirImage() async {
    try {
      final image = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Container(
            width: 500, // عرض ثابت للصورة الملتقطة
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4EC), // لون بيج إسلامي
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. رأس البطاقة (اسم السورة ورقم الآية)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'سورة ${widget.surahName} • الآية ${widget.verseNumber}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. نص الآية
                Text(
                  '﴿ ${widget.verseText} ﴾',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.text, fontSize: 26, height: 2.2, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold),
                ),
                
                // فاصل زخرفي
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.primary.withOpacity(0.3), thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                      ),
                      Expanded(child: Divider(color: AppColors.primary.withOpacity(0.3), thickness: 1)),
                    ],
                  ),
                ),

                // 3. نصوص التفسير
                ...widget.tafsirList.map((tafsir) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tafsir['book_name']}:',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tafsir['text'] ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.8),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),
                
                // 4. توقيع التطبيق
                const Text('تطبيق نور المعرفة', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
      );

      // مشاركة الصورة (يدعم الويب والموبايل)
      final xFile = XFile.fromData(
        image,
        mimeType: 'image/png',
        name: 'tafsir_${widget.surahId}_${widget.verseNumber}.png',
      );
      await Share.shareXFiles([xFile], text: 'تفسير آية من القرآن الكريم');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر مشاركة الصورة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        title: const Text('تفسير الآية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🌟 زر المشاركة كصورة
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            tooltip: 'مشاركة التفسير كصورة',
            onPressed: _shareTafsirImage,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // كارت الآية
          VerseCard(
            surahId: widget.surahId,
            surahName: widget.surahName,
            verseNumber: widget.verseNumber,
            text: widget.verseText,
            tafsirText: '', // فارغ عشان مانكررش التفسير
            onTafsir: () {}, // معطل
          ),

          // كروت التفاسير
          ...widget.tafsirList.map((t) => TafsirCard(
            bookName: t['book_name'] ?? '',
            tafsirText: t['text'] ?? '',
          )),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
