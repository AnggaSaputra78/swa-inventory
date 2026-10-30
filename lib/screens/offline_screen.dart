// lib/screens/offline_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/connectivity_service.dart';
import 'login_screen.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  final _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connectivityService.connectionStream.listen((isOnline) {
      if (isOnline && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SWATheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: SWATheme.dangerRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: SWATheme.dangerRed,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tidak Ada Koneksi Internet',
                  style: SWATheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aplikasi SWA Asset Management memerlukan koneksi internet untuk beroperasi. '
                  'Silakan periksa koneksi Anda dan coba lagi.',
                  style: SWATheme.bodyMedium.copyWith(
                    color: SWATheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Coba cek koneksi lagi
                    if (_connectivityService.isOnline) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Masih tidak ada koneksi internet'),
                          backgroundColor: SWATheme.dangerRed,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}