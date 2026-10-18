import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TafsirSheet extends StatefulWidget {
  final String surahName;
  final int surahId;
  final int verseNumber;
  final String verseText;
  final List<Map<String, Object?>> books;

  const TafsirSheet({
    super.key,
    required this.surahName,
    required this.surahId,
    required this.verseNumber,
    required this.verseText,
    required this.books,
  });

  @override
  State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgDeep,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.auto_stories, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'اختر التفسير',
                        style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(right: BorderSide(color: AppColors.primary, width: 4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'سورة ${widget.surahName} — الآية ${widget.verseNumber}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '﴿ ${widget.verseText} ﴾',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.text, fontSize: 18, height: 2.0, fontFamily: 'serif'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.books.length,
                  itemBuilder: (context, i) {
                    final book = widget.books[i];
                    final key = book['key'] as String;
                    final name = book['name_ar'] as String? ?? key;
                    final isSelected = _selected.contains(key);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(key);
                          } else {
                            _selected.add(key);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.book, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: isSelected ? const Icon(Icons.check, size: 14, color: AppColors.bgDeep) : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_selected.length == widget.books.length) {
                              _selected.clear();
                            } else {
                              _selected.clear();
                              for (final b in widget.books) {
                                _selected.add(b['key'] as String);
                              }
                            }
                          });
                        },
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('تحديد الكل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text('عرض (${_selected.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
