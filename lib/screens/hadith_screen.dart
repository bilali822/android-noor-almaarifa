import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, Object?>> _hadiths = [];
  List<String> _books = ['الكل'];
  String _selectedBook = 'الكل';
  String _selectedGrade = 'الكل';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _applyFilters();
  }

  Future<void> _loadBooks() async {
    final b = await DatabaseHelper.instance.getHadithBooks();
    if (mounted) {
      setState(() => _books = ['الكل', ...b.map((e) => e['name'] as String)]);
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _loading = true);
    
    List<Map<String, Object?>> results = [];
    if (_searchCtrl.text.isNotEmpty) {
      results = await DatabaseHelper.instance.searchHadiths(_searchCtrl.text);
    } else if (_selectedBook != 'الكل') {
      results = await DatabaseHelper.instance.getHadithsByBook(_selectedBook);
    } else {
      // في الويب هذا سيرجع قائمة فارغة (لأن الداتا بيز الويب تجريبية)
      // في الموبايل سيرجع 41 ألف حديث، ولهذا نأخذ أول 50 فقط للعرض السريع
      results = (await DatabaseHelper.instance.getHadiths()).take(50).toList();
    }

    // تطبيق فلتر التصنيف
    if (_selectedGrade != 'الكل') {
      results = results.where((h) => h['grade'] == _selectedGrade).toList();
    }

    if (mounted) {
      setState(() {
        _hadiths = results;
        _loading = false;
      });
    }
  }

  Color _getGradeColor(String? grade) {
    if (grade == 'صحيح') return const Color(0xFF2E7D32);
    if (grade == 'حسن') return const Color(0xFFEF6C00);
    if (grade == 'ضعيف') return const Color(0xFFC62828);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC), // لون بيج إسلامي
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الأحاديث النبوية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // 1. شريط البحث الاحترافي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _applyFilters(),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث بكلمة، رقم حديث، أو راوٍ...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primary),
                    onPressed: _showFilterBottomSheet,
                  ),
                ),
              ),
            ),
          ),

          // 2. اختيار الكتاب (Chips أفقية)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _books.length,
              itemBuilder: (context, i) {
                final book = _books[i];
                final isSelected = _selectedBook == book;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(book, style: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontFamily: 'Cairo', fontSize: 13)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    onSelected: (val) {
                      setState(() => _selectedBook = book);
                      _applyFilters();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                  ),
                );
              },
            ),
          ),

          // 3. قائمة الأحاديث
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _hadiths.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _hadiths.length,
                        itemBuilder: (context, i) => _buildHadithCard(_hadiths[i]),
                      ),
          ),
        ],
      ),
    );
  }

  // 🎨 كارت الحديث الاحترافي
  Widget _buildHadithCard(Map<String, Object?> h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس الكارت
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${h['book']} • حديث ${h['hadith_number']}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGradeColor(h['grade'] as String?).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getGradeColor(h['grade'] as String?)),
                  ),
                  child: Text(
                    h['grade'] as String? ?? 'غير محدد',
                    style: TextStyle(color: _getGradeColor(h['grade'] as String?), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // نص الحديث
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '« ${h['arabic_text']} »',
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.text, fontSize: 20, height: 1.8, fontFamily: 'UthmanicHafs'),
            ),
          ),

          // الراوي وأزرار التفاعل
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'الراوي: ${h['narrator'] ?? 'غير معروف'}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.copy, size: 20, color: AppColors.textMuted), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.share, size: 20, color: AppColors.textMuted), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.bookmark_border, size: 20, color: AppColors.textMuted), onPressed: () {}),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 الحالة الفارغة الاحترافية
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('لم نجد أي أحاديث تطابق بحثك', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('جرب تغيير كلمات البحث أو مسح الفلاتر', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchCtrl.clear();
              setState(() { _selectedBook = 'الكل'; _selectedGrade = 'الكل'; });
              _applyFilters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('مسح الفلاتر والبحث'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )
        ],
      ),
    );
  }

  // ⚙️ نافذة الفلاتر السفلية
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تصفية حسب التصنيف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['الكل', 'صحيح', 'حسن', 'ضعيف'].map((grade) {
                  final isSel = _selectedGrade == grade;
                  return ChoiceChip(
                    label: Text(grade),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.text),
                    onSelected: (v) {
                      setState(() => _selectedGrade = grade);
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
