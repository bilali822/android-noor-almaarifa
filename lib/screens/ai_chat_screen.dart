import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _cancelRequested = false;

  final ScreenshotController _screenshotController = ScreenshotController();

  final String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  ChatSession? _chatSession;

  final List<String> _models = [
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
  ];

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
        final model = GenerativeModel(
          model: _models.first,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(maxOutputTokens: 2000),
          systemInstruction: Content.system(
            'أنت "مساعد نور المعرفة"، مساعد ذكي إسلامي. '
            'قواعدك: 1. أجب عن الأسئلة الإسلامية بدقة. '
            '2. لا تفتِ في المسائل الخلافية المعقدة. '
            '3. ابدأ إجاباتك بالبسملة إذا كان السؤال دينياً. '
            '4. استخدم النقاط (Bullet points) والخطوط العريضة (**نص**) لتنسيق إجابتك. '
            '5. في نهاية إجابتك، ضع 3 أسئلة مقترحة تبدأ بـ ||| وتفصل بينها بـ |. مثال: |||ما هي فوائد الصبر؟|كيف أصبر على البلاء؟|أحاديث عن الصبر'
          ),
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

  void _loadConversation(SavedConversation conv) async {
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
        _messages.add(AIMessage(text: '❌ مفتاح API غير موجود.', isUser: false));
      });
      _inputCtrl.clear();
      _scrollToBottom();
      return;
    }
    
    if (_chatSession == null) _initSession();
    if (_chatSession == null) {
      setState(() {
        _messages.add(AIMessage(text: text, isUser: true));
        _messages.add(AIMessage(text: '❌ تعذر الاتصال بالذكاء الاصطناعي.', isUser: false));
      });
      _inputCtrl.clear();
      _scrollToBottom();
      return;
    }

    _inputCtrl.clear();
    setState(() { _messages.add(AIMessage(text: text, isUser: true)); _isWaiting = true; _cancelRequested = false; });
    _scrollToBottom();

    try {
      final responseStream = _chatSession!.sendMessageStream(Content.text(text)).timeout(const Duration(seconds: 60));
      bool isFirstChunk = true;
      String fullText = '';
      List<String> suggestions = [];

      await for (final response in responseStream) {
        if (_cancelRequested) break; // إيقاف التوليد

        fullText += response.text ?? '';
        
        // استخراج الاقتراحات (إذا وجدت)
        if (fullText.contains('|||')) {
          final parts = fullText.split('|||');
          fullText = parts[0];
          if (parts.length > 1) {
            suggestions = parts[1].split('|').where((s) => s.trim().isNotEmpty).toList();
          }
        }

        setState(() {
          if (isFirstChunk) { _isWaiting = false; _messages.add(AIMessage(text: fullText, isUser: false)); isFirstChunk = false; }
          else { _messages[_messages.length - 1] = AIMessage(text: fullText, isUser: false); }
        });
        _scrollToBottom();
      }

      if (suggestions.isNotEmpty && !_cancelRequested) {
        setState(() {
          _messages.add(AIMessage(text: '|||${suggestions.join('|')}', isUser: false));
        });
      }

      await _saveCurrentConversation();
    } catch (e) {
      // معالجة أخطاء 503 و 404
      if (e.toString().contains('503') || e.toString().contains('404') || e.toString().contains('high demand') || e.toString().contains('not found')) {
        if (mounted) {
          setState(() { _isWaiting = true; _messages.add(AIMessage(text: '⏳ الخادم مشغول، جاري المحاولة بموديل آخر...', isUser: false)); });
          _scrollToBottom();
        }
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() { _messages.removeLast(); _isWaiting = false; });
          if (_models.length > 1) { _models.removeAt(0); _initSession(); }
          _handleSubmit();
        }
        return;
      }
      if (mounted) {
        setState(() { _isWaiting = false; _messages.add(AIMessage(text: '❌ عذراً، حدث خطأ:\n$e', isUser: false)); });
        _scrollToBottom();
      }
    }
  }

  // 🌟 مشاركة إجابة الذكاء الاصطناعي كصورة فخمة
  Future<void> _shareAIMessage(String text) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 400,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: goldAccent, width: 2),
              boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.2), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: goldAccent, size: 40),
                const SizedBox(height: 16),
                Text(text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.8)),
                const SizedBox(height: 24),
                const Text('مساعد نور المعرفة', style: TextStyle(color: goldAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        delay: const Duration(milliseconds: 10),
      );
      final xFile = XFile.fromData(image, mimeType: 'image/png', name: 'ai_answer.png');
      await Share.shareXFiles([xFile], text: 'إجابة من مساعد نور المعرفة');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر مشاركة الصورة.')));
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
    // 🌟 التحقق إذا كانت الرسالة تحتوي على اقتراحات (تبدأ بـ |||)
    if (!m.isUser && m.text.startsWith('|||')) {
      final suggestions = m.text.replaceFirst('|||', '').split('|');
      return Wrap(
        spacing: 8, runSpacing: 8,
        children: suggestions.map((s) => ActionChip(
          label: Text(s, style: const TextStyle(color: goldAccent, fontSize: 12)),
          backgroundColor: aiBubbleColor,
          side: const BorderSide(color: goldAccent),
          onPressed: () { _inputCtrl.text = s; _handleSubmit(); },
        )).toList(),
      );
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 دعم الخطوط العريضة
            SelectableText.rich(
              TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7),
                children: _parseMarkdown(m.text),
              ),
              textDirection: TextDirection.rtl,
            ),
            if (!m.isUser) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _shareAIMessage(m.text),
                    child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.share, size: 16, color: Colors.white38)),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () { Clipboard.setData(ClipboardData(text: m.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); },
                    child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.copy, size: 16, color: Colors.white38)),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  // دالة بسيطة لتحويل **نص** إلى عريض
  List<InlineSpan> _parseMarkdown(String text) {
    final List<InlineSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    
    for (final match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold, color: goldAccent)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
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
              decoration: BoxDecoration(color: _isWaiting ? Colors.redAccent : primaryGreen, shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(_isWaiting ? Icons.stop : Icons.send, color: Colors.white, size: 20), 
                onPressed: _isWaiting 
                  ? () { setState(() => _cancelRequested = true); }
                  : _handleSubmit,
              ),
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
