import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../domain/usecases/scan_library_usecases.dart';

part 'scan_library_state.dart';

class ScanLibraryCubit extends Cubit<ScanLibraryState> {
  final GetScanItemsUseCase getScanItemsUseCase;
  final SaveScanItemUseCase saveScanItemUseCase;
  final UpdateScanItemUseCase updateScanItemUseCase;
  final DeleteScanItemUseCase deleteScanItemUseCase;
  final GetScanItemByIdUseCase getScanItemByIdUseCase;

  ScanLibraryCubit({
    required this.getScanItemsUseCase,
    required this.saveScanItemUseCase,
    required this.updateScanItemUseCase,
    required this.deleteScanItemUseCase,
    required this.getScanItemByIdUseCase,
  }) : super(ScanLibraryInitial());

  Future<void> loadScanItems() async {
    emit(ScanLibraryLoading());
    try {
      final items = await getScanItemsUseCase();
      emit(ScanLibraryLoaded(items));
    } catch (e) {
      emit(ScanLibraryError(e.toString()));
    }
  }

  Future<void> saveScanItem(ScanLibraryItem item) async {
    try {
      await saveScanItemUseCase(item);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryItemSaved(item));
    } catch (e) {
      emit(ScanLibraryError(e.toString()));
    }
  }

  Future<void> updateScanItem(ScanLibraryItem item) async {
    try {
      await updateScanItemUseCase(item);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryItemUpdated(item));
    } catch (e) {
      emit(ScanLibraryError(e.toString()));
    }
  }

  Future<void> deleteScanItem(String id) async {
    try {
      await deleteScanItemUseCase(id);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryItemDeleted(id));
    } catch (e) {
      emit(ScanLibraryError(e.toString()));
    }
  }

  Future<ScanLibraryItem?> getScanItemById(String id) async {
    try {
      return await getScanItemByIdUseCase(id);
    } catch (e) {
      emit(ScanLibraryError(e.toString()));
      return null;
    }
  }
} 