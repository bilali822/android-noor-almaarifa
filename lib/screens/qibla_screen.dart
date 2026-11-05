import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _heading;
  double? _qiblaDirection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getQiblaDirection();
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) setState(() => _heading = event.heading);
    });
  }

  Future<void> _getQiblaDirection() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    double lat1 = position.latitude * (pi / 180);
    double lng1 = position.longitude * (pi / 180);
    double lat2 = kaabaLat * (pi / 180);
    double lng2 = kaabaLng * (pi / 180);
    double y = sin(lng2 - lng1);
    double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(lng2 - lng1);
    double qibla = atan2(y, x) * (180 / pi);
    if (mounted) setState(() { _qiblaDirection = qibla; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('بوصلة القبلة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), iconTheme: const IconThemeData(color: AppColors.primary)),
      body: _loading || _heading == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mosque, size: 60, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 24),
                  const Text('وجه هاتفك نحو الكعبة', style: TextStyle(color: AppColors.text, fontSize: 18)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 300, height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 4))),
                        Transform.rotate(angle: (_qiblaDirection! - _heading!) * (pi / 180), child: const Icon(Icons.navigation, size: 100, color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text('زاوية القبلة: ${_qiblaDirection!.toStringAsFixed(1)}°', style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
                ],
              ),
            ),
    );
  }
}
