import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController(); bool _isLoading = false;
  final List<Map<String, String>> _quotes = [
    {"text": "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾", "source": "سورة طه"}, {"text": "﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾", "source": "سورة الرعد"}, {"text": "﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾", "source": "سورة الشرح"},
  ];
  late Map<String, String> _currentQuote;
  @override void initState() { super.initState(); _currentQuote = _quotes[Random().nextInt(_quotes.length)]; }
  Future<void> _saveName() async {
    final name = _nameController.text.trim(); if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance(); await prefs.setString('user_name', name);
    if (!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFA68A61)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))]), child: const Icon(Icons.auto_stories, color: Color(0xFF06080E), size: 50)),
            const SizedBox(height: 40),
            const Text('نور المعرفة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border(right: const BorderSide(color: Color(0xFFD4AF37), width: 4), top: BorderSide(color: Colors.white.withOpacity(0.05)), bottom: BorderSide(color: Colors.white.withOpacity(0.05)), left: BorderSide(color: Colors.white.withOpacity(0.05)))),
              child: Column(children: [Text(_currentQuote['text']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.white, fontFamily: 'serif')), const SizedBox(height: 8), Text(_currentQuote['source']!, style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: 'أدخل اسمك للبدء', hintStyle: const TextStyle(color: AppColors.textMuted), filled: true, fillColor: const Color(0xFF101623), contentPadding: const EdgeInsets.symmetric(vertical: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1E293B))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2))),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isLoading ? null : _saveName, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF06080E), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF06080E), strokeWidth: 2)) : const Text('الدخول للمنصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }
}
