// lib/screens/asset_list_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/asset.dart';
import '../services/firebase_service.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final _firebaseService = FirebaseService();
  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Elektronik', 'Furnitur', 'Kendaraan', 'Alat Tulis'];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final assets = await _firebaseService.getAssets();
      setState(() {
        _assets = assets;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: SWATheme.dangerRed),
        );
      }
    }
  }

  void _applyFilters() {
    var filtered = List<Asset>.from(_assets);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((asset) {
        return asset.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            asset.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            asset.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((asset) => asset.category == _selectedCategory).toList();
    }

    setState(() => _filteredAssets = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SWATheme.background,
      appBar: AppBar(
        title: const Text('Daftar Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssets,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: SWATheme.surface,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari aset...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                              _applyFilters();
                            });
                          },
                          selectedColor: SWATheme.primaryNavy,
                          checkmarkColor: SWATheme.surface,
                          labelStyle: TextStyle(
                            color: isSelected ? SWATheme.surface : SWATheme.primaryText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Menampilkan ${_filteredAssets.length} dari ${_assets.length} aset',
              style: SWATheme.bodySmall,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAssets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: SWATheme.secondaryText),
                            const SizedBox(height: 16),
                            Text('Tidak ada aset ditemukan', style: SWATheme.bodyMedium.copyWith(color: SWATheme.secondaryText)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredAssets.length,
                        itemBuilder: (context, index) => _buildAssetCard(_filteredAssets[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetFormScreen())).then((_) => _loadAssets());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aset'),
        backgroundColor: SWATheme.primaryNavy,
        foregroundColor: SWATheme.surface,
      ),
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.code, style: SWATheme.headingSmall.copyWith(color: SWATheme.primaryNavy)),
                      const SizedBox(height: 4),
                      Text(asset.name, style: SWATheme.bodyMedium),
                    ],
                  ),
                ),
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: SWATheme.secondaryText),
                const SizedBox(width: 4),
                Text(asset.category, style: SWATheme.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16, color: SWATheme.secondaryText),
                const SizedBox(width: 4),
                Expanded(child: Text(asset.location, style: SWATheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: SWATheme.secondaryText),
                const SizedBox(width: 4),
                Expanded(child: Text(asset.responsiblePerson, style: SWATheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: SWATheme.secondaryText),
                const SizedBox(width: 4),
                Text(
                  'Rp ${asset.acquisitionPrice.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}',
                  style: SWATheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset))),
                child: const Text('Lihat Detail'),
              ),
            ),
          ],
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