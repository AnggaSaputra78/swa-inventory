// lib/services/asset_service.dart
import '../models/asset.dart';

class AssetService {
  final List<Asset> _assets = [];
  int _nextId = 1;

  void initializeDemoData() {
    if (_assets.isNotEmpty) return;

    _addDemoAsset(
      code: 'AST-001',
      name: 'Laptop Dell Latitude 5420',
      category: 'Elektronik',
      brand: 'Dell',
      model: 'Latitude 5420',
      serialNumber: 'DL5420-2024-001',
      acquisitionDate: DateTime(2024, 1, 15),
      acquisitionPrice: 15000000,
      vendor: 'PT Dell Indonesia',
      location: 'Kantor Pusat - Lantai 3',
      department: 'IT',
      responsiblePerson: 'Budi Santoso',
      status: 'Aktif',
      condition: 'Baik',
      specifications: 'Intel Core i5, RAM 8GB, SSD 256GB',
    );

    _addDemoAsset(
      code: 'AST-002',
      name: 'Printer HP LaserJet Pro',
      category: 'Elektronik',
      brand: 'HP',
      model: 'LaserJet Pro M404dn',
      serialNumber: 'HP-M404-2024-002',
      acquisitionDate: DateTime(2024, 2, 20),
      acquisitionPrice: 4500000,
      vendor: 'PT HP Indonesia',
      location: 'Kantor Pusat - Lantai 2',
      department: 'Administrasi',
      responsiblePerson: 'Siti Rahayu',
      status: 'Aktif',
      condition: 'Baik',
    );

    _addDemoAsset(
      code: 'AST-003',
      name: 'Meja Kerja Eksekutif',
      category: 'Furnitur',
      brand: 'Olympic',
      model: 'Executive Desk',
      serialNumber: 'OLY-ED-2024-003',
      acquisitionDate: DateTime(2024, 3, 10),
      acquisitionPrice: 3500000,
      vendor: 'PT Olympic Furniture',
      location: 'Kantor Pusat - Lantai 4',
      department: 'Direksi',
      responsiblePerson: 'Ahmad Wijaya',
      status: 'Aktif',
      condition: 'Baik',
    );

    _addDemoAsset(
      code: 'AST-004',
      name: 'Proyektor Epson EB-X51',
      category: 'Elektronik',
      brand: 'Epson',
      model: 'EB-X51',
      serialNumber: 'EPS-X51-2024-004',
      acquisitionDate: DateTime(2024, 1, 5),
      acquisitionPrice: 8500000,
      vendor: 'PT Epson Indonesia',
      location: 'Ruang Meeting Utama',
      department: 'Umum',
      responsiblePerson: 'Dewi Lestari',
      status: 'Dipinjam',
      condition: 'Baik',
    );

    _addDemoAsset(
      code: 'AST-005',
      name: 'AC Daikin 2 PK',
      category: 'Elektronik',
      brand: 'Daikin',
      model: 'FTKC50RV414',
      serialNumber: 'DK-2PK-2024-005',
      acquisitionDate: DateTime(2023, 11, 15),
      acquisitionPrice: 12000000,
      vendor: 'PT Daikin Indonesia',
      location: 'Kantor Pusat - Lantai 3',
      department: 'IT',
      responsiblePerson: 'Budi Santoso',
      status: 'Perawatan',
      condition: 'Perlu Perawatan',
    );
  }

  void _addDemoAsset({
    required String code,
    required String name,
    required String category,
    required String brand,
    required String model,
    required String serialNumber,
    required DateTime acquisitionDate,
    required double acquisitionPrice,
    required String vendor,
    required String location,
    required String department,
    required String responsiblePerson,
    required String status,
    required String condition,
    String? specifications,
  }) {
    _assets.add(Asset(
      id: (_nextId++).toString(),
      code: code,
      name: name,
      category: category,
      brand: brand,
      model: model,
      serialNumber: serialNumber,
      acquisitionDate: acquisitionDate,
      acquisitionPrice: acquisitionPrice,
      vendor: vendor,
      location: location,
      department: department,
      responsiblePerson: responsiblePerson,
      status: status,
      condition: condition,
      specifications: specifications,
    ));
  }

  List<Asset> getAllAssets() {
    return List.from(_assets);
  }

  Asset? getAssetById(String id) {
    try {
      return _assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  void addAsset(Asset asset) {
    _assets.add(asset);
  }

  String generateNextCode() {
    final nextNumber = _nextId.toString().padLeft(3, '0');
    return 'AST-$nextNumber';
  }
}