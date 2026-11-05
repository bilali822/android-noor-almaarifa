import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});
  @override State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _count = 0;
  int _target = 33;
  String _currentZikr = 'سُبْحَانَ اللَّهِ';
  final List<Map<String, dynamic>> _adhkar = [
    {'text': 'سُبْحَانَ اللَّهِ', 'target': 33},
    {'text': 'الْحَمْدُ لِلَّهِ', 'target': 33},
    {'text': 'اللَّهُ أَكْبَرُ', 'target': 34},
    {'text': 'لَا إِلَهَ إِلَّا اللَّهُ', 'target': 100},
  ];

  @override void initState() { super.initState(); _loadCount(); }
  Future<void> _loadCount() async { final prefs = await SharedPreferences.getInstance(); setState(() => _count = prefs.getInt('tasbeeh_count') ?? 0); }
  Future<void> _saveCount() async { final prefs = await SharedPreferences.getInstance(); await prefs.setInt('tasbeeh_count', _count); }
  void _increment() {
    HapticFeedback.lightImpact();
    setState(() { _count++; if (_count >= _target) { HapticFeedback.heavyImpact(); _count = 0; } });
    _saveCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep, title: const Text('السبحة الإلكترونية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.primary), onPressed: () { setState(() => _count = 0); _saveCount(); })],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 8, children: _adhkar.map((z) => ChoiceChip(
              label: Text(z['text'], style: TextStyle(color: _currentZikr == z['text'] ? Colors.white : AppColors.text, fontFamily: 'UthmanicHafs', fontSize: 16)),
              selected: _currentZikr == z['text'], selectedColor: AppColors.primary,
              onSelected: (v) { setState(() { _currentZikr = z['text']; _target = z['target']; _count = 0; }); },
            )).toList()),
          ),
          const Spacer(),
          Text(_currentZikr, style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 40, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.1), border: Border.all(color: AppColors.primary, width: 4), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 10)]),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$_count', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.primary)), Text('/ $_target', style: const TextStyle(fontSize: 24, color: AppColors.textMuted))])),
            ),
          ),
          const Spacer(),
          const Padding(padding: EdgeInsets.only(bottom: 32), child: Text('اضغط على الدائرة للتسبيح', style: TextStyle(color: AppColors.textMuted))),
        ],
      ),
    );
  }
}
