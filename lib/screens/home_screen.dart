import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_background.dart';
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
    setState(() => _userName = prefs.getString('user_name') ?? 'زائر');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // عشان تظهر الخلفية المتحركة
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('نور المعرفة', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 22),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // الخلفية المتحركة
          const AnimatedBackground(),
          
          // المحتوى
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700), // أوسع شوية عشان الكروت تبان أحلى
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                    );
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // بطاقة الترحيب
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF151B2B).withOpacity(0.8), // شفافية خفيفة
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('أهلاً بك، $_userName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              const Text('نتمنى لك رحلة إيمانية ومعرفية مليئة بالنفع.', style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('الأقسام الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        
                        // 🌟 استخدام Rows بدل GridView عشان نضمن إنهم 2 × 2 بالظبط ومستحيل يبوظوا
                        Row(
                          children: [
                            Expanded(child: _buildCard(title: 'القرآن والتفسير', subtitle: 'تصفح السور والتفاسير', icon: Icons.menu_book, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCard(title: 'الحديث الشريف', subtitle: 'البحث في الأحاديث', icon: Icons.library_books, onTap: () => _showComingSoon())),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildCard(title: 'الذكاء الاصطناعي', subtitle: 'مساعد ذكي للإجابة', icon: Icons.smart_toy, onTap: () => _showComingSoon())),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCard(title: 'الإعدادات', subtitle: 'تخصيص تجربة الاستخدام', icon: Icons.settings, onTap: () => _showComingSoon())),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151B2B).withOpacity(0.8),
          border: Border.all(color: const Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFA68A61)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: const Color(0xFF0B101E), size: 26),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('هذه الميزة ستتوفر في التحديث القادم', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
