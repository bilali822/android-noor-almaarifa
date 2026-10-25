import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
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
  int _currentSurah = 1;
  String _currentSurahName = 'الفاتحة';
  int? _highlightedVerse;

  final Color bgColor = const Color(0xFFF8F4EC);
  final Color frameColor = const Color(0xFF155E35);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color textColor = const Color(0xFF1A1A1A);

  final List<TapGestureRecognizer> _recognizers = [];
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurahId;
    _pageController = PageController(initialPage: _currentSurah - 1);
    _loadSurahName(_currentSurah);
    _checkLastRead();
  }

  Future<void> _loadSurahName(int surahId) async {
    final s = await DatabaseHelper.instance.getSurah(surahId);
    if (s.isNotEmpty && mounted) {
      setState(() => _currentSurahName = s.first['name_ar'] as String);
    }
  }

  Future<void> _checkLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSurah = prefs.getInt('last_read_surah');
    final savedVerse = prefs.getInt('last_read_verse');
    
    if (savedSurah != null && mounted) {
      if (savedSurah != _currentSurah) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('لديك علامة محفوظة في سورة رقم $savedSurah${savedVerse != null ? ' آية $savedVerse' : ''}'),
              action: SnackBarAction(
                label: 'الذهاب',
                onPressed: () {
                  _pageController.jumpToPage(savedSurah - 1);
                  if (savedVerse != null) setState(() => _highlightedVerse = savedVerse);
                },
              ),
            ),
          );
        });
      } else if (savedVerse != null) {
        setState(() => _highlightedVerse = savedVerse);
      }
    }
  }

  Future<void> _saveLastRead(int surahId, int? verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahId);
    if (verse != null) await prefs.setInt('last_read_verse', verse);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ العلامة')));
  }

  void _openSearch() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MushafSearchScreen()),
    );
    if (result != null && mounted) {
      final targetSurah = result['surahId'] as int;
      final targetVerse = result['verseNumber'] as int;
      
      setState(() => _highlightedVerse = targetVerse);
      _pageController.jumpToPage(targetSurah - 1);
      
      // مسح التظليل بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedVerse = null);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var r in _recognizers) { r.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('المصحف الشريف', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: _openSearch,
          ),
          IconButton(
            icon: const Icon(Icons.list, color: AppColors.primary),
            onPressed: _showSurahSelection,
          )
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 114,
        onPageChanged: (index) {
          setState(() => _currentSurah = index + 1);
          _loadSurahName(_currentSurah);
        },
        itemBuilder: (context, index) {
          final surahId = index + 1;
          return _MushafSurahPage(
            surahId: surahId,
            highlightedVerse: _highlightedVerse,
            onVerseTap: (surahName, verseNumber, verseText) {
              _showVerseOptions(surahId, surahName, verseNumber, verseText);
            },
          );
        },
      ),
    );
  }

  void _showVerseOptions(int surahId, String surahName, int verseNumber, String verseText) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('سورة $surahName - آية $verseNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                _buildOptionButton(Icons.bookmark_add, 'علامة', Colors.orange, () {
                  Navigator.pop(context);
                  _saveLastRead(surahId, verseNumber);
                }),
                _buildOptionButton(Icons.share, 'مشاركة', Colors.purple, () {
                  Navigator.pop(context);
                  _shareVerse(surahName, verseNumber, verseText);
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _openTafsir(int surahId, String surahName, int verseNumber, String verseText) async {
    // 🌟 نجيب بس الكتب اللي عندها تفسير للآية دي
    final books = await DatabaseHelper.instance.getTafsirBooksForVerse(surahId, verseNumber);
    if (!mounted) return;

    if (books.isEmpty) {
      _showSnack('لا يوجد تفسير متاح لهذه الآية');
      return;
    }

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
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/ayah_share.png').create();
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'آية من القرآن الكريم');
    } catch (e) { _showSnack('تعذر مشاركة الصورة.'); }
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
                            onTap: () { Navigator.pop(context); _pageController.jumpToPage((s['id'] as int) - 1); },
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

// 🌟 صفحة السورة (StatefulWidget عشان تدير التمرير والتظليل)
class _MushafSurahPage extends StatefulWidget {
  final int surahId;
  final int? highlightedVerse;
  final Function(String, int, String) onVerseTap;

  const _MushafSurahPage({required this.surahId, this.highlightedVerse, required this.onVerseTap});

  @override
  State<_MushafSurahPage> createState() => _MushafSurahPageState();
}

class _MushafSurahPageState extends State<_MushafSurahPage> {
  final ScrollController _scrollController = ScrollController();
  final List<TapGestureRecognizer> _recognizers = [];
  final Color bgColor = const Color(0xFFF8F4EC);
  final Color frameColor = const Color(0xFF155E35);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void didUpdateWidget(covariant _MushafSurahPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedVerse != null && widget.highlightedVerse != oldWidget.highlightedVerse) {
      _scrollToVerse(widget.highlightedVerse!);
    }
  }

  void _scrollToVerse(int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final totalVerses = 7; // تقريبياً، أو نمرره من البيانات
        final maxExtent = _scrollController.position.maxScrollExtent;
        final offset = (verseNumber / 10) * maxExtent; // تقدير تقريبي
        _scrollController.animateTo(offset.clamp(0.0, maxExtent), duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var r in _recognizers) { r.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        DatabaseHelper.instance.getVerses(widget.surahId),
        DatabaseHelper.instance.getSurah(widget.surahId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        
        final verses = snapshot.data![0];
        final surahInfo = snapshot.data![1];
        
        if (surahInfo.isEmpty) return const Center(child: Text('جاري التحميل...'));
        if (verses.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.info_outline, size: 60, color: AppColors.primary), const SizedBox(height: 16), const Text('هذه السورة غير متاحة في نسخة الويب.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text), textAlign: TextAlign.center), const SizedBox(height: 8), const Text('لتجربة المصحف كاملاً، قم بتثبيت تطبيق الأندرويد.', style: TextStyle(color: AppColors.textMuted, fontSize: 14), textAlign: TextAlign.center)]))); 
        }

        final surahName = surahInfo.first['name_ar'] as String;
        final surahNum = surahInfo.first['id'] as int;
        final versesCount = surahInfo.first['verses_count'] as int;

        for (var r in _recognizers) { r.dispose(); }
        _recognizers.clear();

        final List<InlineSpan> textSpans = [];
        for (var v in verses) {
          final verseNumber = v['verse_number'] as int;
          final arabicNum = _toArabicNumeral(verseNumber);
          
          final recognizer = TapGestureRecognizer()..onTap = () => widget.onVerseTap(surahName, verseNumber, v['text_ar'] as String);
          _recognizers.add(recognizer);

          final isHighlighted = verseNumber == widget.highlightedVerse;

          textSpans.add(TextSpan(
            children: [
              TextSpan(
                text: '${v['text_ar']} ', 
                recognizer: recognizer,
                style: TextStyle(backgroundColor: isHighlighted ? goldColor.withOpacity(0.3) : null),
              ),
              TextSpan(
                text: '﴿$arabicNum﴾ ', 
                style: TextStyle(color: frameColor, fontSize: 22, backgroundColor: isHighlighted ? goldColor.withOpacity(0.3) : null), 
                recognizer: recognizer,
              ),
            ],
          ));
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: goldColor, width: 3), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: frameColor, width: 1.5), borderRadius: BorderRadius.circular(8), gradient: LinearGradient(colors: [bgColor, bgColor.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              children: [
                Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(gradient: LinearGradient(colors: [frameColor, frameColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: frameColor.withOpacity(0.3), blurRadius: 5)]), child: Text('سورة $surahName', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        if (widget.surahId != 1 && widget.surahId != 9) Padding(padding: const EdgeInsets.only(bottom: 20), child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24, color: frameColor, fontWeight: FontWeight.bold))),
                        RichText(textDirection: TextDirection.rtl, textAlign: TextAlign.justify, text: TextSpan(style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 28, height: 2.4, color: textColor), children: textSpans)),
                      ],
                    ),
                  ),
                ),
                Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: goldColor.withOpacity(0.1), border: Border(top: BorderSide(color: goldColor, width: 1))), child: Text('سورة رقم $surahNum • $versesCount آية', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 14, color: frameColor, fontWeight: FontWeight.bold))),
              ],
            ),
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
