import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/quranic_background.dart';
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
      // 🌟 نقفل العرض عشان يبان زي الموبايل على الكمبيوتر
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: QuranicBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 1. الهيدر المخصص
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('السلام عليكم', style: TextStyle(color: AppColors.text, fontSize: 26, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$_name، نتمنى لك يوماً مباركاً', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.notifications_none, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFD6E4D6),
                              child: Icon(Icons.person, color: AppColors.primary, size: 24),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // 2. المحتوى
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // كارت الآية الكبير
                          BouncyTap(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6EBDC), // لون البيج الفاتح
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: const Color(0xFFEAD6C0), width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 36, height: 1.6, color: AppColors.primary, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('سورة طه • الآية 114', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text('تصفح القرآن الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // الكروت 2x2 (مربعة)
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0, // مربع
                            children: [
                              _buildFeatureCard('الذكاء الاصطناعي', Icons.psychology_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                              _buildFeatureCard('الحديث', Icons.menu_book_outlined, () {}),
                              _buildFeatureCard('الإعدادات', Icons.settings_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                              _buildFeatureCard('المحفوظات', Icons.bookmark_border, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
                            ],
                          ),
                          const SizedBox(height: 100), // مساحة لشريط التنقل
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
      // 3. شريط التنقل السفلي العائم
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.home, 'الرئيسية', true, () {}),
                  _navItem(Icons.menu_book_outlined, 'القرآن', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                  _navItem(Icons.search, 'البحث', false, () {}),
                  _navItem(Icons.auto_awesome, 'ذكاء', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                  _navItem(Icons.person_outline, 'حسابي', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تصميم الكارت المربع
  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16), 
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5)), 
              child: Icon(icon, color: AppColors.primary, size: 36)
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // تصميم أزرار التنقل
  Widget _navItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFFB0BEC5), size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : const Color(0xFFB0BEC5), fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ]
      ),
    );
  }
}
