import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';

class MushafSearchScreen extends StatefulWidget {
  const MushafSearchScreen({super.key});
  @override State<MushafSearchScreen> createState() => _MushafSearchScreenState();
}

class _MushafSearchScreenState extends State<MushafSearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, Object?>> _results = [];
  bool _loading = false;
  bool _hasSearched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _loading = true; _hasSearched = true; });
    final results = await DatabaseHelper.instance.searchVerses(query, limit: 50);
    if (!mounted) return;
    setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(
            hintText: 'ابحث عن آية أو جملة...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: () => _search(_controller.text))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : !_hasSearched
              ? const Center(child: Text('اكتب كلمة للبحث عنها في الآيات', style: TextStyle(color: AppColors.textMuted)))
              : _results.isEmpty
                  ? const Center(child: Text('لا توجد نتائج مطابقة.', style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        final surahName = r['surah_name'] ?? 'سورة ${r['surah_id']}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text('$surahName - آية ${r['verse_number']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(r['text_ar'] as String, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.text, fontSize: 16, height: 1.8, fontFamily: 'UthmanicHafs')),
                            ),
                            onTap: () {
                              Navigator.pop(context, {'surahId': r['surah_id'], 'verseNumber': r['verse_number']});
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
