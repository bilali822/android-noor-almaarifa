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
import '../services/device_profiler.dart';

class MushafScreen extends StatefulWidget {
  final int initialSurahId;
  const MushafScreen({super.key, this.initialSurahId = 1});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  final Map<int, List<Map<String, Object?>>> _pageCache = {};
  int? _highlightedVerse;
  int? _lastReadPage;

  final Color bgColor = const Color(0xFFFDFBF7); 
  final Color frameColor = const Color(0xFF155E35);
  final Color textColor = const Color(0xFF1A1A1A);

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage - 1);
    _loadSavedData(); 
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastReadPage = prefs.getInt('last_read_page') ?? 1;
        _currentPage = _lastReadPage!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPage - 1);
          }
        });
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
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            onPageChanged: (index) {
              setState(() => _currentPage = index + 1);
            },
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return _MushafPageView(
                pageNumber: pageNumber,
                highlightedVerse: _highlightedVerse,
                onVerseTap: (surahName, verseNumber, verseText) {
                  _showVerseOptions(pageNumber, surahName, verseNumber, verseText);
                },
              );
            },
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildFloatingButton(
                      icon: Icons.workspace_premium,
                      iconColor: const Color(0xFFD4AF37),
                      onPressed: () {
                        if (_lastReadPage != null) {
                          _pageController.jumpToPage(_lastReadPage! - 1);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFloatingButton(icon: Icons.search, onPressed: _openSearch),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: DeviceProfiler.isLowEnd ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: frameColor.withOpacity(0.1)),
                  ),
                  child: Text('صفحة $_currentPage', style: TextStyle(color: frameColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'UthmanicHafs')),
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
        boxShadow: DeviceProfiler.isLowEnd ? [] : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
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
      setState(() => _highlightedVerse = result['verseNumber'] as int);
    }
  }

  void _showVerseOptions(int pageNumber, String surahName, int verseNumber, String verseText) {
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
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildOptionButton(Icons.copy, 'نسخ', Colors.blue, () {
                      Clipboard.setData(ClipboardData(text: verseText));
                      Navigator.pop(context);
                      _showSnack('تم نسخ الآية');
                    }),
                    _buildOptionButton(Icons.menu_book, 'تفسير', Colors.green, () {
                      Navigator.pop(context);
                      _openTafsir(pageNumber, surahName, verseNumber, verseText);
                    }),
                    _buildOptionButton(Icons.workspace_premium, 'تعليم', const Color(0xFFD4AF37), () {
                      Navigator.pop(context);
                      _setLastRead(pageNumber);
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

  Future<void> _setLastRead(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_page', pageNumber);
    if (mounted) _showSnack('📍 تم تعيين علامة القراءة (تعليم) هنا');
    _loadSavedData(); 
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _openTafsir(int pageNumber, String surahName, int verseNumber, String verseText) async {
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;
    if (books.isEmpty) { _showSnack('لا يوجد تفسير متاح لهذه الآية'); return; }
    
    final selected = await showModalBottomSheet<List<String>>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(surahName: surahName, surahId: 1, verseNumber: verseNumber, verseText: verseText, books: books),
    );
    
    if (selected != null && selected.isNotEmpty && mounted) {
      final tafsirs = await DatabaseHelper.instance.getTafsirs(1, verseNumber);
      final List<Map<String, String>> tafsirList = [];
      for (var key in selected) {
        final book = books.firstWhere((b) => b['key'] == key, orElse: () => {'name_ar': key});
        final text = tafsirs.firstWhere((t) => t['book_key'] == key, orElse: () => {'text_ar': 'التفسير غير متوفر.'})['text_ar'] as String;
        tafsirList.add({'book_name': book['name_ar'] as String, 'text': text});
      }
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TafsirViewScreen(surahId: 1, surahName: surahName, verseNumber: verseNumber, verseText: verseText, tafsirList: tafsirList)));
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
}

class _MushafPageView extends StatefulWidget {
  final int pageNumber;
  final int? highlightedVerse;
  final Function(String, int, String) onVerseTap;

  const _MushafPageView({
    required this.pageNumber, 
    this.highlightedVerse, 
    required this.onVerseTap
  });

  @override
  State<_MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<_MushafPageView> {
  final Color frameColor = const Color(0xFF155E35);
  final Color textColor = const Color(0xFF1A1A1A);
  final Color goldColor = const Color(0xFFD4AF37);
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (var r in _recognizers) { r.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 استخدام الكاش لتسريع السحب بين الصفحات
    if (_pageCache.containsKey(widget.pageNumber)) {
      return _buildPageContent(_pageCache[widget.pageNumber]!);
    }

    return FutureBuilder(
      future: DatabaseHelper.instance.getVersesByPage(widget.pageNumber),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final verses = snapshot.data!;
        if (verses.isEmpty) return const Center(child: Text('جاري تحميل الصفحة...'));
        
        // حفظ في الكاش
        if (_pageCache.length > 5) _pageCache.clear();
        _pageCache[widget.pageNumber] = verses;

        return _buildPageContent(verses);
      },
    );
  }

  Widget _buildPageContent(List<Map<String, Object?>> verses) {
    {

        for (var r in _recognizers) { r.dispose(); }
        _recognizers.clear();

        // 🌟 اكتشاف بداية السورة والبسملة
        final firstVerse = verses.first;
        final isSurahStart = firstVerse['verse_number'] == 1;
        final surahName = firstVerse['surah_name'] as String? ?? '';
        final surahId = firstVerse['surah_id'] as int;
        final showBismillah = isSurahStart && surahId != 1 && surahId != 9;

        final List<InlineSpan> textSpans = [];
        for (var v in verses) {
          final verseNumber = v['verse_number'] as int;
          final arabicNum = _toArabicNumeral(verseNumber);
          
          final recognizer = TapGestureRecognizer()
            ..onTap = () => widget.onVerseTap(surahName, verseNumber, v['text_ar'] as String);
          _recognizers.add(recognizer);
          
          textSpans.add(TextSpan(
            children: [
              TextSpan(
                text: '${v['text_ar']} ', 
                recognizer: recognizer,
                style: TextStyle(backgroundColor: widget.highlightedVerse == verseNumber ? const Color(0xFFF1E5C9) : null)
              ),
              TextSpan(
                text: '﴿$arabicNum﴾ ', 
                style: TextStyle(
                  color: frameColor, 
                  fontSize: 22, 
                  backgroundColor: widget.highlightedVerse == verseNumber ? const Color(0xFFF1E5C9) : null
                ), 
                recognizer: recognizer
              ),
            ],
          ));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40),
            child: Column(
              children: [
                // 🌟 التصميم الفخم لاسم السورة
                if (isSurahStart)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF155E35), Color(0xFF0E3A21)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goldColor, width: 2), // إطار ذهبي فاخر
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF155E35).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Text(
                      'سورة $surahName',
                      style: const TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                
                // 🌟 البسملة الفخمة
                if (showBismillah)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: 26,
                        color: frameColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
