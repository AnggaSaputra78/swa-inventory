// lib/screens/asset_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/asset.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: SWATheme.background,
      appBar: AppBar(
        title: Text(widget.asset.name),
      ),
      body: Column(
        children: [
          Container(
            color: SWATheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: SWATheme.primaryNavy,
              unselectedLabelColor: SWATheme.secondaryText,
              indicatorColor: SWATheme.primaryNavy,
              tabs: const [
                Tab(text: 'Informasi'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Pemeliharaan'),
                Tab(text: 'Dokumen'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildHistoryTab(),
                _buildMaintenanceTab(),
                _buildDocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.asset.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(widget.asset.status)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: _getStatusColor(widget.asset.status),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.asset.status,
                  style: TextStyle(
                    color: _getStatusColor(widget.asset.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Informasi Dasar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Dasar',
                    style: SWATheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Kode Aset', widget.asset.code),
                  _buildInfoRow('Nama Aset', widget.asset.name),
                  _buildInfoRow('Kategori', widget.asset.category),
                  _buildInfoRow('Lokasi', widget.asset.location),
                  _buildInfoRow('Penanggung Jawab', widget.asset.responsiblePerson),
                  _buildInfoRow(
                    'Nilai Perolehan',
                    'Rp ${widget.asset.acquisitionPrice.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]}.',
                    )}',
                  ),
                  _buildInfoRow(
                    'Tanggal Perolehan',
                    DateFormat('dd MMMM yyyy').format(widget.asset.acquisitionDate),
                  ),
                  _buildInfoRow('Kondisi', widget.asset.condition),
                  if (widget.asset.specifications != null)
                    _buildInfoRow('Spesifikasi', widget.asset.specifications!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Informasi Pengadaan
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pengadaan',
                    style: SWATheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Merek', widget.asset.brand),
                  _buildInfoRow('Model', widget.asset.model),
                  _buildInfoRow('Nomor Seri', widget.asset.serialNumber),
                  _buildInfoRow('Vendor', widget.asset.vendor),
                  _buildInfoRow('Departemen', widget.asset.department),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Tindakan
          const Text(
            'Tindakan',
            style: SWATheme.headingSmall,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.edit,
            'Edit Aset',
            () => _showComingSoon('Edit Aset'),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            Icons.swap_horiz,
            'Ajukan Mutasi',
            () => _showComingSoon('Mutasi Aset'),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            Icons.build,
            'Catat Perawatan',
            () => _showComingSoon('Catat Perawatan'),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            Icons.report_problem,
            'Laporkan Kerusakan',
            () => _showComingSoon('Lapor Kerusakan'),
            color: SWATheme.dangerRed,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: SWATheme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat Aset',
            style: SWATheme.headingSmall.copyWith(
              color: SWATheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat untuk aset ini',
            style: SWATheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_circle,
            size: 64,
            color: SWATheme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat Pemeliharaan',
            style: SWATheme.headingSmall.copyWith(
              color: SWATheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada catatan pemeliharaan',
            style: SWATheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: SWATheme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Dokumen Aset',
            style: SWATheme.headingSmall.copyWith(
              color: SWATheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada dokumen yang diunggah',
            style: SWATheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: SWATheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: SWATheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    final buttonColor = color ?? SWATheme.primaryNavy;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: buttonColor),
        label: Text(
          label,
          style: TextStyle(color: buttonColor),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return SWATheme.successGreen;
      case 'Dipinjam':
        return SWATheme.warningAmber;
      case 'Perawatan':
        return SWATheme.secondaryBlue;
      case 'Rusak':
        return SWATheme.dangerRed;
      default:
        return SWATheme.secondaryText;
    }
  }
}