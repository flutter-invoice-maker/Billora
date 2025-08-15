import '../entities/scan_library_item.dart';
import '../repositories/scan_library_repository.dart';

class GetScanItemsUseCase {
  final ScanLibraryRepository repository;

  GetScanItemsUseCase(this.repository);

  Future<List<ScanLibraryItem>> call() => repository.getScanItems();
}

class SaveScanItemUseCase {
  final ScanLibraryRepository repository;

  SaveScanItemUseCase(this.repository);

  Future<void> call(ScanLibraryItem item) => repository.saveScanItem(item);
}

class UpdateScanItemUseCase {
  final ScanLibraryRepository repository;

  UpdateScanItemUseCase(this.repository);

  Future<void> call(ScanLibraryItem item) => repository.updateScanItem(item);
}

class DeleteScanItemUseCase {
  final ScanLibraryRepository repository;

  DeleteScanItemUseCase(this.repository);

  Future<void> call(String id) => repository.deleteScanItem(id);
}

class GetScanItemByIdUseCase {
  final ScanLibraryRepository repository;

  GetScanItemByIdUseCase(this.repository);

  Future<ScanLibraryItem?> call(String id) => repository.getScanItemById(id);
} 