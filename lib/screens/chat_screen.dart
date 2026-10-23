import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/query_parser.dart';
import '../widgets/message_bubble.dart';
import '../widgets/welcome_view.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/verse_card.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final Map<String, dynamic>? verseData;

  ChatMessage({required this.text, required this.isUser, this.verseData}) : time = DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.hour >= 12 ? 'م' : 'ص';
    return '$h:$m $p';
  }

  Future<void> _handleSubmit([String? forced]) async {
    final text = (forced ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _typing = true;
    });
    _scrollBottom();

    try {
      await _processQuery(text);
    } catch (e) {
      setState(() => _messages.add(ChatMessage(text: 'حدث خطأ في النظام المحلي.', isUser: false)));
    } finally {
      if (mounted) setState(() => _typing = false);
      _scrollBottom();
    }
  }

  Future<void> _processQuery(String text) async {
    final p = QueryParser.parse(text);
    final type = p['type'] as String;

    if (type == 'verse' && p['surahId'] != null && p['verseNumber'] != null) {
      final sid = p['surahId'] as int;
      final vn = p['verseNumber'] as int;

      final verse = await DatabaseHelper.instance.getVerse(sid, vn);
      if (verse.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'لم يتم العثور على الآية $vn', isUser: false)));
        return;
      }
      final v = verse.first;
      final surahName = v['surah_name'] as String? ?? '';

      setState(() {
        _messages.add(ChatMessage(
          text: '',
          isUser: false,
          verseData: {
            'surahId': sid,
            'surahName': surahName,
            'verseNumber': vn,
            'verseText': v['text_ar'],
          },
        ));
      });
      _scrollBottom();
      return;
    }

    if (type == 'surah' && p['surahId'] != null) {
      final sid = p['surahId'] as int;
      final verses = await DatabaseHelper.instance.getVerses(sid);
      if (verses.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'السورة غير موجودة', isUser: false)));
        return;
      }
      final surahName = verses.first['surah_name'] as String? ?? '';
      final preview = verses.take(3).map((v) => '﴿ ${v['text_ar']} ﴾').join('\n\n');

      setState(() => _messages.add(ChatMessage(
            text: 'تم العثور على سورة $surahName (${verses.length} آية).\n\n$preview\n\n... (يفضل البحث عن آية محددة لتجربة أفضل)',
            isUser: false,
          )));
      _scrollBottom();
      return;
    }

    if (type == 'search') {
      final term = p['term'] as String?;
      if (term == null || term.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'يرجى كتابة اسم سورة أو كلمة للبحث', isUser: false)));
        return;
      }
      final results = await DatabaseHelper.instance.searchVerses(term, limit: 3);
      if (results.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'لا توجد نتائج لـ "$term"', isUser: false)));
        return;
      }
      final body = results.map((v) => 'سورة ${v['surah_name']} (${v['verse_number']}):\n﴿ ${v['text_ar']} ﴾').join('\n\n');
      setState(() => _messages.add(ChatMessage(text: 'نتائج البحث:\n\n$body', isUser: false)));
      _scrollBottom();
      return;
    }
  }

  void _openTafsir(Map<String, dynamic> data) async {
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(
        surahName: data['surahName'] as String,
        surahId: data['surahId'] as int,
        verseNumber: data['verseNumber'] as int,
        verseText: data['verseText'] as String,
        books: books,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('المحادثة الذكية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? WelcomeView(onExample: (text) => _handleSubmit(text))
                : ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    itemBuilder: (context, i) {
                      if (i == _messages.length && _typing) {
                        return const TypingIndicator();
                      }
                      final m = _messages[i];
                      
                      if (m.verseData != null) {
                        return VerseCard(
                          surahName: m.verseData!['surahName'] as String,
                          verseNumber: m.verseData!['verseNumber'] as int,
                          text: m.verseData!['verseText'] as String,
                          onTafsir: () => _openTafsir(m.verseData!),
                        );
                      }
                      
                      return MessageBubble(
                        text: m.text,
                        isUser: m.isUser,
                        time: _formatTime(m.time),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSubmit(),
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          hintText: 'اسأل عن آية أو سورة...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: AppColors.bgDeep, size: 22),
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
