// lib/models/asset.dart
class Asset {
  final String id;
  final String code;
  final String name;
  final String category;
  final String brand;
  final String model;
  final String serialNumber;
  final DateTime acquisitionDate;
  final double acquisitionPrice;
  final String vendor;
  final String location;
  final String department;
  final String responsiblePerson;
  final String status;
  final String condition;
  final String? specifications;

  Asset({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.acquisitionDate,
    required this.acquisitionPrice,
    required this.vendor,
    required this.location,
    required this.department,
    required this.responsiblePerson,
    this.status = 'Aktif',
    this.condition = 'Baik',
    this.specifications,
  });
}