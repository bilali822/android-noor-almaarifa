import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/query_parser.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/verse_card.dart';
import '../widgets/surah_card.dart';
import '../widgets/tafsir_card.dart';
import '../widgets/quranic_background.dart';
import '../widgets/tafsir_sheet.dart';
import '../models/chat_history.dart';
import '../services/chat_history_service.dart';
import 'chat_history_screen.dart';
import '../widgets/support_card.dart';

class ChatMessage {
  final String text; 
  final bool isUser; 
  final String time; 
  final Map<String, dynamic>? verseData; 
  final String? surahName; 
  final String? fullSurahText;
  final List<Map<String, dynamic>>? tafsirData; 
  
  ChatMessage({
    required this.text, required this.isUser, required this.time, 
    this.verseData, this.surahName, this.fullSurahText, this.tafsirData
  });
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
  final GlobalKey _lastMessageKey = GlobalKey();

  String _currentConvId = DateTime.now().millisecondsSinceEpoch.toString();

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveConversation() async {
    if (_messages.isEmpty) return;
    final savedMsgs = _messages.map((m) => SavedMessage(
      text: m.text, isUser: m.isUser, 
      verseData: m.verseData, 
      tafsirData: m.tafsirData, 
      time: m.time
    )).toList();
    final title = _messages.first.text;
    final conv = SavedConversation(id: _currentConvId, title: title, type: 'quran', date: DateTime.now().toIso8601String(), messages: savedMsgs);
    await ChatHistoryService.save(conv);
  }

  void _loadConversation(SavedConversation conv) {
    setState(() {
      _currentConvId = conv.id;
      _messages.clear();
      for (var m in conv.messages) {
        _messages.add(ChatMessage(
          text: m.text, isUser: m.isUser, time: m.time, 
          verseData: m.verseData, tafsirData: m.tafsirData
        ));
      }
    });
    _scrollToBottom();
  }

