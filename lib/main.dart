// lib/main.dart
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

void main() {
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
      home: const LoginScreen(),
    );
  }
}