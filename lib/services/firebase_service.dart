// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/asset.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isInitialized = false;

  /// Aman dipanggil kapan pun, bahkan sebelum initialize().
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    // Matikan cache offline -> aplikasi hanya bekerja saat online
    _firestore!.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'Firebase belum diinisialisasi pada platform ini. '
        'Gunakan perangkat/emulator Android untuk mengakses Firebase.',
      );
    }
  }

  // ==================== AUTH ====================

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    _ensureInitialized();
    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    _ensureInitialized();
    await _auth!.signOut();
  }

  User? get currentUser {
    if (!_isInitialized) return null;
    return _auth!.currentUser;
  }

  bool get isAuthenticated {
    if (!_isInitialized) return false;
    return _auth!.currentUser != null;
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Kata sandi salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'invalid-credential':
        return 'Email atau kata sandi salah';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }

  // ==================== ASSETS ====================

  Future<List<Asset>> getAssets() async {
    _ensureInitialized();
    try {
      final snapshot = await _firestore!.collection('assets').orderBy('code').get();
      return snapshot.docs.map(_mapDocToAsset).toList();
    } catch (e) {
      throw Exception('Gagal memuat data aset: $e');
    }
  }

  Future<Asset?> getAssetById(String id) async {
    _ensureInitialized();
    try {
      final doc = await _firestore!.collection('assets').doc(id).get();
      return doc.exists ? _mapDocToAsset(doc) : null;
    } catch (e) {
      throw Exception('Gagal memuat detail aset: $e');
    }
  }

  Future<String> addAsset(Asset asset) async {
    _ensureInitialized();
    try {
      final docRef = await _firestore!.collection('assets').add({
        'code': asset.code,
        'name': asset.name,
        'category': asset.category,
        'brand': asset.brand,
        'model': asset.model,
        'serialNumber': asset.serialNumber,
        'acquisitionDate': Timestamp.fromDate(asset.acquisitionDate),
        'acquisitionPrice': asset.acquisitionPrice,
        'vendor': asset.vendor,
        'location': asset.location,
        'department': asset.department,
        'responsiblePerson': asset.responsiblePerson,
        'status': asset.status,
        'condition': asset.condition,
        'specifications': asset.specifications,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth!.currentUser?.email ?? 'unknown',
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menyimpan aset: $e');
    }
  }

  Future<void> updateAsset(String id, Map<String, dynamic> updates) async {
    _ensureInitialized();
    try {
      await _firestore!.collection('assets').doc(id).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth!.currentUser?.email ?? 'unknown',
      });
    } catch (e) {
      throw Exception('Gagal memperbarui aset: $e');
    }
  }

  Future<void> deleteAsset(String id) async {
    _ensureInitialized();
    try {
      await _firestore!.collection('assets').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus aset: $e');
    }
  }

  Future<String> generateNextCode() async {
    _ensureInitialized();
    try {
      final snapshot = await _firestore!
          .collection('assets')
          .orderBy('code', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 'AST-001';

      final lastCode = snapshot.docs.first['code'] as String;
      final number = int.tryParse(lastCode.split('-').last) ?? 0;
      return 'AST-${(number + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      return 'AST-001';
    }
  }

  Asset _mapDocToAsset(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Asset(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      acquisitionDate: (data['acquisitionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acquisitionPrice: (data['acquisitionPrice'] as num?)?.toDouble() ?? 0,
      vendor: data['vendor'] ?? '',
      location: data['location'] ?? '',
      department: data['department'] ?? '',
      responsiblePerson: data['responsiblePerson'] ?? '',
      status: data['status'] ?? 'Aktif',
      condition: data['condition'] ?? 'Baik',
      specifications: data['specifications'],
    );
  }
}