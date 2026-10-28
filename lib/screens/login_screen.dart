// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = false;
  bool _isLoading = false;
  String _loginMethod = 'nik';

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi proses login demo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    }
  }

  void _showDemoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode Demo'),
        content: const Text(
          'Aplikasi ini menggunakan data demo. Untuk menggunakan autentikasi nyata, '
          'hubungkan dengan backend API yang sesuai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SWATheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header Perusahaan
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SWATheme.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 64,
                          color: SWATheme.surface,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'PT Swabina Gatra',
                          style: SWATheme.headingLarge.copyWith(
                            color: SWATheme.surface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SWA Asset Management System',
                          style: SWATheme.bodyMedium.copyWith(
                            color: SWATheme.surface.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SWATheme.accentTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Akses Internal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Judul dan Deskripsi
                  const Text(
                    'Masuk ke Portal',
                    style: SWATheme.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola inventaris dan aset perusahaan dengan mudah dan efisien',
                    style: SWATheme.bodyMedium.copyWith(
                      color: SWATheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Pilihan Metode Login
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SWATheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SWATheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildLoginMethodButton(
                            'NIK/Dinas',
                            'nik',
                            Icons.badge,
                          ),
                        ),
                        Expanded(
                          child: _buildLoginMethodButton(
                            'SSO Gatra',
                            'sso',
                            Icons.security,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input NIK/Email
                  TextFormField(
                    controller: _nikController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: _loginMethod == 'nik'
                          ? 'NIK Pegawai'
                          : 'Email',
                      hintText: _loginMethod == 'nik'
                          ? 'Masukkan NIK Anda'
                          : 'Masukkan email Anda',
                      prefixIcon: Icon(
                        _loginMethod == 'nik'
                            ? Icons.badge
                            : Icons.email,
                        color: SWATheme.secondaryText,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _loginMethod == 'nik'
                            ? 'NIK wajib diisi'
                            : 'Email wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: 'Masukkan kata sandi Anda',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: SWATheme.secondaryText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: SWATheme.secondaryText,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Checkbox Ingat Sesi
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberSession,
                        onChanged: (value) {
                          setState(() {
                            _rememberSession = value ?? false;
                          });
                        },
                        activeColor: SWATheme.primaryNavy,
                      ),
                      const Text(
                        'Ingat sesi ini',
                        style: SWATheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status Shift
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SWATheme.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SWATheme.accentTeal),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: SWATheme.accentTeal,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Status Shift:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SWATheme.accentTeal,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Aktif',
                          style: TextStyle(
                            color: SWATheme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Login
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SWATheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SWATheme.surface,
                              ),
                            ),
                          )
                        : const Text('Masuk ke Sistem Aset'),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Scan Badge/RFID
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur scan badge dalam pengembangan'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.nfc),
                    label: const Text('Scan Badge/RFID'),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Scan QR
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur scan QR dalam pengembangan'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Pegawai'),
                  ),

                  const SizedBox(height: 24),

                  // Info Demo
                  TextButton.icon(
                    onPressed: _showDemoInfo,
                    icon: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: SWATheme.secondaryText,
                    ),
                    label: const Text(
                      'Informasi Mode Demo',
                      style: TextStyle(
                        color: SWATheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginMethodButton(String label, String method, IconData icon) {
    final isSelected = _loginMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _loginMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? SWATheme.primaryNavy
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? SWATheme.surface
                  : SWATheme.secondaryText,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? SWATheme.surface
                    : SWATheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}