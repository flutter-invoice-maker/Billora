import '../entities/scan_library_item.dart';

abstract class ScanLibraryRepository {
  Future<List<ScanLibraryItem>> getScanItems();
  Future<void> saveScanItem(ScanLibraryItem item);
  Future<void> updateScanItem(ScanLibraryItem item);
  Future<void> deleteScanItem(String id);
  Future<ScanLibraryItem?> getScanItemById(String id);
} 