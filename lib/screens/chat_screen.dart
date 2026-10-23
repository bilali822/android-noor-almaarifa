import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/query_parser.dart';
import '../widgets/message_bubble.dart';
import '../widgets/welcome_view.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/tafsir_sheet.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser}) : time = DateTime.now();
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
      setState(() => _messages.add(ChatMessage(text: 'حدث خطأ: $e', isUser: false)));
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

      setState(() => _messages.add(ChatMessage(
            text: 'سورة $surahName — الآية $vn\n\n﴿ ${v['text_ar']} ﴾',
            isUser: false,
          )));
      _scrollBottom();

      await _openTafsirSheet(
        surahId: sid,
        surahName: surahName,
        verseNumber: vn,
        verseText: v['text_ar'] as String? ?? '',
      );
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
      final preview = verses.take(10).map((v) => '${v['verse_number']}. ﴿ ${v['text_ar']} ﴾').join('\n\n');

      setState(() => _messages.add(ChatMessage(
            text: 'سورة $surahName (${verses.length} آية)\n\n$preview\n\n...',
            isUser: false,
          )));
      _scrollBottom();

      await _openTafsirSheet(
        surahId: sid,
        surahName: surahName,
        verseNumber: verses.first['verse_number'] as int,
        verseText: verses.first['text_ar'] as String? ?? '',
      );
      return;
    }

    if (type == 'search') {
      final term = p['term'] as String?;
      if (term == null || term.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'يرجى كتابة اسم سورة أو كلمة للبحث', isUser: false)));
        return;
      }
      final results = await DatabaseHelper.instance.searchVerses(term, limit: 5);
      if (results.isEmpty) {
        setState(() => _messages.add(ChatMessage(text: 'لا توجد نتائج لـ "$term"', isUser: false)));
        return;
      }
      final body = results.map((v) => '${v['surah_id']}:${v['verse_number']} ﴿ ${v['text_ar']} ﴾').join('\n\n');
      setState(() => _messages.add(ChatMessage(text: 'نتائج البحث:\n\n$body', isUser: false)));
      _scrollBottom();
      return;
    }
  }

  Future<void> _openTafsirSheet({
    required int surahId,
    required String surahName,
    required int verseNumber,
    required String verseText,
  }) async {
    final books = await DatabaseHelper.instance.getTafsirBooks();
    if (!mounted) return;

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(
        surahName: surahName,
        surahId: surahId,
        verseNumber: verseNumber,
        verseText: verseText,
        books: books,
      ),
    );

    if (selected != null && selected.isNotEmpty && mounted) {
      setState(() => _messages.add(ChatMessage(
            text: 'تم اختيار ${selected.length} تفسير. (ميزة العرض قيد التطوير)',
            isUser: false,
          )));
      _scrollBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('نور المعرفة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? WelcomeView(onExample: _handleSubmit)
                : ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (context, i) {
                      if (i == _messages.length && _typing) {
                        return const TypingIndicator();
                      }
                      final m = _messages[i];
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.bgDeep,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(),
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم سورة أو آية...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.bgDeep, size: 20),
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
