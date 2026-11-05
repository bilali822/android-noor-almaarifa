import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AsmaaAllahScreen extends StatelessWidget {
  const AsmaaAllahScreen({super.key});
  final List<String> _names = const ['الرَّحْمَنُ', 'الرَّحِيمُ', 'الْمَلِكُ', 'الْقُدُّوسُ', 'السَّلَامُ', 'الْمُؤْمِنُ', 'الْمُهَيْمِنُ', 'الْعَزِيزُ', 'الْجَبَّارُ', 'الْمُتَكَبِّرُ'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('أسماء الله الحسنى', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), iconTheme: const IconThemeData(color: AppColors.primary)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
        itemCount: _names.length,
        itemBuilder: (context, i) => Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF155E35), Color(0xFF0E3A21)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4AF37), width: 1.5)),
          child: Center(child: Text(_names[i], style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}
