import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';

class TafsirSheet extends StatefulWidget {
  final String surahName; final int surahId; final int verseNumber; final String verseText; final List<Map<String, Object?>> books;
  const TafsirSheet({super.key, required this.surahName, required this.surahId, required this.verseNumber, required this.verseText, required this.books});
  @override State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  int _selectedIndex = 0;
  String _text = '';
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (widget.books.isEmpty) return;
    setState(() => _loading = true);
    final tafsirs = await DatabaseHelper.instance.getTafsirs(widget.surahId, widget.verseNumber);
    final bookKey = widget.books[_selectedIndex]['key'];
    final match = tafsirs.firstWhere((t) => t['book_key'] == bookKey, orElse: () => <String, Object?>{});
    setState(() { _text = match['text_ar'] as String? ?? 'غير متوفر'; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const Center(child: Text('لا توجد كتب تفسير متاحة.'));
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
            Text('سورة ${widget.surahName} - الآية ${widget.verseNumber}', style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const Icon(Icons.bookmark_border, color: AppColors.primary),
          ]),
        ),
        Container(height: 15, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), border: const Border.symmetric(horizontal: BorderSide(color: AppColors.primary, width: 0.5)))),
        Padding(padding: const EdgeInsets.all(32), child: Text('﴿ ${widget.verseText} ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, height: 2.0, color: AppColors.text, fontFamily: 'UthmanicHafs'))),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: widget.books.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedIndex == i;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(widget.books[i]['name_ar'] as String), selected: isSelected, onSelected: (val) { setState(() => _selectedIndex = i); _load(); },
                  selectedColor: AppColors.primary, backgroundColor: Colors.transparent,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.bgDeep, borderRadius: BorderRadius.circular(16)), child: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : SingleChildScrollView(child: Text(_text, textDirection: TextDirection.rtl, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 18, height: 2.0, color: AppColors.text))))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.copy, size: 18), label: const Text('نسخ'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.menu_book, size: 18), label: const Text('تفسير'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0))),
          ]),
        )
      ]),
    );
  }
}
