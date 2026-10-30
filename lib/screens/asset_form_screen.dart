// lib/screens/asset_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/asset.dart';
import '../services/firebase_service.dart';

class AssetFormScreen extends StatefulWidget {
  const AssetFormScreen({super.key});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _vendorController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _responsibleController = TextEditingController();

  DateTime? _acquisitionDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  Future<void> _generateCode() async {
    try {
      final code = await _firebaseService.generateNextCode();
      setState(() => _codeController.text = code);
    } catch (e) {
      _codeController.text = 'AST-001';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _priceController.dispose();
    _vendorController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _responsibleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _acquisitionDate = picked);
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_acquisitionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal perolehan wajib diisi'), backgroundColor: SWATheme.dangerRed),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final asset = Asset(
        id: '',
        code: _codeController.text,
        name: _nameController.text,
        category: _categoryController.text,
        brand: _brandController.text,
        model: _modelController.text,
        serialNumber: _serialNumberController.text,
        acquisitionDate: _acquisitionDate!,
        acquisitionPrice: double.parse(_priceController.text),
        vendor: _vendorController.text,
        location: _locationController.text,
        department: _departmentController.text,
        responsiblePerson: _responsibleController.text,
        status: 'Aktif',
        condition: 'Baik',
      );

      await _firebaseService.addAsset(asset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset berhasil disimpan'), backgroundColor: SWATheme.successGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: SWATheme.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SWATheme.background,
      appBar: AppBar(title: const Text('Tambah Aset')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('A. Informasi Aset'),
              const SizedBox(height: 16),
              _buildTextField(controller: _codeController, label: 'Kode Aset', hint: 'Kode otomatis', readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _nameController, label: 'Nama Aset', hint: 'Masukkan nama aset', required: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _categoryController, label: 'Kategori', hint: 'Contoh: Elektronik, Furnitur', required: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _brandController, label: 'Merek', hint: 'Masukkan merek aset'),
              const SizedBox(height: 12),
              _buildTextField(controller: _modelController, label: 'Model', hint: 'Masukkan model aset'),
              const SizedBox(height: 12),
              _buildTextField(controller: _serialNumberController, label: 'Nomor Seri', hint: 'Masukkan nomor seri'),
              const SizedBox(height: 24),
              _buildSectionHeader('B. Pengadaan dan Finansial'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Perolehan',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _acquisitionDate == null
                        ? 'Pilih tanggal'
                        : DateFormat('dd MMMM yyyy').format(_acquisitionDate!),
                    style: SWATheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _priceController,
                label: 'Harga Perolehan (Rp)',
                hint: 'Masukkan harga dalam rupiah',
                keyboardType: TextInputType.number,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(value) == null) return 'Harga harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _vendorController, label: 'Vendor/Pemasok', hint: 'Masukkan nama vendor', required: true),
              const SizedBox(height: 24),
              _buildSectionHeader('C. Penempatan dan PIC'),
              const SizedBox(height: 16),
              _buildTextField(controller: _locationController, label: 'Lokasi Fisik', hint: 'Masukkan lokasi aset', required: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _departmentController, label: 'Departemen', hint: 'Masukkan nama departemen', required: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _responsibleController, label: 'Penanggung Jawab', hint: 'Masukkan nama PIC', required: true),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAsset,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(SWATheme.surface)),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: SWATheme.headingSmall.copyWith(color: SWATheme.primaryNavy));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
      ),
      validator: validator ??
          (value) {
            if (required && (value == null || value.isEmpty)) return '$label wajib diisi';
            return null;
          },
    );
  }
}