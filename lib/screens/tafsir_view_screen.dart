import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isDownloading = false;
  bool _isDownloaded = false;

  void _downloadTafsirs() async {
    setState(() => _isDownloading = true);
    // 🌟 هنا يتم برمجة تحميل ملف التفاسير (مؤقتاً نحاكي التحميل)
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isDownloading = false;
      _isDownloaded = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم تحميل التفاسير بنجاح! يمكنك الآن استخدامها بدون إنترنت.'), backgroundColor: Colors.green));
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // 🌟 بانر التحميل (يظهر فقط إذا لم يتم التحميل مسبقاً)
          if (!_isDownloaded)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.download_for_offline, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'هل تريد تحميل التفاسير لاستخدامها بدون إنترنت؟',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isDownloading ? null : _downloadTafsirs,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: _isDownloading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('تحميل', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // كارت الآية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '﴿ ${widget.verseText} ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.text, fontSize: 24, height: 2.0, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // كروت التفاسير (مثل تصميم الأحاديث)
                ...widget.tafsirList.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(t['book_name'] ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          t['text'] ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: AppColors.text, fontSize: 18, height: 1.8, fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
