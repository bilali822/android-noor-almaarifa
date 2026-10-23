import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/quranic_background.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final List<Map<String, String>> _quotes = [
    {"text": "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾", "source": "سورة طه"}, 
    {"text": "﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾", "source": "سورة الرعد"}, 
    {"text": "﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾", "source": "سورة الشرح"},
  ];
  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F4C3A), Color(0xFF0A3629)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: const Color(0xFF0F4C3A).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.auto_stories, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 40),
          const Text('نور المعرفة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 1)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border(right: const BorderSide(color: Color(0xFF0F4C3A), width: 4), top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border), left: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Text(_currentQuote['text']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.8, color: AppColors.text, fontFamily: 'UthmanicHafs')),
                const SizedBox(height: 8),
                Text(_currentQuote['source']!, style: const TextStyle(fontSize: 12, color: Color(0xFF0F4C3A), fontWeight: FontWeight.bold))
              ],
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: 'أدخل اسمك للبدء', hintStyle: const TextStyle(color: AppColors.textMuted), filled: true, fillColor: AppColors.bgSurface, contentPadding: const EdgeInsets.symmetric(vertical: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F4C3A), width: 2))),
          ),
          const SizedBox(height: 24),
          BouncyTap(
            onTap: _isLoading ? () {} : _saveName,
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveName,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('الدخول للمنصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const QuranicBackground(child: SizedBox.expand()),
          SafeArea(
            child: Center(
              child: kIsWeb 
                  ? content 
                  : TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(offset: Offset(0, 30 * (1 - value)), child: Opacity(opacity: value, child: child));
                      },
                      child: content,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
