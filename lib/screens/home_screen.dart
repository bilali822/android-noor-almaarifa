import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('نور المعرفة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Greeting
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً بك، $_userName',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'منصة متكاملة للقرآن الكريم والتفاسير المعتمدة',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Features Grid
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: 'القرآن والتفسير',
                    icon: Icons.menu_book,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCard(
                    title: 'الحديث الشريف',
                    icon: Icons.library_books,
                    onTap: () => _showComingSoon(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: 'الذكاء الاصطناعي',
                    icon: Icons.smart_toy,
                    onTap: () => _showComingSoon(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCard(
                    title: 'الإعدادات',
                    icon: Icons.settings,
                    onTap: () => _showComingSoon(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة قادمة في التحديث القادم', textAlign: TextAlign.center), backgroundColor: AppColors.primary),
    );
  }
}
