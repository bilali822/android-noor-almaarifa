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
  int _currentPage = 1; // 🌟 604 صفحة
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
        _pageController.jumpToPage(_currentPage - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 🌟 عرض الصفحات من 1 إلى 604
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
                lastReadVerse: null,
                onVerseTap: (surahName, verseNumber, verseText) {
                  _showVerseOptions(pageNumber, surahName, verseNumber, verseText);
                },
              );
            },
          ),
          
          // الشريط العلوي
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
      final targetSurah = result['surahId'] as int;
      setState(() => _highlightedVerse = result['verseNumber'] as int);
      // بما أننا نستخدم الصفحات، سنقوم بالبحث عن الصفحة التابعة للسورة
      // (سنفترض هنا أننا سنستخدم الصفحة 1 مؤقتاً في حالة البحث)
      _pageController.jumpToPage(0); 
    }
  }

  void _showVerseOptions(int pageNumber, String surahName, int verseNumber, String verseText) {
    // ... نفس الأكواد السابقة (نسخ، تفسير، تعليم، مشاركة)
  }
}

class _MushafPageView extends StatefulWidget {
  final int pageNumber;
  final int? highlightedVerse;
  final int? lastReadVerse;
  final Function(String, int, String) onVerseTap;

  const _MushafPageView({
    required this.pageNumber, 
    this.highlightedVerse, 
    this.lastReadVerse,
    required this.onVerseTap
  });

  @override
  State<_MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<_MushafPageView> {
  final Color frameColor = const Color(0xFF155E35);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.getVersesByPage(widget.pageNumber), // 🌟 جلب آيات الصفحة
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final verses = snapshot.data!;
        if (verses.isEmpty) return const Center(child: Text('جاري تحميل الصفحة...'));

        final List<InlineSpan> textSpans = [];
        for (var v in verses) {
          final verseNumber = v['verse_number'] as int;
          final arabicNum = _toArabicNumeral(verseNumber);
          
          textSpans.add(TextSpan(
            children: [
              TextSpan(
                text: '${v['text_ar']} ', 
                style: TextStyle(backgroundColor: widget.highlightedVerse == verseNumber ? const Color(0xFFF1E5C9) : null)
              ),
              TextSpan(
                text: '﴿$arabicNum﴾ ', 
                style: TextStyle(
                  color: frameColor, 
                  fontSize: 22, 
                  backgroundColor: widget.highlightedVerse == verseNumber ? const Color(0xFFF1E5C9) : null
                ), 
              ),
            ],
          ));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
            child: RichText(
              textDirection: TextDirection.rtl, 
              textAlign: TextAlign.justify, 
              text: TextSpan(
                style: TextStyle(fontFamily: 'UthmanicHafs', fontSize: 28, height: 2.6, color: textColor), 
                children: textSpans
              ),
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
