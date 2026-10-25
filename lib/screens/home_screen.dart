import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/quranic_background.dart';
import '../services/notification_service.dart';
import 'chat_screen.dart';
import 'ai_chat_screen.dart';
import 'mushaf_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'hadith_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  String _timeString = '';
  String _hijriDate = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => _name = p.getString('user_name') ?? 'زائر'));
    
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _initNotifications();
      });
    });
  }

  Future<void> _initNotifications() async {
    await NotificationService.instance.init();
    await NotificationService.instance.showWelcomeNotification();
    await NotificationService.instance.scheduleDailyNotification();
    
    await NotificationService.instance.updatePrayerTimesByLocation();
    if (mounted) setState(() {});
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  void _updateTime() {
    final now = DateTime.now();
    initializeDateFormatting('ar', null);
    final format = DateFormat('hh:mm a', 'ar');
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    
    if (mounted) {
      setState(() {
        _timeString = _toArabicNumbers(format.format(now));
        _hijriDate = _toArabicNumbers('${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ');
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: QuranicBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 🌟 الهيدر (تم إصلاحه باستخدام Expanded)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 40, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( // 🌟 هذا هو الحل لمنع خروج النص
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('السلام عليكم', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('$_name، نتمنى لك يوماً مباركاً', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              const SizedBox(height: 12),
                              // 🌟 البطاقات الزمنية
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_filled, color: AppColors.primary, size: 14),
                                        const SizedBox(width: 4),
                                        Text(_timeString, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                        const SizedBox(width: 8),
                                        Container(width: 1, height: 12, color: Colors.grey.shade300),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.calendar_month, color: AppColors.primary, size: 14),
                                        const SizedBox(width: 4),
                                        Text(_hijriDate, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.mosque, color: AppColors.primary, size: 14),
                                        const SizedBox(width: 4),
                                        Text('${NotificationService.instance.nextPrayerName}: ${NotificationService.instance.nextPrayerTime}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                              child: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFD3E2D3), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.person, color: AppColors.primary, size: 28)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  // المحتوى
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          BouncyTap(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen())),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                              decoration: BoxDecoration(color: AppColors.bgCardBeige, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 1)),
                              child: Column(
                                children: [
                                  const Text('﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 32, height: 1.6, color: AppColors.primary, fontFamily: 'UthmanicHafs', fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text('سورة طه • الآية ١١٤', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen())),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                    child: const Text('إقرأ كلامَ الله', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.05,
                            children: [
                              _buildFeatureCard('المصحف', Icons.auto_stories, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen())); }),
                              _buildFeatureCard('تفسير القرآن', Icons.import_contacts, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())); }),
                              _buildFeatureCard('الذكاء الاصطناعي', Icons.psychology, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())); }),
                              _buildFeatureCard('الحديث', Icons.menu_book, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())); }),
                              _buildFeatureCard('الإعدادات', Icons.settings, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
                              _buildFeatureCard('المحفوظات', Icons.bookmark, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())); }),
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
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              height: 70,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(Icons.home, 'الرئيسية', true, () {}),
                  _navItem(Icons.menu_book_outlined, 'القرآن', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen()))),
                  _navItem(Icons.search, 'البحث', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                  _navItem(Icons.auto_awesome_outlined, 'ذكاء', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()))),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5)), child: Icon(icon, color: AppColors.primary, size: 30)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.bold)),
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
          Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E), fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ]
      ),
    );
  }
}
