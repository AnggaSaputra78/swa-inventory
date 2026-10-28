// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'asset_list_screen.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';
import '../models/asset.dart';
import '../services/asset_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final AssetService _assetService = AssetService();

  @override
  void initState() {
    super.initState();
    _assetService.initializeDemoData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssetListScreen()),
        );
        break;
      case 2:
        _showComingSoon('Peminjaman Aset');
        break;
      case 3:
        _showComingSoon('Servis Aset');
        break;
      case 4:
        _showComingSoon('Menu Lainnya');
        break;
    }
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
    final assets = _assetService.getAllAssets();
    final totalAssets = assets.length;
    final activeAssets = assets.where((a) => a.status == 'Aktif').length;
    final borrowedAssets = assets.where((a) => a.status == 'Dipinjam').length;
    final maintenanceAssets = assets.where((a) => a.status == 'Perawatan').length;

    final goodCondition = assets.where((a) => a.condition == 'Baik').length;
    final needMaintenance = assets.where((a) => a.condition == 'Perlu Perawatan').length;
    final damaged = assets.where((a) => a.condition == 'Rusak').length;

    return Scaffold(
      backgroundColor: SWATheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                color: SWATheme.primaryNavy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              style: SWATheme.headingLarge.copyWith(
                                color: SWATheme.surface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search),
                              color: SWATheme.surface,
                              onPressed: () {
                                _showComingSoon('Pencarian');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications),
                              color: SWATheme.surface,
                              onPressed: () {
                                _showComingSoon('Notifikasi');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ringkasan Aset
                    const Text(
                      'Ringkasan Aset',
                      style: SWATheme.headingMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Aset',
                            totalAssets.toString(),
                            Icons.inventory_2,
                            SWATheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Aset Aktif',
                            activeAssets.toString(),
                            Icons.check_circle,
                            SWATheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Dipinjam',
                            borrowedAssets.toString(),
                            Icons.handshake,
                            SWATheme.warningAmber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Perawatan',
                            maintenanceAssets.toString(),
                            Icons.build,
                            SWATheme.secondaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Visualisasi Kondisi Aset
                    const Text(
                      'Kondisi Aset',
                      style: SWATheme.headingMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildConditionBar(
                              'Baik',
                              goodCondition,
                              totalAssets,
                              SWATheme.successGreen,
                            ),
                            const SizedBox(height: 12),
                            _buildConditionBar(
                              'Perlu Perawatan',
                              needMaintenance,
                              totalAssets,
                              SWATheme.warningAmber,
                            ),
                            const SizedBox(height: 12),
                            _buildConditionBar(
                              'Rusak',
                              damaged,
                              totalAssets,
                              SWATheme.dangerRed,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Peringatan
                    const Text(
                      'Perlu Tindakan Segera',
                      style: SWATheme.headingMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildAlertItem(
                              Icons.warning_amber,
                              '3 peminjaman mendekati batas waktu',
                              SWATheme.warningAmber,
                            ),
                            const Divider(height: 24),
                            _buildAlertItem(
                              Icons.build_circle,
                              '2 jadwal servis perlu ditindaklanjuti',
                              SWATheme.secondaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Aset Prioritas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aset Prioritas',
                          style: SWATheme.headingMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AssetListScreen(),
                              ),
                            );
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...assets.take(3).map((asset) => _buildAssetCard(asset)),

                    const SizedBox(height: 24),

                    // Tombol Tambah Aset
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AssetFormScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Aset'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Aset',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: 'Pinjam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Servis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Lainnya',
          ),
        ],
      ),
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
            Text(
              value,
              style: SWATheme.headingLarge.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: SWATheme.bodySmall,
            ),
          ],
        ),
      ),
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
            Text('$count (${percentage.toStringAsFixed(0)}%)',
                style: SWATheme.bodySmall),
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

  Widget _buildAlertItem(IconData icon, String message, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: SWATheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailScreen(asset: asset),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    asset.code,
                    style: SWATheme.headingSmall.copyWith(
                      color: SWATheme.primaryNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(asset.condition).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      asset.condition,
                      style: TextStyle(
                        color: _getConditionColor(asset.condition),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(asset.name, style: SWATheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                '${asset.category} • ${asset.location}',
                style: SWATheme.bodySmall,
              ),
            ],
          ),
        ),
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