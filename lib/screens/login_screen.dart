// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';
import 'dashboard_screen.dart';
import 'offline_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  final _connectivityService = ConnectivityService();

  bool _obscurePassword = true;
  bool _rememberSession = false;
  bool _isLoading = false;
  String _loginMethod = 'nik';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() {
    _connectivityService.connectionStream.listen((isOnline) {
      if (!isOnline && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OfflineScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Cegah login di Web karena Firebase Web belum dikonfigurasi
    if (kIsWeb) {
      _showErrorDialog(
        'Login via Web belum dikonfigurasi. Silakan gunakan Emulator atau Device Android untuk menguji Firebase.',
      );
      return;
    }

    if (!_connectivityService.isOnline) {
      _showErrorDialog('Tidak ada koneksi internet. Silakan periksa koneksi Anda.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _firebaseService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $feature dalam pengembangan')),
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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 32),
                  _buildLoginMethodSelector(),
                  const SizedBox(height: 24),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildRememberMe(),
                  const SizedBox(height: 8),
                  _buildShiftStatus(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildScanButtons(),
                  const SizedBox(height: 24),
                  _buildOnlineIndicator(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SWATheme.primaryNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.business, size: 64, color: SWATheme.surface),
          const SizedBox(height: 16),
          Text(
            'PT Swabina Gatra',
            style: SWATheme.headingLarge.copyWith(color: SWATheme.surface),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Masuk ke Portal',
          style: SWATheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola inventaris dan aset perusahaan dengan mudah dan efisien',
          style: SWATheme.bodyMedium.copyWith(color: SWATheme.secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SWATheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SWATheme.border),
      ),
      child: Row(
        children: [
          Expanded(child: _buildLoginMethodButton('NIK/Dinas', 'nik', Icons.badge)),
          Expanded(child: _buildLoginMethodButton('SSO Gatra', 'sso', Icons.security)),
        ],
      ),
    );
  }

  Widget _buildLoginMethodButton(String label, String method, IconData icon) {
    final isSelected = _loginMethod == method;
    return InkWell(
      onTap: () => setState(() => _loginMethod = method),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? SWATheme.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? SWATheme.surface : SWATheme.secondaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? SWATheme.surface : SWATheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: _loginMethod == 'nik' ? 'NIK Pegawai / Email' : 'Email',
        hintText: _loginMethod == 'nik' ? 'Masukkan NIK atau email' : 'Masukkan email Anda',
        prefixIcon: Icon(
          _loginMethod == 'nik' ? Icons.badge : Icons.email,
          color: SWATheme.secondaryText,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _loginMethod == 'nik' ? 'NIK/Email wajib diisi' : 'Email wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Kata Sandi',
        hintText: 'Masukkan kata sandi Anda',
        prefixIcon: const Icon(Icons.lock, color: SWATheme.secondaryText),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: SWATheme.secondaryText,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
        if (value.length < 6) return 'Kata sandi minimal 6 karakter';
        return null;
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberSession,
          onChanged: (value) => setState(() => _rememberSession = value ?? false),
          activeColor: SWATheme.primaryNavy,
        ),
        const Text('Ingat sesi ini', style: SWATheme.bodyMedium),
      ],
    );
  }

  Widget _buildShiftStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SWATheme.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SWATheme.accentTeal),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time, color: SWATheme.accentTeal, size: 20),
          SizedBox(width: 8),
          Text(
            'Status Shift:',
            style: TextStyle(fontWeight: FontWeight.w600, color: SWATheme.accentTeal),
          ),
          SizedBox(width: 4),
          Text('Aktif', style: TextStyle(color: SWATheme.accentTeal)),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
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
                valueColor: AlwaysStoppedAnimation<Color>(SWATheme.surface),
              ),
            )
          : const Text('Masuk ke Sistem Aset'),
    );
  }

  Widget _buildScanButtons() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => _showComingSoon('Scan Badge/RFID'),
          icon: const Icon(Icons.nfc),
          label: const Text('Scan Badge/RFID'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showComingSoon('Scan QR Pegawai'),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR Pegawai'),
        ),
      ],
    );
  }

  Widget _buildOnlineIndicator() {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStream,
      initialData: _connectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isOnline
                  ? SWATheme.successGreen.withValues(alpha: 0.1)
                  : SWATheme.dangerRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: isOnline ? SWATheme.successGreen : SWATheme.dangerRed,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Online' : 'Offline - Tidak ada koneksi',
                  style: TextStyle(
                    color: isOnline ? SWATheme.successGreen : SWATheme.dangerRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}