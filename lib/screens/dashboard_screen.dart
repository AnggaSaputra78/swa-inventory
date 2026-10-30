// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/asset.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';
import 'asset_list_screen.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';
import 'login_screen.dart';
import 'offline_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _firebaseService = FirebaseService();
  final _connectivityService = ConnectivityService();

  List<Asset> _assets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _checkConnectivity();
  }

  void _checkConnectivity() {
    _connectivityService.connectionStream.listen((isOnline) {
      if (!isOnline && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OfflineScreen()),
        );
      } else if (isOnline && mounted) {
        _loadAssets();
      }
    });
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assets = await _firebaseService.getAssets();
      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _firebaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssetListScreen()),
        );
        break;
      case 2:
        _showComingSoon('Peminjaman Aset');
        break;
      case 3:
        _showComingSoon('Servis Aset');
        break;
      case 4:
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: SWATheme.dangerRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fitur Dalam Pengembangan'),
        content: Text('Fitur $feature akan segera tersedia.'),
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
    final totalAssets = _assets.length;
    final activeAssets = _assets.where((a) => a.status == 'Aktif').length;
    final borrowedAssets = _assets.where((a) => a.status == 'Dipinjam').length;
    final maintenanceAssets = _assets.where((a) => a.status == 'Perawatan').length;
    final goodCondition = _assets.where((a) => a.condition == 'Baik').length;
    final needMaintenance = _assets.where((a) => a.condition == 'Perlu Perawatan').length;
    final damaged = _assets.where((a) => a.condition == 'Rusak').length;

    return Scaffold(
      backgroundColor: SWATheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummarySection(totalAssets, activeAssets, borrowedAssets, maintenanceAssets),
                              const SizedBox(height: 24),
                              _buildConditionSection(goodCondition, needMaintenance, damaged, totalAssets),
                              const SizedBox(height: 24),
                              _buildAlertSection(),
                              const SizedBox(height: 24),
                              _buildPrioritySection(),
                              const SizedBox(height: 24),
                              _buildAddButton(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Aset'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Pinjam'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servis'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Keluar'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: SWATheme.primaryNavy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PT Swabina Gatra',
                style: SWATheme.bodyMedium.copyWith(
                  color: SWATheme.surface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dashboard',
                style: SWATheme.headingLarge.copyWith(color: SWATheme.surface),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                color: SWATheme.surface,
                onPressed: _loadAssets,
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                color: SWATheme.surface,
                onPressed: () => _showComingSoon('Notifikasi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: SWATheme.dangerRed),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: SWATheme.headingSmall),
            const SizedBox(height: 8),
            Text(_error!, style: SWATheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAssets,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(int total, int active, int borrowed, int maintenance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Aset', style: SWATheme.headingMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Aset', total.toString(), Icons.inventory_2, SWATheme.primaryNavy)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Aset Aktif', active.toString(), Icons.check_circle, SWATheme.successGreen)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Dipinjam', borrowed.toString(), Icons.handshake, SWATheme.warningAmber)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Perawatan', maintenance.toString(), Icons.build, SWATheme.secondaryBlue)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(value, style: SWATheme.headingLarge.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: SWATheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSection(int good, int needMaint, int damaged, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kondisi Aset', style: SWATheme.headingMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildConditionBar('Baik', good, total, SWATheme.successGreen),
                const SizedBox(height: 12),
                _buildConditionBar('Perlu Perawatan', needMaint, total, SWATheme.warningAmber),
                const SizedBox(height: 12),
                _buildConditionBar('Rusak', damaged, total, SWATheme.dangerRed),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: SWATheme.bodyMedium),
            Text('$count (${percentage.toStringAsFixed(0)}%)', style: SWATheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: SWATheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Perlu Tindakan Segera', style: SWATheme.headingMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAlertItem(Icons.warning_amber, '3 peminjaman mendekati batas waktu', SWATheme.warningAmber),
                const Divider(height: 24),
                _buildAlertItem(Icons.build_circle, '2 jadwal servis perlu ditindaklanjuti', SWATheme.secondaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(IconData icon, String message, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: SWATheme.bodyMedium)),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Aset Prioritas', style: SWATheme.headingMedium),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetListScreen())),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_assets.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48, color: SWATheme.secondaryText),
                    const SizedBox(height: 12),
                    Text('Belum ada aset', style: SWATheme.bodyMedium.copyWith(color: SWATheme.secondaryText)),
                  ],
                ),
              ),
            ),
          )
        else
          ..._assets.take(3).map((asset) => _buildAssetCard(asset)),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(asset.code, style: SWATheme.headingSmall.copyWith(color: SWATheme.primaryNavy)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConditionColor(asset.condition).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asset.condition,
                      style: TextStyle(color: _getConditionColor(asset.condition), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(asset.name, style: SWATheme.bodyMedium),
              const SizedBox(height: 4),
              Text('${asset.category} • ${asset.location}', style: SWATheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetFormScreen())).then((_) => _loadAssets());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aset'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Baik':
        return SWATheme.successGreen;
      case 'Perlu Perawatan':
        return SWATheme.warningAmber;
      case 'Rusak':
        return SWATheme.dangerRed;
      default:
        return SWATheme.secondaryText;
    }
  }
}