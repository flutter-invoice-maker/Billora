import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/scan_library_item.dart';
import '../../domain/usecases/scan_library_usecases.dart';
import '../../../../core/utils/logger.dart';

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
    if (!isClosed) {
      emit(const ScanLibraryState.loading());
    }
    try {
      final items = await getScanItemsUseCase();
      if (!isClosed) {
        emit(ScanLibraryState.loaded(items));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ScanLibraryState.error(e.toString()));
      }
    }
  }

  Future<void> saveScanItem(ScanLibraryItem item) async {
    try {
      Logger.saveOperation('scan item', itemId: item.id, itemName: item.fileName);
      
      // Save the item first
      await saveScanItemUseCase(item);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, add the new item to the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = List<ScanLibraryItem>.from(currentState.items);
        updatedItems.insert(0, item); // Add new item at the beginning
        if (!isClosed) {
          emit(ScanLibraryState.loaded(updatedItems));
          emit(ScanLibraryState.itemSaved(item));
        }
      } else {
        // If no items loaded yet, just emit saved state
        if (!isClosed) {
          emit(ScanLibraryState.itemSaved(item));
        }
        // Then load all items to refresh the list
        await loadScanItems();
      }
      
      Logger.saveSuccess('scan item', itemId: item.id, itemName: item.fileName);
    } catch (e) {
      Logger.saveError('scan item', e, itemId: item.id);
      if (!isClosed) {
        emit(ScanLibraryState.error(e.toString()));
      }
    }
  }

  Future<void> updateScanItem(ScanLibraryItem item) async {
    try {
      Logger.saveOperation('update scan item', itemId: item.id, itemName: item.fileName);
      
      await updateScanItemUseCase(item);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, update the item in the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = currentState.items.map((existingItem) {
          return existingItem.id == item.id ? item : existingItem;
        }).toList();
        if (!isClosed) {
          emit(ScanLibraryState.loaded(updatedItems));
          emit(ScanLibraryState.itemUpdated(item));
        }
      } else {
        if (!isClosed) {
          emit(ScanLibraryState.itemUpdated(item));
        }
        await loadScanItems();
      }
      
      Logger.saveSuccess('update scan item', itemId: item.id, itemName: item.fileName);
    } catch (e) {
      Logger.saveError('update scan item', e, itemId: item.id);
      if (!isClosed) {
        emit(ScanLibraryState.error(e.toString()));
      }
    }
  }

  Future<void> deleteScanItem(String id) async {
    try {
      Logger.saveOperation('delete scan item', itemId: id);
      
      await deleteScanItemUseCase(id);
      
      // Get current state
      final currentState = state;
      
      // If we have loaded items, remove the item from the list
      if (currentState is ScanLibraryLoaded) {
        final updatedItems = currentState.items.where((item) => item.id != id).toList();
        if (!isClosed) {
          emit(ScanLibraryState.loaded(updatedItems));
          emit(ScanLibraryState.itemDeleted(id));
        }
      } else {
        if (!isClosed) {
          emit(ScanLibraryState.itemDeleted(id));
        }
        await loadScanItems();
      }
      
      Logger.saveSuccess('delete scan item', itemId: id);
    } catch (e) {
      Logger.saveError('delete scan item', e, itemId: id);
      if (!isClosed) {
        emit(ScanLibraryState.error(e.toString()));
      }
    }
  }

  Future<ScanLibraryItem?> getScanItemById(String id) async {
    try {
      return await getScanItemByIdUseCase(id);
    } catch (e) {
      if (!isClosed) {
        emit(ScanLibraryState.error(e.toString()));
      }
      return null;
    }
  }
} 