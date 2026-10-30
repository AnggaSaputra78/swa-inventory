// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'offline_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Tampilkan splash sebentar agar tidak berkedip
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _navigated) return;

    // 1) Tidak ada internet -> layar offline
    if (!_connectivityService.isOnline) {
      _navigateTo(const OfflineScreen());
      return;
    }

    // 2) Online -> cek sesi, lalu masuk Dashboard atau Login.
    //    try/catch menjamin splash TIDAK AKAN PERNAH nyangkut,
    //    misalnya saat Firebase tidak tersedia di platform Web.
    try {
      final firebase = FirebaseService();
      final isLoggedIn = firebase.isInitialized && firebase.isAuthenticated;
      if (!mounted || _navigated) return;
      _navigateTo(isLoggedIn ? const DashboardScreen() : const LoginScreen());
    } catch (e) {
      debugPrint('SplashScreen error: $e');
      if (!mounted || _navigated) return;
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget page) {
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SWATheme.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: SWATheme.surface),
            const SizedBox(height: 24),
            Text(
              'SWA Asset Management',
              style: SWATheme.headingLarge.copyWith(color: SWATheme.surface),
            ),
            const SizedBox(height: 8),
            Text(
              'PT Swabina Gatra',
              style: SWATheme.bodyMedium.copyWith(
                color: SWATheme.surface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SWATheme.surface),
            ),
          ],
        ),
      ),
    );
  }
}