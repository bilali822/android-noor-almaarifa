import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import 'chat_screen.dart';
import 'welcome_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String _userName = ''; int _currentIndex = 0;
  @override void initState() { super.initState(); _loadName(); }
  Future<void> _loadName() async { final prefs = await SharedPreferences.getInstance(); setState(() => _userName = prefs.getString('user_name') ?? 'زائر'); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep, extendBody: true,
      body: Stack(children: [
        const AnimatedBackground(),
        SafeArea(bottom: false, child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('السلام عليكم،', style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5))]),
            IconButton(icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted), onPressed: () async { final prefs = await SharedPreferences.getInstance(); await prefs.clear(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen())); }),
          ]))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Container(
            padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.bgSurface], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withOpacity(0.3)), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(30)), child: const Text('آية اليوم', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))), const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20)]),
              const SizedBox(height: 20), const Text('﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 26, height: 1.6, color: Colors.white, fontFamily: 'serif', fontWeight: FontWeight.bold)),
              const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.bgDeep, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('تصفح القرآن الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
            ]),
          ))),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
            delegate: SliverChildListDelegate([
              _buildBentoCard(title: 'الحديث الشريف', icon: Icons.library_books_rounded, color: const Color(0xFF1E293B), onTap: () => _showComingSoon()),
              _buildBentoCard(title: 'الذكاء الاصطناعي', icon: Icons.psychology_rounded, color: const Color(0xFF1E293B), onTap: () => _showComingSoon()),
              _buildBentoCard(title: 'المحفوظات', icon: Icons.bookmark_rounded, color: const Color(0xFF1E293B), onTap: () => _showComingSoon()),
              _buildBentoCard(title: 'الإعدادات', icon: Icons.tune_rounded, color: const Color(0xFF1E293B), onTap: () => _showComingSoon()),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ])),
      ]),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24), height: 70, decoration: BoxDecoration(color: const Color(0xFF101623).withOpacity(0.85), borderRadius: BorderRadius.circular(35), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
        child: ClipRRect(borderRadius: BorderRadius.circular(35), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _navItem(Icons.home_rounded, 0), _navItem(Icons.menu_book_rounded, 1), _navItem(Icons.bookmark_rounded, 2), _navItem(Icons.person_rounded, 3),
        ])),
      ),
    );
  }
  Widget _buildBentoCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 28)),
        const SizedBox(height: 16), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ]),
    ));
  }
  Widget _navItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(onTap: () { setState(() => _currentIndex = index); if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())); }, child: AnimatedContainer(
      duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
      child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 26),
    ));
  }
  void _showComingSoon() { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('هذه الميزة ستتوفر قريباً', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFD4AF37), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); }
}
