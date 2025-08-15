part of 'scan_library_cubit.dart';

abstract class ScanLibraryState extends Equatable {
  const ScanLibraryState();

  @override
  List<Object> get props => [];
}

class ScanLibraryInitial extends ScanLibraryState {}

class ScanLibraryLoading extends ScanLibraryState {}

class ScanLibraryLoaded extends ScanLibraryState {
  final List<ScanLibraryItem> items;

  const ScanLibraryLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ScanLibraryItemSaved extends ScanLibraryState {
  final ScanLibraryItem item;

  const ScanLibraryItemSaved(this.item);

  @override
  List<Object> get props => [item];
}

class ScanLibraryItemUpdated extends ScanLibraryState {
  final ScanLibraryItem item;

  const ScanLibraryItemUpdated(this.item);

  @override
  List<Object> get props => [item];
}

class ScanLibraryItemDeleted extends ScanLibraryState {
  final String id;

  const ScanLibraryItemDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class ScanLibraryError extends ScanLibraryState {
  final String message;

  const ScanLibraryError(this.message);

  @override
  List<Object> get props => [message];
} 