import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_history.dart';
import '../services/chat_history_service.dart';
import 'chat_history_screen.dart';

const Color bgColor = Color(0xFF0B101E);
const Color aiBubbleColor = Color(0xFF1E293B);
const Color primaryGreen = Color(0xFF155E35);
const Color goldAccent = Color(0xFFD4AF37);

class AIMessage {
  final String text;
  final bool isUser;
  AIMessage({required this.text, required this.isUser});
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<AIMessage> _messages = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isWaiting = false;

  final String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  ChatSession? _chatSession;

  String _currentConvId = DateTime.now().millisecondsSinceEpoch.toString();
  String _convTitle = 'محادثة جديدة';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initSession();
  }

  void _initSession() {
    if (_apiKey.isNotEmpty) {
      try {
        // 🌟 استخدام الموديل المطلوب من جوجل
        final model = GenerativeModel(
          model: 'gemini-flash-lite-latest',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(maxOutputTokens: 2000),
          systemInstruction: Content.system('أنت "مساعد نور المعرفة". أجب على سؤال المستخدم بإيجاز شديد ومباشر. لا تكتب مقدمات ولا خواتيم طويلة. اجعل الرد في نقاط أو فقرة قصيرة جداً.'),
        );
        _chatSession = model.startChat();
      } catch (e) {
        debugPrint("AI Init Error: $e");
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _saveCurrentConversation() async {
    if (_messages.isEmpty) return;
    if (_convTitle == 'محادثة جديدة') _convTitle = _messages.first.text;
    final savedMsgs = _messages.map((m) => SavedMessage(text: m.text, isUser: m.isUser, time: DateTime.now().toString())).toList();
    final conv = SavedConversation(id: _currentConvId, title: _convTitle, type: 'ai', date: DateTime.now().toIso8601String(), messages: savedMsgs);
    await ChatHistoryService.save(conv);
  }

  Future<void> _loadConversation(SavedConversation conv) async {
    setState(() {
      _currentConvId = conv.id; _convTitle = conv.title; _messages.clear();
      for (var m in conv.messages) { _messages.add(AIMessage(text: m.text, isUser: m.isUser)); }
      _isWaiting = false;
    });
    _initSession(); _scrollToBottom();
  }

  void _newChat() {
    setState(() { _messages.clear(); _currentConvId = DateTime.now().millisecondsSinceEpoch.toString(); _convTitle = 'محادثة جديدة'; });
    _initSession();
  }

  Future<void> _handleSubmit() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    if (_apiKey.isEmpty) {
      setState(() {
        _messages.add(AIMessage(text: text, isUser: true));
        _messages.add(AIMessage(text: '❌ خطأ: مفتاح API (GEMINI_API_KEY) غير موجود في إعدادات التطبيق.', isUser: false));
      });
      _inputCtrl.clear();
      _scrollToBottom();
      return;
    }
    
    if (_chatSession == null) _initSession();
    if (_chatSession == null) {
      setState(() {
        _messages.add(AIMessage(text: text, isUser: true));
        _messages.add(AIMessage(text: '❌ خطأ: تعذر تهيئة الجلسة مع الذكاء الاصطناعي.', isUser: false));
      });
      _inputCtrl.clear();
      _scrollToBottom();
      return;
    }

    _inputCtrl.clear();
    setState(() { _messages.add(AIMessage(text: text, isUser: true)); _isWaiting = true; });
    _scrollToBottom();

    try {
      // 🌟 زيادة وقت الانتظار إلى 60 ثانية
      final responseStream = _chatSession!.sendMessageStream(Content.text(text)).timeout(const Duration(seconds: 60));
      bool isFirstChunk = true;
      String fullText = '';

      await for (final response in responseStream) {
        fullText += response.text ?? '';
        String cleanText = fullText.replaceAll('**', '').replaceAll('*', '•');
        setState(() {
          if (isFirstChunk) { _isWaiting = false; _messages.add(AIMessage(text: cleanText, isUser: false)); isFirstChunk = false; }
          else { _messages[_messages.length - 1] = AIMessage(text: cleanText, isUser: false); }
        });
        _scrollToBottom();
      }
      await _saveCurrentConversation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWaiting = false;
          _messages.add(AIMessage(text: '❌ عذراً، حدث خطأ في الاتصال:\n$e', isUser: false));
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: goldAccent), SizedBox(width: 8), Text('مساعد نور الذكي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), SizedBox(width: 40)]),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: () async {
              final selected = await Navigator.push<SavedConversation>(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen(type: 'ai')));
              if (selected != null) _loadConversation(selected);
            },
          ),
          IconButton(icon: const Icon(Icons.add_comment, color: Colors.white), onPressed: _newChat),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isWaiting
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollCtrl, padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60, left: 16, right: 16, bottom: 20),
                    itemCount: _messages.length + (_isWaiting ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length && _isWaiting) return const _BouncingDots();
                      return _buildMessageBubble(_messages[i]);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: goldAccent.withOpacity(0.5))), child: const Icon(Icons.auto_awesome, size: 60, color: goldAccent)),
          const SizedBox(height: 24),
          const Text('أهلاً بك في مساعد نور الذكي', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('أنا هنا لمساعدتك في فهم القرآن، السنة، والفتاوى.', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 32),
          Wrap(spacing: 12, children: [_buildSuggestionCard(Icons.menu_book, 'اشرح لي الصبر'), _buildSuggestionCard(Icons.lightbulb_outline, 'أركان الإسلام')])
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(IconData icon, String text) {
    return InkWell(
      onTap: () { _inputCtrl.text = text; _handleSubmit(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: aiBubbleColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: primaryGreen, size: 18), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))]),
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage m) {
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: m.isUser ? const LinearGradient(colors: [primaryGreen, Color(0xFF0E3A21)]) : null,
          color: m.isUser ? null : aiBubbleColor,
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(m.isUser ? 20 : 4), bottomRight: Radius.circular(m.isUser ? 4 : 20)),
          border: m.isUser ? null : Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: SelectableText(m.text, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7)),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: aiBubbleColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl, textInputAction: TextInputAction.send, onSubmitted: (_) => _handleSubmit(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'اسأل الذكاء الاصطناعي...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _isWaiting ? null : _handleSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();
  @override State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: aiBubbleColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryGreen.withOpacity(0.3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final double value = (_ctrl.value + (i * 0.2)) % 1.0;
                final double dy = value < 0.5 ? -6 * (value * 2) : -6 * (2 - value * 2);
                return Transform.translate(offset: Offset(0, dy), child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8, decoration: const BoxDecoration(color: goldAccent, shape: BoxShape.circle)));
              },
            );
          }),
        ),
      ),
    );
  }
}
