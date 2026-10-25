import 'package:flutter/material.dart';
import '../models/chat_history.dart';
import '../services/chat_history_service.dart';
import '../theme/app_colors.dart';

class ChatHistoryScreen extends StatefulWidget {
  final String type; // 'ai' or 'quran'
  const ChatHistoryScreen({super.key, required this.type});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<SavedConversation> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ChatHistoryService.loadAll();
    if (!mounted) return;
    setState(() {
      _conversations = all.where((c) => c.type == widget.type).toList();
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await ChatHistoryService.delete(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: Text(
          widget.type == 'ai' ? 'سجل الذكاء الاصطناعي' : 'سجل القرآن', 
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _conversations.isEmpty
              ? const Center(child: Text('لا يوجد سجل محادثات.', style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversations.length,
                  itemBuilder: (context, i) {
                    final c = _conversations[i];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                        subtitle: Text(DateTime.parse(c.date).toString().substring(0, 16), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _delete(c.id),
                        ),
                        onTap: () => Navigator.pop(context, c),
                      ),
                    );
                  },
                ),
    );
  }
}
