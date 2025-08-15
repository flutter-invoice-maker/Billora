import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../domain/repositories/scan_library_repository.dart';

class ScanLibraryRepositoryImpl implements ScanLibraryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ScanLibraryRepositoryImpl(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_userId).collection('scan_library');

  @override
  Future<List<ScanLibraryItem>> getScanItems() async {
    try {
      final querySnapshot = await _collection
          .orderBy('lastModifiedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanLibraryItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to load scan items: $e');
    }
  }

  @override
  Future<void> saveScanItem(ScanLibraryItem item) async {
    try {
      await _collection.doc(item.id).set(item.toJson());
    } catch (e) {
      throw Exception('Failed to save scan item: $e');
    }
  }

  @override
  Future<void> updateScanItem(ScanLibraryItem item) async {
    try {
      await _collection.doc(item.id).update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update scan item: $e');
    }
  }

  @override
  Future<void> deleteScanItem(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete scan item: $e');
    }
  }

  @override
  Future<ScanLibraryItem?> getScanItemById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return ScanLibraryItem.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get scan item: $e');
    }
  }
} 