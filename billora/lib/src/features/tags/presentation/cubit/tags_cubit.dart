import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/features/tags/domain/entities/tag.dart';
import 'package:billora/src/features/tags/domain/usecases/get_all_tags_usecase.dart';
import 'package:billora/src/features/tags/domain/usecases/create_tag_usecase.dart';

part 'tags_state.dart';

@injectable
class TagsCubit extends Cubit<TagsState> {
  final GetAllTagsUseCase getAllTagsUseCase;
  final CreateTagUseCase createTagUseCase;

  TagsCubit({
    required this.getAllTagsUseCase,
    required this.createTagUseCase,
  }) : super(TagsInitial());

  Future<void> getAllTags() async {
    if (isClosed) return;
    emit(TagsLoading());
    final result = await getAllTagsUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => emit(TagsError(failure.message)),
      (tags) => emit(TagsLoaded(tags)),
    );
  }

  Future<void> createTag({required String name, required String color}) async {
    if (isClosed) return;
    final result = await createTagUseCase(name: name, color: color);
    if (isClosed) return;
    result.fold(
      (failure) => emit(TagsError(failure.message)),
      (_) => getAllTags(),
    );
  }
} 