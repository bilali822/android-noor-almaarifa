import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/query_parser.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/verse_card.dart';
import '../widgets/surah_card.dart';
import '../widgets/quranic_background.dart';
import '../widgets/tafsir_sheet.dart';

class ChatMessage {
  final String text; 
  final bool isUser; 
  final String time; 
  final Map<String, dynamic>? verseData; 
  final String? tafsirText;
  final String? surahName;
  final String? fullSurahText; // 🌟 حقل جديد للسورة الكاملة
  
  ChatMessage({required this.text, required this.isUser, required this.time, this.verseData, this.tafsirText, this.surahName, this.fullSurahText});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = []; 
  final _inputCtrl = TextEditingController(); 
  final _scrollCtrl = ScrollController(); 
  bool _typing = false;

  // 🌟 مفتاح لتحديد مكان الرسالة الأخيرة للتمرير إليها
  final GlobalKey _lastMessageKey = GlobalKey();

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // 🌟 دالة التمرير لبداية الرسالة الجديدة (وليس لآخر الشاشة)
  void _scrollToMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastMessageKey.currentContext != null) {
        Scrollable.ensureVisible(
          _lastMessageKey.currentContext!,
          alignment: 0.0, // 0.0 تعني رأس الرسالة (فوق)
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openTafsir(Map<String, dynamic> data) async {
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (_) => TafsirSheet(
        surahName: data['surahName'], 
        surahId: data['surahId'], 
        verseNumber: data['verseNumber'], 
        verseText: data['verseText'], 
        books: books,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _inputCtrl.text.trim(); 
    if (text.isEmpty) return;
    final currentTime = _formatTime();
    _inputCtrl.clear(); 
    
    setState(() { 
      _messages.add(ChatMessage(text: text, isUser: true, time: currentTime)); 
      _typing = true; 
    }); 
    _scrollToMessage();
    
    try {
      final p = QueryParser.parse(text);
      
      // 1. البحث عن آية محددة
      if (p['type'] == 'verse' && p['surahId'] != null && p['verseNumber'] != null) {
        final sid = p['surahId'] as int; 
        final vn = p['verseNumber'] as int;
        final verse = await DatabaseHelper.instance.getVerse(sid, vn);
        
        if (verse.isNotEmpty) {
          final v = verse.first;
          final surahName = v['surah_name'] ?? 'غير معروف';
          final tafsirs = await DatabaseHelper.instance.getTafsirs(sid, vn);
          final defaultTafsir = tafsirs.isNotEmpty ? tafsirs.first['text_ar'] as String : 'التفسير غير متوفر.';
          
          setState(() => _messages.add(ChatMessage(
            text: '', isUser: false, time: currentTime,
            verseData: {'surahId': sid, 'surahName': surahName, 'verseNumber': vn, 'verseText': v['text_ar']},
            tafsirText: defaultTafsir,
          )));
        } else {
          setState(() => _messages.add(ChatMessage(text: 'لم يتم العثور على الآية.', isUser: false, time: currentTime)));
        }
      }
      
      // 2. البحث عن سورة كاملة
      else if (p['type'] == 'surah' && p['surahId'] != null) {
        final sid = p['surahId'] as int;
        final verses = await DatabaseHelper.instance.getVerses(sid);
        
        if (verses.isNotEmpty) {
          final surahName = verses.first['surah_name'] as String? ?? 'غير معروف';
          
          // تجميع السورة كلها في نص واحد
          String fullText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n';
          for (var v in verses) {
            fullText += '${v['text_ar']} ﴿${v['verse_number']}﴾\n\n';
          }
          
          setState(() => _messages.add(ChatMessage(
            text: '', isUser: false, time: currentTime,
            surahName: surahName,
            fullSurahText: fullText,
          )));
        } else {
          setState(() => _messages.add(ChatMessage(text: 'السورة غير موجودة.', isUser: false, time: currentTime)));
        }
      } 
      
      // 3. بحث بالكلمات
      else if (p['type'] == 'search') {
        final term = p['term'] as String?;
        if (term != null && term.isNotEmpty) {
          final results = await DatabaseHelper.instance.searchVerses(term, limit: 3);
          if (results.isNotEmpty) {
            final v = results.first;
            setState(() => _messages.add(ChatMessage(
              text: '', isUser: false, time: currentTime,
              verseData: {'surahId': v['surah_id'], 'surahName': v['surah_name'], 'verseNumber': v['verse_number'], 'verseText': v['text_ar']},
              tafsirText: 'تم العثور على هذه الآية بناءً على بحثك.',
            )));
          } else {
            setState(() => _messages.add(ChatMessage(text: 'لا توجد نتائج.', isUser: false, time: currentTime)));
          }
        }
      } else {
        setState(() => _messages.add(ChatMessage(text: 'جرب تسأل عن آية أو سورة.', isUser: false, time: currentTime)));
      }
    } catch (e) {
      setState(() => _messages.add(ChatMessage(text: 'حدث خطأ: $e', isUser: false, time: currentTime)));
    } finally { 
      if (mounted) setState(() => _typing = false); 
      _scrollToMessage(); // ننزل لبداية الرد الجديد
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: QuranicBackground(
        child: SafeArea(
          child: Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
                  const Column(children: [Text('مساعد القرآن', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)), Text('مساعدك لتفسير القرآن الكريم', style: TextStyle(color: AppColors.textMuted, fontSize: 12))]),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(child: _messages.isEmpty 
              ? const Center(child: Text('اسأل عن أي آية أو سورة للبدء...', style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                controller: _scrollCtrl, itemCount: _messages.length + (_typing ? 1 : 0), padding: const EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, i) {
                  if (i == _messages.length && _typing) return const TypingIndicator();
                  
                  final m = _messages[i];
                  final isLast = i == _messages.length - 1; // 🌟 هل دي آخر رسالة؟
                  
                  Widget messageWidget;
                  if (m.fullSurahText != null) {
                    messageWidget = SurahCard(surahName: m.surahName!, fullText: m.fullSurahText!);
                  } else if (m.verseData != null) {
                    messageWidget = VerseCard(
                      surahId: m.verseData!['surahId'] as int, 
                      surahName: m.verseData!['surahName'] as String, 
                      verseNumber: m.verseData!['verseNumber'] as int, 
                      text: m.verseData!['verseText'] as String, 
                      tafsirText: m.tafsirText ?? '',
                      onTafsir: () => _openTafsir(m.verseData!), 
                    );
                  } else {
                    messageWidget = MessageBubble(text: m.text, isUser: m.isUser);
                  }

                  return Container(
                    key: isLast ? _lastMessageKey : null, // 🌟 وضع المفتاح على آخر رسالة
                    child: Column(
                      crossAxisAlignment: m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        messageWidget,
                        Padding(
                          padding: EdgeInsets.only(right: m.isUser ? 24 : 60, left: m.isUser ? 60 : 24, bottom: 16),
                          child: Text(m.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Row(children: [
                  Expanded(child: TextField(controller: _inputCtrl, textInputAction: TextInputAction.send, onSubmitted: (_) => _handleSubmit(), decoration: const InputDecoration(hintText: 'اسأل عن آية أو سورة...', hintTextDirection: TextDirection.rtl, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
                  Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 22), onPressed: _handleSubmit)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
