import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/tags/domain/entities/tag.dart';

abstract class TagsRepository {
  ResultFuture<List<Tag>> getAllTags();
  
  ResultFuture<Tag> createTag({
    required String name,
    required String color,
  });
  
  ResultFuture<void> updateTag(Tag tag);
  
  ResultFuture<void> deleteTag(String tagId);
  
  ResultFuture<List<Tag>> searchTags(String query);
  
  ResultFuture<void> incrementTagUsage(String tagId);
  
  ResultFuture<List<Tag>> getMostUsedTags({int limit = 10});
  
  ResultFuture<void> syncTags();
} 