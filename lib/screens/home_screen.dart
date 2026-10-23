import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import 'chat_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => _name = p.getString('user_name') ?? 'زائر'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('السلام عليكم', style: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('$_name، نتمنى لك يوماً مباركاً', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]), child: const Icon(Icons.notifications_none, color: AppColors.primary, size: 24)),
                              Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.redDot, shape: BoxShape.circle)))
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFD3E2D3), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.person, color: AppColors.primary, size: 28))
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        BouncyTap(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
                            decoration: BoxDecoration(color: AppColors.bgCardBeige, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border, width: 1)),
                            child: Column(
                              children: [
                                const Text('﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 38, height: 1.6, color: AppColors.primary, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                const Text('سورة طه • الآية ١١٤', style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 36),
                                ElevatedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                  child: const Text('تصفح القرآن الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.0,
                          children: [
                            _buildFeatureCard('الذكاء الاصطناعي', Icons.psychology_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                            _buildFeatureCard('الحديث', Icons.menu_book_outlined, () {}),
                            _buildFeatureCard('الإعدادات', Icons.settings_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                            _buildFeatureCard('المحفوظات', Icons.bookmark_border, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              height: 75,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.home, 'الرئيسية', true, () {}),
                  _navItem(Icons.menu_book_outlined, 'القرآن', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                  _navItem(Icons.search, 'البحث', false, () {}),
                  _navItem(Icons.auto_awesome_outlined, 'ذكاء', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                  _navItem(Icons.person_outline, 'حسابي', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5)), child: Icon(icon, color: AppColors.primary, size: 36)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E), size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E), fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ]
      ),
    );
  }
}
