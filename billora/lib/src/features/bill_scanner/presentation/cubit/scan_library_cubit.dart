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
      // Save the item first
      await saveScanItemUseCase(item);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, add the new item to the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = List<ScanLibraryItem>.from(currentState.items);
        updatedItems.insert(0, item); // Add new item at the beginning
        emit(ScanLibraryState.loaded(updatedItems));
        emit(ScanLibraryState.itemSaved(item));
      } else {
        // If no items loaded yet, just emit saved state
        emit(ScanLibraryState.itemSaved(item));
        // Then load all items to refresh the list
        await loadScanItems();
      }
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<void> updateScanItem(ScanLibraryItem item) async {
    try {
      await updateScanItemUseCase(item);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, update the item in the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = currentState.items.map((existingItem) {
          return existingItem.id == item.id ? item : existingItem;
        }).toList();
        emit(ScanLibraryState.loaded(updatedItems));
        emit(ScanLibraryState.itemUpdated(item));
      } else {
        emit(ScanLibraryState.itemUpdated(item));
        await loadScanItems();
      }
    } catch (e) {
      emit(ScanLibraryState.error(e.toString()));
    }
  }

  Future<void> deleteScanItem(String id) async {
    try {
      await deleteScanItemUseCase(id);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, remove the item from the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = currentState.items.where((item) => item.id != id).toList();
        emit(ScanLibraryState.loaded(updatedItems));
        emit(ScanLibraryState.itemDeleted(id));
      } else {
        emit(ScanLibraryState.itemDeleted(id));
        await loadScanItems();
      }
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