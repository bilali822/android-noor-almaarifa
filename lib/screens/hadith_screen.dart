import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/support_card.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _screenshotController = ScreenshotController();

  List<Map<String, Object?>> _hadiths = [];
  List<String> _books = ['الكل'];
  String _selectedBook = 'الكل';
  String _selectedGrade = 'الكل';
  
  bool _loading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  bool get wantKeepAlive => true; // 🌟 يحفظ الشاشة في الذاكرة

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // 🌟 شاشة كاملة
    _loadBooks();
    _resetAndLoad();
    
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200 && 
          !_isLoadingMore && _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadBooks() async {
    final b = await DatabaseHelper.instance.getHadithBooks();
    if (mounted) {
      setState(() => _books = ['الكل', ...b.map((e) => e['name'] as String)]);
    }
  }

  Future<void> _resetAndLoad() async {
    setState(() {
      _loading = true;
      _offset = 0;
      _hasMore = true;
      _hadiths.clear();
    });

    if (_searchCtrl.text.isNotEmpty) {
      final results = await DatabaseHelper.instance.searchHadiths(_searchCtrl.text);
      if (mounted) {
        setState(() {
          _hadiths = results;
          _loading = false;
          _hasMore = false;
        });
      }
    } else if (_selectedBook != 'الكل') {
      final results = await DatabaseHelper.instance.getHadithsByBookPaginated(_selectedBook, _limit, 0);
      if (mounted) {
        setState(() {
          _hadiths = results;
          _offset = results.length;
          _hasMore = results.length == _limit;
          _loading = false;
        });
      }
    } else {
      final results = await DatabaseHelper.instance.getHadithsPaginated(_limit, 0);
      if (mounted) {
        setState(() {
          _hadiths = results;
          _offset = results.length;
          _hasMore = results.length == _limit;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    List<Map<String, Object?>> results = [];

    if (_selectedBook != 'الكل' && _searchCtrl.text.isEmpty) {
      results = await DatabaseHelper.instance.getHadithsByBookPaginated(_selectedBook, _limit, _offset);
    } else if (_searchCtrl.text.isEmpty) {
      results = await DatabaseHelper.instance.getHadithsPaginated(_limit, _offset);
    }

    if (mounted) {
      setState(() {
        _hadiths.addAll(results);
        _offset += results.length;
        _hasMore = results.length == _limit;
        _isLoadingMore = false;
      });
    }
  }

  Color _getGradeColor(String? grade) {
    if (grade == 'صحيح') return const Color(0xFF2E7D32);
    if (grade == 'حسن') return const Color(0xFFEF6C00);
    if (grade == 'ضعيف') return const Color(0xFFC62828);
    return Colors.grey;
  }

  Future<void> _shareHadithImage(Map<String, Object?> h) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32), width: 400,
            decoration: BoxDecoration(color: const Color(0xFFF8F4EC), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary, width: 2)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${h['book']} • حديث ${h['hadith_number']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _getGradeColor(h['grade'] as String?).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(h['grade'] as String? ?? '', style: TextStyle(color: _getGradeColor(h['grade'] as String?), fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Text('« ${h['arabic_text']} »', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 24, height: 2.0, fontFamily: 'UthmanicHafs')),
                const SizedBox(height: 24),
                Text('الراوي: ${h['narrator'] ?? 'غير معروف'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 16),
                const Text('تطبيق نور المعرفة', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
      final xFile = XFile.fromData(image, mimeType: 'image/png', name: 'hadith.png');
      await Share.shareXFiles([xFile], text: 'حديث نبوي شريف');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر مشاركة الصورة.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🌟 مطلوب لـ KeepAlive
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('الأحاديث النبوية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: TextField(
                controller: _searchCtrl, onSubmitted: (_) => _resetAndLoad(), textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث بكلمة، رقم حديث، أو راوٍ...', hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: IconButton(icon: const Icon(Icons.tune, color: AppColors.primary), onPressed: _showFilterBottomSheet),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _books.length,
              itemBuilder: (context, i) {
                final book = _books[i];
                final isSelected = _selectedBook == book;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(book, style: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontFamily: 'Cairo', fontSize: 13)),
                    selected: isSelected, selectedColor: AppColors.primary, backgroundColor: Colors.white,
                    onSelected: (val) { setState(() => _selectedBook = book); _resetAndLoad(); },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _hadiths.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollCtrl, padding: const EdgeInsets.all(16),
                        itemCount: _hadiths.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _hadiths.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                          return _buildHadithCard(_hadiths[i]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(Map<String, Object?> h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))], border: Border.all(color: AppColors.primary.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${h['book']} • حديث ${h['hadith_number']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _getGradeColor(h['grade'] as String?).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getGradeColor(h['grade'] as String?))),
                  child: Text(h['grade'] as String? ?? 'غير محدد', style: TextStyle(color: _getGradeColor(h['grade'] as String?), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: Text('« ${h['arabic_text']} »', textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.text, fontSize: 20, height: 1.8, fontFamily: 'UthmanicHafs'))),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Text('الراوي: ${h['narrator'] ?? 'غير معروف'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.copy, size: 20, color: AppColors.textMuted), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.share, size: 20, color: AppColors.primary), onPressed: () => _shareHadithImage(h)),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
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
              onPressed: () { _searchCtrl.clear(); setState(() { _selectedBook = 'الكل'; _selectedGrade = 'الكل'; }); _resetAndLoad(); },
              icon: const Icon(Icons.refresh), label: const Text('مسح الفلاتر والبحث'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 32),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SupportCard())
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تصفية حسب التصنيف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['الكل', 'صحيح', 'حسن', 'ضعيف'].map((grade) {
                  final isSel = _selectedGrade == grade;
                  return ChoiceChip(
                    label: Text(grade), selected: isSel, selectedColor: AppColors.primary, labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.text),
                    onSelected: (v) { setState(() => _selectedGrade = grade); Navigator.pop(context); _resetAndLoad(); },
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
