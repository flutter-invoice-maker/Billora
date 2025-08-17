import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../domain/usecases/scan_library_usecases.dart';

part 'scan_library_state.dart';
part 'scan_library_cubit.freezed.dart';

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
  }) : super(const ScanLibraryState.initial());

  Future<void> loadScanItems() async {
    emit(const ScanLibraryState.loading());
    try {
      final items = await getScanItemsUseCase();
      emit(ScanLibraryState.loaded(items));
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<void> saveScanItem(ScanLibraryItem item) async {
    try {
      await saveScanItemUseCase(item);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryState.itemSaved(item));
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<void> updateScanItem(ScanLibraryItem item) async {
    try {
      await updateScanItemUseCase(item);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryState.itemUpdated(item));
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<void> deleteScanItem(String id) async {
    try {
      await deleteScanItemUseCase(id);
      await loadScanItems(); // Reload to get updated list
      emit(ScanLibraryState.itemDeleted(id));
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<ScanLibraryItem?> getScanItemById(String id) async {
    try {
      return await getScanItemByIdUseCase(id);
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
      return null;
    }
  }
} 