  void _newChat() {
    setState(() {
      _messages.clear();
      _currentConvId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _openTafsir(Map<String, dynamic> data) async {
    // 🌟 نجيب بس الكتب اللي عندها تفسير للآية دي
    final books = await DatabaseHelper.instance.getTafsirBooksForVerse(
      data['surahId'] as int,
      data['verseNumber'] as int,
    );
    if (!mounted) return;

    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تفسير متاح لهذه الآية')),
      );
      return;
    }

    final selectedBooks = await showModalBottomSheet<List<String>>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent, 
      builder: (_) => TafsirSheet(surahName: data['surahName'], surahId: data['surahId'], verseNumber: data['verseNumber'], verseText: data['verseText'], books: books),
    );

    if (selectedBooks != null && selectedBooks.isNotEmpty && mounted) {
      setState(() => _typing = true);
      try {
        final tafsirs = await DatabaseHelper.instance.getTafsirs(data['surahId'] as int, data['verseNumber'] as int);
        final List<Map<String, dynamic>> tafsirList = [];

        for (var key in selectedBooks) {
          final book = books.firstWhere((b) => b['key'] == key, orElse: () => {'name_ar': key});
          final text = tafsirs.firstWhere((t) => t['book_key'] == key, orElse: () => {'text_ar': 'التفسير غير متوفر.'})['text_ar'] as String;
          tafsirList.add({'book_name': book['name_ar'] as String, 'text': text});
        }

        setState(() => _messages.add(ChatMessage(text: '', isUser: false, time: _formatTime(), tafsirData: tafsirList)));
      } catch (e) {
        setState(() => _messages.add(ChatMessage(text: 'حدث خطأ في جلب التفسير.', isUser: false, time: _formatTime())));
      } finally {
        if (mounted) setState(() => _typing = false);
        _scrollToBottom();
        await _saveConversation();
      }
    }
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
    _scrollToBottom();
    
    try {
      final p = QueryParser.parse(text);
      if (p['type'] == 'verse' && p['surahId'] != null && p['verseNumber'] != null) {
        final sid = p['surahId'] as int; final vn = p['verseNumber'] as int;
        final verse = await DatabaseHelper.instance.getVerse(sid, vn);
        
        if (verse.isNotEmpty) {
          final v = verse.first;
          final surahName = v['surah_name'] as String? ?? 'غير معروف';
          setState(() => _messages.add(ChatMessage(
            text: '', isUser: false, time: currentTime,
            verseData: {'surahId': sid, 'surahName': surahName, 'verseNumber': vn, 'verseText': v['text_ar']},
          )));
        } else {
          setState(() => _messages.add(ChatMessage(text: 'لم يتم العثور على الآية.', isUser: false, time: currentTime)));
        }
      } else if (p['type'] == 'surah' && p['surahId'] != null) {
        final sid = p['surahId'] as int;
        final verses = await DatabaseHelper.instance.getVerses(sid);
        if (verses.isNotEmpty) {
          final surahName = verses.first['surah_name'] as String? ?? 'غير معروف';
          String fullText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n';
          for (var v in verses) { fullText += '${v['text_ar']} ﴿${v['verse_number']}﴾\n\n'; }
          setState(() => _messages.add(ChatMessage(text: '', isUser: false, time: currentTime, surahName: surahName, fullSurahText: fullText)));
        } else {
          setState(() => _messages.add(ChatMessage(text: 'السورة غير موجودة في نسخة الويب.', isUser: false, time: currentTime)));
        }
      } else {
        setState(() => _messages.add(ChatMessage(text: 'جرب تسأل عن آية أو سورة.', isUser: false, time: currentTime)));
      }
    } catch (e) {
      setState(() => _messages.add(ChatMessage(text: 'حدث خطأ في الاتصال. يرجى التواصل مع الدعم الفني.', isUser: false, time: currentTime)));
      _showSupportDialog();
    } finally { 
      if (mounted) setState(() => _typing = false); 
      _scrollToBottom();
      await _saveConversation();
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: SupportCard(),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: const Text('مساعد القرآن', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            onPressed: () async {
              final selected = await Navigator.push<SavedConversation>(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen(type: 'quran')));
              if (selected != null) _loadConversation(selected);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment, color: AppColors.primary),
            onPressed: _newChat,
          ),
        ],
      ),
      body: QuranicBackground(
        child: SafeArea(
          child: Column(children: [
            Expanded(child: _messages.isEmpty 
              ? const Center(child: Text('اسأل عن "سورة الفاتحة" أو "آية الكرسي"...', style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                controller: _scrollCtrl, itemCount: _messages.length + (_typing ? 1 : 0), padding: const EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, i) {
                  if (i == _messages.length && _typing) return const TypingIndicator();
                  final m = _messages[i];
                  final isLast = i == _messages.length - 1;
                  
                  Widget messageWidget;
                  if (m.tafsirData != null) {
                    messageWidget = Column(children: m.tafsirData!.map((t) => TafsirCard(bookName: t['book_name'], tafsirText: t['text'])).toList());
                  } else if (m.fullSurahText != null) {
                    messageWidget = SurahCard(surahName: m.surahName!, fullText: m.fullSurahText!);
                  } else if (m.verseData != null) {
                    messageWidget = VerseCard(
                      surahId: m.verseData!['surahId'] as int, surahName: m.verseData!['surahName'] as String, verseNumber: m.verseData!['verseNumber'] as int, text: m.verseData!['verseText'] as String, tafsirText: '',
                      onTafsir: () => _openTafsir(m.verseData!), 
                    );
                  } else {
                    messageWidget = MessageBubble(text: m.text, isUser: m.isUser);
                  }

                  return Container(
                    key: isLast ? _lastMessageKey : null,
                    child: Column(crossAxisAlignment: m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                      messageWidget,
                      Padding(padding: EdgeInsets.only(right: m.isUser ? 24 : 60, left: m.isUser ? 60 : 24, bottom: 16), child: Text(m.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    ]),
                  );
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
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
