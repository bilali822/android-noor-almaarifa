import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});
  @override State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  final int _totalPages = 604;
  int _selectedDays = 30;
  int _pagesRead = 0;
  DateTime? _startDate;
  final List<int> _durationOptions = [7, 14, 21, 30, 60, 90];

  @override void initState() { super.initState(); _loadData(); }
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDays = prefs.getInt('khatma_days') ?? 30;
      _pagesRead = prefs.getInt('khatma_read') ?? 0;
      final startStr = prefs.getString('khatma_start');
      if (startStr != null) _startDate = DateTime.parse(startStr);
    });
  }

  Future<void> _startKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('khatma_days', _selectedDays);
    await prefs.setInt('khatma_read', 0);
    await prefs.setString('khatma_start', now.toIso8601String());
    setState(() { _pagesRead = 0; _startDate = now; });
  }

  Future<void> _updateProgress(int pages) async {
    if (_startDate == null) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() => _pagesRead = (_pagesRead + pages).clamp(0, _totalPages));
    await prefs.setInt('khatma_read', _pagesRead);
  }

  @override
  Widget build(BuildContext context) {
    final dailyPages = (_totalPages / _selectedDays).ceil();
    final progress = _pagesRead / _totalPages;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('متتبع الختمة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), iconTheme: const IconThemeData(color: AppColors.primary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          if (_startDate == null) ...[
            const Icon(Icons.menu_book, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('خطط لختم القرآن الكريم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 32),
            Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _durationOptions.map((d) => ChoiceChip(
              label: Text('$d يوم', style: TextStyle(color: _selectedDays == d ? Colors.white : AppColors.text)),
              selected: _selectedDays == d, selectedColor: AppColors.primary,
              onSelected: (v) => setState(() => _selectedDays = d),
            )).toList()),
            const SizedBox(height: 32),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text('ستحتاج لقراءة $dailyPages صفحة يومياً', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary))),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _startKhatma, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('ابدأ الختمة الآن', style: TextStyle(fontSize: 18, color: Colors.white))),
          ] else ...[
            Stack(alignment: Alignment.center, children: [
              SizedBox(width: 220, height: 220, child: CircularProgressIndicator(value: progress, strokeWidth: 16, backgroundColor: AppColors.primary.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary))),
              Column(children: [Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)), Text('$_pagesRead / $_totalPages', style: const TextStyle(color: AppColors.textMuted))]),
            ]),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildProgressButton('+1', () => _updateProgress(1)),
              _buildProgressButton('+5', () => _updateProgress(5)),
              _buildProgressButton('+10', () => _updateProgress(10)),
            ]),
          ]
        ]),
      ),
    );
  }
  Widget _buildProgressButton(String text, VoidCallback onTap) {
    return ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
