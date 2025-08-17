part of 'scan_library_cubit.dart';

@freezed
class ScanLibraryState with _$ScanLibraryState {
  const factory ScanLibraryState.initial() = ScanLibraryInitial;
  const factory ScanLibraryState.loading() = ScanLibraryLoading;
  const factory ScanLibraryState.loaded(List<ScanLibraryItem> items) = ScanLibraryLoaded;
  const factory ScanLibraryState.itemSaved(ScanLibraryItem item) = ScanLibraryItemSaved;
  const factory ScanLibraryState.itemUpdated(ScanLibraryItem item) = ScanLibraryItemUpdated;
  const factory ScanLibraryState.itemDeleted(String id) = ScanLibraryItemDeleted;
  const factory ScanLibraryState.error(String message) = ScanLibraryError;
} 