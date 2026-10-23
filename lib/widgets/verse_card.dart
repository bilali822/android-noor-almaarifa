import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';

class VerseCard extends StatefulWidget {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String text;
  final VoidCallback onTafsir;

  const VerseCard({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.text,
    required this.onTafsir,
  });

  @override State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  bool _isSaved = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    setState(() => _isSaved = saved.contains('${widget.surahName}:${widget.verseNumber}'));
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    final key = '${widget.surahName}:${widget.verseNumber}';
    setState(() { if (_isSaved) { saved.remove(key); _isSaved = false; } else { saved.add(key); _isSaved = true; } });
    await prefs.setStringList('bookmarks', saved);
  }

  // 🎧 دالة تشغيل الصوت
  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => _isLoadingAudio = true);
      try {
        // رابط صوت الشيخ مشاري العفاسي (كل آية ليها ملف)
        final surahStr = widget.surahId.toString().padLeft(3, '0');
        final verseStr = widget.verseNumber.toString().padLeft(3, '0');
        final url = 'https://everyayah.com/data/Alafasy_128kbps/$surahStr$verseStr.mp3';
        
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تشغيل الصوت. تأكد من اتصالك بالإنترنت.')));
      } finally {
        if (mounted) setState(() => _isLoadingAudio = false);
      }
    }
  }

  // 🖼️ دالة مشاركة الآية كصورة
  Future<void> _shareAsImage() async {
    try {
      final image = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '﴿ ${widget.text} ﴾',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    height: 2.2,
                    fontFamily: 'UthmanicHafs',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'سورة ${widget.surahName} - الآية ${widget.verseNumber}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text('تطبيق نور المعرفة', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ),
        delay: const Duration(milliseconds: 10),
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/ayah_share.png').create();
      await file.writeAsBytes(image);

      await Share.shareXFiles([XFile(file.path)], text: 'آية من القرآن الكريم');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر مشاركة الصورة.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(Icons.menu_book, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('سورة ${widget.surahName} • الآية ${widget.verseNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
            // 🌟 زر الصوت
            IconButton(
              onPressed: _toggleAudio,
              icon: _isLoadingAudio 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.primary, size: 28),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text('﴿ ${widget.text} ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 26, height: 2.2, fontFamily: 'UthmanicHafs')),
        ),
        const Divider(color: AppColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // زر التفسير
            IconButton(onPressed: widget.onTafsir, icon: const Icon(Icons.menu_book, color: AppColors.primary), tooltip: 'تفسير'),
            // زر النسخ
            IconButton(onPressed: () { Clipboard.setData(ClipboardData(text: '${widget.text}\n[سورة ${widget.surahName} - آية ${widget.verseNumber}]')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); }, icon: const Icon(Icons.copy, color: AppColors.primary), tooltip: 'نسخ'),
            // 🌟 زر مشاركة الصورة
            IconButton(onPressed: _shareAsImage, icon: const Icon(Icons.share, color: AppColors.primary), tooltip: 'مشاركة كصورة'),
            // زر الحفظ
            IconButton(onPressed: _toggleSave, icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary), tooltip: 'حفظ'),
          ]),
        )
      ]),
    );
  }
}
