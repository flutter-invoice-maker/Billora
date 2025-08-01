import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/tags/domain/entities/tag.dart';
import 'package:billora/src/features/tags/domain/repositories/tags_repository.dart';

@injectable
class GetAllTagsUseCase {
  final TagsRepository repository;

  GetAllTagsUseCase(this.repository);

  ResultFuture<List<Tag>> call() async {
    return await repository.getAllTags();
  }
} 