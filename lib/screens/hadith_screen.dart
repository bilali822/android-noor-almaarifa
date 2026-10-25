import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/quranic_background.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<Map<String, Object?>> _allHadiths = [];
  List<Map<String, Object?>> _filtered = [];
  List<String> _books = [];
  String _selectedBook = 'الكل';
  String _selectedGrade = 'الكل';
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getHadiths();
    final booksData = await DatabaseHelper.instance.getHadithBooks();
    if (!mounted) return;
    setState(() {
      _allHadiths = data;
      _books = ['الكل', ...booksData.map((b) => b['name'] as String).toSet()];
      _filtered = data;
      _loading = false;
    });
  }

  // 🌟 فلترة ذكية: تفلتر بالكتاب والتصنيف والبحث مع بعض
  void _applyFilters() {
    setState(() {
      _filtered = _allHadiths.where((h) {
        final bookMatch = _selectedBook == 'الكل' || h['book'] == _selectedBook;
        final gradeMatch = _selectedGrade == 'الكل' || h['grade'] == _selectedGrade;
        
        bool queryMatch = true;
        if (_query.isNotEmpty) {
          final textMatch = (h['arabic_text'] as String? ?? '').contains(_query) ||
                            (h['narrator'] as String? ?? '').contains(_query);
          final numMatch = h['hadith_number'].toString() == _query;
          queryMatch = textMatch || numMatch;
        }

        return bookMatch && gradeMatch && queryMatch;
      }).toList();
    });
  }

  Color _getGradeColor(String? grade) {
    if (grade == 'صحيح') return Colors.green;
    if (grade == 'حسن') return Colors.orange;
    if (grade == 'ضعيف') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('الأحاديث النبوية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: QuranicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 🌟 شريط البحث
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) { setState(() => _query = v.trim()); _applyFilters(); },
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: AppColors.text, fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    hintText: 'ابحث بكلمة أو رقم حديث أو راوٍ...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _query.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textMuted), onPressed: () { setState(() => _query = ''); _applyFilters(); }) 
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              
              // الفلاتر (الكتاب والتصنيف)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBook,
                        items: _books.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)))).toList(),
                        onChanged: (v) { setState(() => _selectedBook = v!); _applyFilters(); },
                        decoration: InputDecoration(
                          labelText: 'الكتاب',
                          filled: true, fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        items: ['الكل', 'صحيح', 'حسن', 'ضعيف'].map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)))).toList(),
                        onChanged: (v) { setState(() => _selectedGrade = v!); _applyFilters(); },
                        decoration: InputDecoration(
                          labelText: 'التصنيف',
                          filled: true, fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ),

              // عداد النتائج
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text('النتائج: ${_filtered.length}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              
              // القائمة
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _filtered.isEmpty
                        ? const Center(child: Text('لا توجد أحاديث مطابقة.', style: TextStyle(color: AppColors.textMuted)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) {
                              final h = _filtered[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text('${h['book']} • حديث ${h['hadith_number']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: _getGradeColor(h['grade'] as String?), borderRadius: BorderRadius.circular(10)),
                                            child: Text(h['grade'] as String? ?? 'غير محدد', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text('« ${h['arabic_text']} »', textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.text, fontSize: 20, height: 2.0, fontFamily: 'UthmanicHafs')),
                                    ),
                                    if ((h['narrator'] as String? ?? '').isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20, left: 20, bottom: 16),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text('الراوي: ${h['narrator']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
