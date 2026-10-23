import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_colors.dart';
import '../utils/query_parser.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/verse_card.dart';

class ChatMessage {
  final String text; final bool isUser; final Map<String, dynamic>? verseData;
  ChatMessage({required this.text, required this.isUser, this.verseData});
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

  void _scrollBottom() => WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); });

  Future<void> _handleSubmit() async {
    final text = _inputCtrl.text.trim(); if (text.isEmpty) return;
    _inputCtrl.clear(); setState(() { _messages.add(ChatMessage(text: text, isUser: true)); _typing = true; }); _scrollBottom();
    try {
      final p = QueryParser.parse(text);
      if (p['type'] == 'verse' || p['type'] == 'search') {
        final sid = p['surahId'] ?? 18; final vn = p['verseNumber'] ?? 9;
        final verse = await DatabaseHelper.instance.getVerse(sid, vn);
        if (verse.isNotEmpty) {
          final v = verse.first;
          setState(() => _messages.add(ChatMessage(text: '', isUser: false, verseData: {'surahId': sid, 'surahName': v['surah_name'], 'verseNumber': vn, 'verseText': v['text_ar']})));
        } else {
          setState(() => _messages.add(ChatMessage(text: 'لم يتم العثور على الآية.', isUser: false)));
        }
      } else {
        setState(() => _messages.add(ChatMessage(text: 'جرب تسأل عن آية أو سورة.', isUser: false)));
      }
    } finally { if (mounted) setState(() => _typing = false); _scrollBottom(); }
  }

  void _openTafsir(Map<String, dynamic> data) async {
    final books = await DatabaseHelper.instance.getTafsirBooks(); if (!mounted) return;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => TafsirSheet(surahName: data['surahName'], surahId: data['surahId'], verseNumber: data['verseNumber'], verseText: data['verseText'], books: books));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Column(children: [Text('مساعد القرآن', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)), Text('مساعدك لتفسير القرآن الكريم', style: TextStyle(color: AppColors.textMuted, fontSize: 12))]),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(children: [
            Expanded(child: ListView.builder(
              controller: _scrollCtrl, itemCount: _messages.length + (_typing ? 1 : 0), padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, i) {
                if (i == _messages.length && _typing) return const TypingIndicator();
                final m = _messages[i];
                if (m.verseData != null) return VerseCard(surahId: m.verseData!['surahId'] as int, surahName: m.verseData!['surahName'] as String, verseNumber: m.verseData!['verseNumber'] as int, text: m.verseData!['verseText'] as String, onTafsir: () => _openTafsir(m.verseData!));
                return MessageBubble(text: m.text, isUser: m.isUser);
              }
            )),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _inputCtrl, textInputAction: TextInputAction.send, onSubmitted: (_) => _handleSubmit(), decoration: const InputDecoration(hintText: 'اسأل عن آية أو سورة...', hintTextDirection: TextDirection.rtl, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
                    Container(decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _handleSubmit)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
