import 'package:injectable/injectable.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/tags/domain/entities/tag.dart';
import 'package:billora/src/features/tags/domain/repositories/tags_repository.dart';

@injectable
class CreateTagUseCase {
  final TagsRepository repository;

  CreateTagUseCase(this.repository);

  ResultFuture<Tag> call({
    required String name,
    required String color,
  }) => repository.createTag(name: name, color: color);
} 