import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(30)), child: const Icon(Icons.menu_book, color: Colors.white, size: 50)),
              const SizedBox(height: 32),
              const Text('نور المعرفة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 40),
              TextField(controller: _nameController, textAlign: TextAlign.center, decoration: InputDecoration(hintText: 'أدخل اسمك للبدء', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 24),
              BouncyTap(onTap: _saveName, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)), child: const Text('متابعة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }
}
