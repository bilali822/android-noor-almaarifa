import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatefulWidget {
  final String surahName;
  final int verseNumber;
  final String text;
  final VoidCallback onTafsir;

  const VerseCard({
    super.key,
    required this.surahName,
    required this.verseNumber,
    required this.text,
    required this.onTafsir,
  });

  @override
  State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    // بنفترض إن اسم السورة مش موجود في المفتاح، فبنعتمد على رقم السورة اللي بنجيبه من الداتابيز (مش موجود هنا للأسف، فهنستخدم اسم السورة ورقم الآية كبديل مؤقت)
    // الأفضل نمرر surahId، بس عشان منبوظش الكود، هنخلي الحفظ بالاسم والرقم
    setState(() => _isSaved = saved.contains('${widget.surahName}:${widget.verseNumber}'));
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    final key = '${widget.surahName}:${widget.verseNumber}';

    setState(() {
      if (_isSaved) {
        saved.remove(key);
        _isSaved = false;
      } else {
        saved.add(key);
        _isSaved = true;
      }
    });
    await prefs.setStringList('bookmarks', saved);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سورة ${widget.surahName}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text('آية ${widget.verseNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Text(
              '﴿ ${widget.text} ﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 26, height: 2.2, fontFamily: 'UthmanicHafs'),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _toggleSave,
                  icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, size: 18, color: _isSaved ? AppColors.primary : AppColors.textMuted),
                  label: Text(_isSaved ? 'محفوظة' : 'حفظ', style: TextStyle(color: _isSaved ? AppColors.primary : AppColors.textMuted)),
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '${widget.text}\n[سورة ${widget.surahName} - آية ${widget.verseNumber}]'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الآية')));
                  },
                  icon: const Icon(Icons.copy, size: 18, color: AppColors.textMuted),
                  label: const Text('نسخ', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onTafsir,
                  icon: const Icon(Icons.menu_book, size: 18, color: AppColors.primary),
                  label: const Text('التفسير', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
