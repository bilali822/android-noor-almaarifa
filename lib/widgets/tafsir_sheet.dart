import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';

class TafsirSheet extends StatefulWidget {
  final String surahName;
  final int surahId;
  final int verseNumber;
  final String verseText;
  final List<Map<String, Object?>> books;

  const TafsirSheet({super.key, required this.surahName, required this.surahId, required this.verseNumber, required this.verseText, required this.books});

  @override State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  int _selectedBookIndex = 0;
  String _tafsirText = 'جاري التحميل...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    setState(() => _isLoading = true);
    final book = widget.books[_selectedBookIndex];
    final tafsirs = await DatabaseHelper.instance.getTafsirs(widget.surahId, widget.verseNumber);
    final selected = tafsirs.firstWhere((t) => t['book_key'] == book['key'], orElse: () => {});
    
    setState(() {
      _tafsirText = selected['text_ar'] ?? 'التفسير غير متوفر لهذه الآية.';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(children: [
            // رأس الشاشة
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary), onPressed: () => Navigator.pop(context)),
                Text('سورة ${widget.surahName} - الآية ${widget.verseNumber}', style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.bookmark_border, color: AppColors.primary),
              ]),
            ),
            // زخرفة
            Container(height: 20, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), border: const Border.symmetric(horizontal: BorderSide(color: AppColors.primary, width: 0.5)))),
            
            // نص الآية
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('﴿ ${widget.verseText} ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, height: 2.0, color: AppColors.text, fontFamily: 'UthmanicHafs')),
            ),
            
            // أزرار التفاسير
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.books.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedBookIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(widget.books[i]['name_ar'] as String),
                      selected: isSelected,
                      onSelected: (val) { setState(() => _selectedBookIndex = i); _loadTafsir(); },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // نص التفسير
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF8F6F0), borderRadius: BorderRadius.circular(20)),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      controller: scrollCtrl,
                      child: Text(_tafsirText, textDirection: TextDirection.rtl, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 18, height: 2.0, color: AppColors.text)),
                    ),
              ),
            ),
            
            // أزرار التحكم
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.copy, size: 18), label: const Text('نسخ'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.menu_book, size: 18), label: const Text('حسناً'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0))),
              ]),
            )
          ]),
        );
      },
    );
  }
}
