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
  int _currentSurah = 1;
  String _currentSurahName = 'الفاتحة';
  int? _highlightedVerse;

  // 🌟 متغيرات لحفظ العلامات (تعليم ومفضلة)
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
    _currentSurah = widget.initialSurahId;
    _pageController = PageController(initialPage: _currentSurah - 1);
    _loadSurahName(_currentSurah);
    _loadSavedData(); // 🌟 تحميل العلامات المحفوظة
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // 🌟 دالة جلب العلامات من الذاكرة
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

  Future<void> _loadSurahName(int surahId) async {
    final s = await DatabaseHelper.instance.getSurah(surahId);
    if (s.isNotEmpty && mounted) {
      setState(() => _currentSurahName = s.first['name_ar'] as String);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          PageView.builder(
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
                lastReadVerse: (_lastReadSurah == surahId) ? _lastReadVerse : null,
                bookmarks: _bookmarks,
                onVerseTap: (surahName, verseNumber, verseText) {
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
                    // 🌟 زر متابعة القراءة (يظهر فقط إذا كان هناك تعليم)
                    if (_lastReadSurah != null) ...[
                      _buildFloatingButton(
                        icon: Icons.bookmark,
                        iconColor: Colors.orange,
                        onPressed: () {
                          _pageController.jumpToPage(_lastReadSurah! - 1);
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
      setState(() => _highlightedVerse = result['verseNumber'] as int);
      _pageController.jumpToPage(targetSurah - 1);
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
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    final key = '$surahId:$verseNumber';
    
    if (saved.contains(key)) {
      _showSnack('الآية محفوظة مسبقاً في المفضلة');
    } else {
      saved.add(key);
      await prefs.setStringList('bookmarks', saved);
      _showSnack('✅ تم حفظ الآية في المفضلة');
      _loadSavedData(); // 🌟 تحديث الشاشة لتظهر أيقونة الحفظ
    }
  }

  Future<void> _setLastRead(int surahId, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahId);
    await prefs.setInt('last_read_verse', verseNumber);
    if (mounted) _showSnack('📍 تم تعيين علامة القراءة (تعليم) هنا');
    _loadSavedData(); // 🌟 تحديث الشاشة لتظهر علامة التعليم وزر المتابعة
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

// 🌟 صفحة السورة (مع إضافة أيقونات التعليم والحفظ)
class _MushafSurahPage extends StatefulWidget {
  final int surahId;
  final int? highlightedVerse;
  final int? lastReadVerse;
  final Set<String> bookmarks;
  final Function(String, int, String) onVerseTap;

  const _MushafSurahPage({
    required this.surahId, 
    this.highlightedVerse, 
    this.lastReadVerse,
    required this.bookmarks,
    required this.onVerseTap
  });

  @override
  State<_MushafSurahPage> createState() => _MushafSurahPageState();
}

class _MushafSurahPageState extends State<_MushafSurahPage> {
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

        for (var r in _recognizers) { r.dispose(); }
        _recognizers.clear();

        final List<InlineSpan> textSpans = [];
        for (var v in verses) {
          final verseNumber = v['verse_number'] as int;
          final arabicNum = _toArabicNumeral(verseNumber);
          
          final recognizer = TapGestureRecognizer()
            ..onTap = () => widget.onVerseTap(surahName, verseNumber, v['text_ar'] as String);
          _recognizers.add(recognizer);
          
          final isHighlighted = verseNumber == widget.highlightedVerse;
          final isLastRead = verseNumber == widget.lastReadVerse;
          final isBookmarked = widget.bookmarks.contains('${widget.surahId}:$verseNumber');

          textSpans.add(TextSpan(
            children: [
              TextSpan(
                text: '${v['text_ar']} ', 
                recognizer: recognizer, 
                style: TextStyle(backgroundColor: isHighlighted ? const Color(0xFFF1E5C9) : null)
              ),
              // رقم الآية
              TextSpan(
                text: '﴿$arabicNum﴾ ', 
                style: TextStyle(
                  color: frameColor, 
                  fontSize: 22, 
                  backgroundColor: isHighlighted ? const Color(0xFFF1E5C9) : null
                ), 
                recognizer: recognizer
              ),
              // 🌟 أيقونة التعليم (تظهر بجانب الآية)
              if (isLastRead)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Icon(Icons.push_pin, color: Colors.redAccent, size: 18),
                  ),
                ),
              // 🌟 أيقونة الحفظ (تظهر بجانب الآية)
              if (isBookmarked)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Icon(Icons.bookmark, color: Colors.purple, size: 18),
                  ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text('سورة $surahName', style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 28, fontWeight: FontWeight.bold, color: frameColor)),
                      ),
                      if (widget.surahId != 1 && widget.surahId != 9) 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24), 
                          child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24, color: frameColor, fontWeight: FontWeight.bold))
                        ),
                      RichText(
                        textDirection: TextDirection.rtl, 
                        textAlign: TextAlign.justify, 
                        text: TextSpan(
                          style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 28, height: 2.6, color: textColor), 
                          children: textSpans
                        ),
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
