import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TafsirSheet extends StatefulWidget {
  final String surahName; final int surahId; final int verseNumber; final String verseText; final List<Map<String, Object?>> books;
  const TafsirSheet({super.key, required this.surahName, required this.surahId, required this.verseNumber, required this.verseText, required this.books});
  @override State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
                const Text('اختر التفاسير', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 40),
              ]
            ),
          ),
          const Divider(color: AppColors.border),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.books.length,
              itemBuilder: (context, i) {
                final book = widget.books[i];
                final key = book['key'] as String;
                final name = book['name_ar'] as String;
                final isSelected = _selected.contains(key);

                return CheckboxListTile(
                  title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) _selected.add(key);
                      else _selected.remove(key);
                    });
                  },
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text('عرض التفسير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
