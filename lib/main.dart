import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- TAMBAHKAN INI
import 'theme.dart';
import 'services/firebase_service.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase hanya diinisialisasi di platform native (Android/iOS).
  // Web memerlukan konfigurasi script tambahan di web/index.html.
  if (!kIsWeb) {
    await FirebaseService().initialize();
  }

  await ConnectivityService().initialize();

  runApp(const SWAAssetManagementApp());
}

class SWAAssetManagementApp extends StatelessWidget {
  const SWAAssetManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWA Asset Management',
      debugShowCheckedModeBanner: false,
      theme: SWATheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}