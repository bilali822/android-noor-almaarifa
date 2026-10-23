import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/quranic_background.dart';
import 'chat_screen.dart';
import 'welcome_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _currentIndex = 0;

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
      backgroundColor: AppColors.bgDeep,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('السلام عليكم', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('$_userName، نتمنى لك يوماً مباركاً', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          const QuranicBackground(child: SizedBox.expand()),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // كارت الآية الكبير
                      BouncyTap(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EAE0), // لون بيج فاتح
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 32, height: 1.8, color: AppColors.primary, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              const Text('سورة طه • الآية 114', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('تصفح القرآن الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // الكروت الأربعة
                      Row(
                        children: [
                          Expanded(child: _buildFeatureCard('الذكاء الاصطناعي', Icons.psychology, () => _showComingSoon())),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFeatureCard('الحديث', Icons.menu_book, () => _showComingSoon())),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildFeatureCard('الإعدادات', Icons.settings_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFeatureCard('المحفوظات', Icons.bookmark_border, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())))),
                        ],
                      ),
                      const SizedBox(height: 100), // مساحة لشريط التنقل
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // شريط التنقل الجديد (5 أزرار)
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.home, 'الرئيسية', 0),
              _navItem(Icons.menu_book, 'القرآن', 1),
              _navItem(Icons.search, 'البحث', 2),
              _navItem(Icons.auto_awesome, 'ذكاء', 3),
              _navItem(Icons.person, 'حسابي', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2)),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1 || index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textMuted, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً', textAlign: TextAlign.center)));
  }
}
