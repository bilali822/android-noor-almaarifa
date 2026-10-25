import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/tafsir_sheet.dart';
import 'tafsir_view_screen.dart';
import 'mushaf_search_screen.dart';

class MushafScreen extends StatefulWidget {
  final int initialSurahId;
  const MushafScreen({super.key, this.initialSurahId = 1});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late PageController _pageController;
  int _currentPage = 1; // 🌟 نبدأ من الصفحة 1 بدلاً من السورة
  String _currentSurahName = 'الفاتحة';
  int? _highlightedVerse;

  int? _lastReadSurah;
  int? _lastReadVerse;
  Set<String> _bookmarks = {};

  final Color bgColor = const Color(0xFFFDFBF7); 
  final Color frameColor = const Color(0xFF155E35);
  final Color textColor = const Color(0xFF1A1A1A);

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSavedData();
    _updateSurahNameForPage(1);
  }

  Future<void> _updateSurahNameForPage(int page) async {
    // جلب الآية الأولى في الصفحة لمعرفة اسم السورة
    final verses = await DatabaseHelper.instance.getVersesByPage(page);
    if (verses.isNotEmpty && mounted) {
      setState(() => _currentSurahName = verses.first['surah_name'] as String);
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastReadSurah = prefs.getInt('last_read_surah');
        _lastReadVerse = prefs.getInt('last_read_verse');
        _bookmarks = (prefs.getStringList('bookmarks') ?? []).toSet();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 🌟 604 صفحة بدلاً من 114 سورة
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            onPageChanged: (index) {
              setState(() => _currentPage = index + 1);
              _updateSurahNameForPage(_currentPage);
            },
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return _MushafPage(
                pageNumber: pageNumber,
                highlightedVerse: _highlightedVerse,
                lastReadVerse: (_lastReadSurah == _currentPage) ? _lastReadVerse : null, // ملاحظة: هذا يحتاج تعديل ليعتمد على الصفحة وليس السورة
                bookmarks: _bookmarks,
                onVerseTap: (surahName, verseNumber, verseText, surahId) {
                  _showVerseOptions(surahId, surahName, verseNumber, verseText);
                },
              );
            },
          ),
          
          // الشريط العلوي العائم
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (_lastReadSurah != null) ...[
                      _buildFloatingButton(
                        icon: Icons.bookmark,
                        iconColor: Colors.orange,
                        onPressed: () async {
                          final startPage = await DatabaseHelper.instance.getSurahStartPage(_lastReadSurah!);
                          _pageController.jumpToPage(startPage - 1);
                          setState(() => _highlightedVerse = _lastReadVerse);
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildFloatingButton(icon: Icons.search, onPressed: _openSearch),
                    const SizedBox(width: 8),
                    _buildFloatingButton(icon: Icons.format_list_bulleted, onPressed: _showSurahSelection),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: frameColor.withOpacity(0.1)),
                  ),
                  child: Text('سورة $_currentSurahName', style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'UthmanicHafs')),
                ),
                _buildFloatingButton(icon: Icons.arrow_forward_ios, onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({required IconData icon, Color iconColor = const Color(0xFF155E35), required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: frameColor.withOpacity(0.1), width: 1),
      ),
      child: IconButton(icon: Icon(icon, color: iconColor, size: 22), onPressed: onPressed),
    );
  }

  void _openSearch() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context, MaterialPageRoute(builder: (_) => const MushafSearchScreen()),
    );
    if (result != null && mounted) {
      final targetSurah = result['surahId'] as int;
      final startPage = await DatabaseHelper.instance.getSurahStartPage(targetSurah);
      setState(() => _highlightedVerse = result['verseNumber'] as int);
      _pageController.jumpToPage(startPage - 1);
      Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _highlightedVerse = null); });
    }
  }

  void _showVerseOptions(int surahId, String surahName, int verseNumber, String verseText) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 28), onPressed: () => Navigator.pop(context)),
                    Text('سورة $surahName - آية $verseNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildOptionButton(Icons.copy, 'نسخ', Colors.blue, () {
                      Clipboard.setData(ClipboardData(text: verseText));
                      Navigator.pop(context);
                      _showSnack('تم نسخ الآية');
                    }),
                    _buildOptionButton(Icons.menu_book, 'تفسير', Colors.green, () {
                      Navigator.pop(context);
                      _openTafsir(surahId, surahName, verseNumber, verseText);
                    }),
                    _buildOptionButton(Icons.bookmark_add, 'حفظ', Colors.purple, () {
                      Navigator.pop(context);
                      _saveVerse(surahId, verseNumber);
                    }),
                    _buildOptionButton(Icons.push_pin, 'تعليم', Colors.redAccent, () {
                      Navigator.pop(context);
                      _setLastRead(surahId, verseNumber);
                    }),
                    _buildOptionButton(Icons.share, 'مشاركة', Colors.orange, () {
                      Navigator.pop(context);
                      _shareVerse(surahName, verseNumber, verseText);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _saveVerse(int surahId, int verseNumber) async {
    final key = '$surahId:$verseNumber';
    if (_bookmarks.contains(key)) {
      setState(() => _bookmarks.remove(key));
      _showSnack('تم إزالة الآية من المفضلة');
    } else {
      setState(() => _bookmarks.add(key));
      _showSnack('✅ تم حفظ الآية في المفضلة');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', _bookmarks.toList());
  }

  Future<void> _setLastRead(int surahId, int verseNumber) async {
    setState(() {
      _lastReadSurah = surahId;
      _lastReadVerse = verseNumber;
    });
    if (mounted) _showSnack('📍 تم تعيين علامة القراءة (تعليم) هنا');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahId);
    await prefs.setInt('last_read_verse', verseNumber);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _openTafsir(int surahId, String surahName, int verseNumber, String verseText) async {
    final books = await DatabaseHelper.instance.getTafsirBooksForVerse(surahId, verseNumber);
    if (!mounted) return;
    if (books.isEmpty) { _showSnack('لا يوجد تفسير متاح لهذه الآية'); return; }
    
    final selected = await showModalBottomSheet<List<String>>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(surahName: surahName, surahId: surahId, verseNumber: verseNumber, verseText: verseText, books: books),
    );
    
    if (selected != null && selected.isNotEmpty && mounted) {
      final tafsirs = await DatabaseHelper.instance.getTafsirs(surahId, verseNumber);
      final List<Map<String, String>> tafsirList = [];
      for (var key in selected) {
        final book = books.firstWhere((b) => b['key'] == key, orElse: () => {'name_ar': key});
        final text = tafsirs.firstWhere((t) => t['book_key'] == key, orElse: () => {'text_ar': 'التفسير غير متوفر.'})['text_ar'] as String;
        tafsirList.add({'book_name': book['name_ar'] as String, 'text': text});
      }
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TafsirViewScreen(surahId: surahId, surahName: surahName, verseNumber: verseNumber, verseText: verseText, tafsirList: tafsirList)));
      }
    }
  }

  Future<void> _shareVerse(String surahName, int verseNumber, String verseText) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        Material(color: Colors.transparent, child: Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: const Color(0xFFF4EAE0), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary, width: 2)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('﴿ $verseText ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 28, height: 2.2, fontFamily: 'UthmanicHafs')), const SizedBox(height: 16), Text('سورة $surahName - الآية $verseNumber', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 16), const Text('تطبيق نور المعرفة', style: TextStyle(color: AppColors.textMuted, fontSize: 10))]))), delay: const Duration(milliseconds: 10),
      );
      
      final xFile = XFile.fromData(image, mimeType: 'image/png', name: 'ayah_${surahName}_$verseNumber.png');
      await Share.shareXFiles([xFile], text: 'آية من القرآن الكريم');
    } catch (e) { 
      _showSnack('تعذر مشاركة الصورة.'); 
    }
  }

  void _showSurahSelection() {
    showModalBottomSheet(
      context: context, backgroundColor: bgColor, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
          builder: (context, scrollController) {
            return FutureBuilder(
              future: DatabaseHelper.instance.getSurahs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final surahs = snapshot.data!;
                return Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(16), child: Text('اختر السورة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary))),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController, itemCount: surahs.length,
                        itemBuilder: (context, i) {
                          final s = surahs[i];
                          return ListTile(
                            title: Text('سورة ${s['name_ar']}', style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 22, color: AppColors.primary)),
                            trailing: Text('${s['verses_count']} آية', style: const TextStyle(color: Colors.black54)),
                            onTap: () async { 
                              Navigator.pop(context); 
                              final startPage = await DatabaseHelper.instance.getSurahStartPage(s['id'] as int);
                              _pageController.jumpToPage(startPage - 1); 
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// 🌟 صفحة المصحف (تعرض مجموعة آيات تنتمي لرقم صفحة معين)
class _MushafPage extends StatefulWidget {
  final int pageNumber;
  final int? highlightedVerse;
  final int? lastReadVerse;
  final Set<String> bookmarks;
  final Function(String, int, String, int) onVerseTap;

  const _MushafPage({
    required this.pageNumber, 
    this.highlightedVerse, 
    this.lastReadVerse,
    required this.bookmarks,
    required this.onVerseTap
  });

  @override
  State<_MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<_MushafPage> {
  final ScrollController _scrollController = ScrollController();
  final List<TapGestureRecognizer> _recognizers = [];
  final Color frameColor = const Color(0xFF155E35);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void dispose() {
    _scrollController.dispose();
    for (var r in _recognizers) { r.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.getVersesByPage(widget.pageNumber),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

        final verses = snapshot.data!;

        if (verses.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.info_outline, size: 60, color: AppColors.primary), const SizedBox(height: 16), const Text('هذه الصفحة غير متاحة في نسخة الويب.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text), textAlign: TextAlign.center), const SizedBox(height: 8), const Text('لتجربة المصحف كاملاً، قم بتثبيت تطبيق الأندرويد.', style: TextStyle(color: AppColors.textMuted, fontSize: 14), textAlign: TextAlign.center)])));
        }

        for (var r in _recognizers) { r.dispose(); }
        _recognizers.clear();

        final List<InlineSpan> textSpans = [];
        
        for (var v in verses) {
          final verseNumber = v['verse_number'] as int;
          final surahId = v['surah_id'] as int;
          final surahName = v['surah_name'] as String;
          final arabicNum = _toArabicNumeral(verseNumber);
          
          final recognizer = TapGestureRecognizer()
            ..onTap = () => widget.onVerseTap(surahName, verseNumber, v['text_ar'] as String, surahId);
          _recognizers.add(recognizer);
          
          final isHighlighted = verseNumber == widget.highlightedVerse;
          final isLastRead = verseNumber == widget.lastReadVerse;

          // 🌟 عرض اسم السورة والزخرفة إذا كانت الآية هي الأولى في السورة
          if (verseNumber == 1) {
            // إضافة اسم السورة كعنوان
            textSpans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: frameColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: frameColor.withOpacity(0.3)),
                ),
                child: Text('سورة $surahName', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24, fontWeight: FontWeight.bold, color: frameColor)),
              ),
            ));
            
            // إضافة البسملة (ما عدا التوبة والفاتحة)
            if (surahId != 1 && surahId != 9) {
              textSpans.add(WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24, color: frameColor, fontWeight: FontWeight.bold)),
                ),
              ));
            }
          }

          textSpans.add(TextSpan(
            children: [
              TextSpan(
                text: '${v['text_ar']} ', 
                recognizer: recognizer, 
                style: TextStyle(backgroundColor: isHighlighted ? const Color(0xFFF1E5C9) : null)
              ),
              // رقم الآية (مع الختم الذهبي الفاخر للتعليم)
              if (isLastRead)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => widget.onVerseTap(surahName, verseNumber, v['text_ar'] as String, surahId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: Text('﴿$arabicNum﴾', style: TextStyle(color: frameColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'UthmanicHafs', height: 1.4)),
                    ),
                  ),
                )
              else
                TextSpan(
                  text: '﴿$arabicNum﴾ ', 
                  style: TextStyle(color: frameColor, fontSize: 22, backgroundColor: isHighlighted ? const Color(0xFFF1E5C9) : null), 
                  recognizer: recognizer
                ),
            ],
          ));
        }

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 120),
                  child: Column(
                    children: [
                      RichText(
                        textDirection: TextDirection.rtl, 
                        textAlign: TextAlign.justify, 
                        text: TextSpan(
                          style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 28, height: 2.6, color: textColor), 
                          children: textSpans
                        ),
                      ),
                      // 🌟 رقم الصفحة في الأسفل
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Text('صفحة ${_toArabicNumeral(widget.pageNumber)}', style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        );
      },
    );
  }

  String _toArabicNumeral(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = number.toString();
    for (int i = 0; i < english.length; i++) { result = result.replaceAll(english[i], arabic[i]); }
    return result;
  }
}
