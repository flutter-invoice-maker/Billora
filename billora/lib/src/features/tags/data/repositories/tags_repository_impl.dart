import 'package:dartz/dartz.dart';
import 'package:billora/src/core/errors/failures.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/tags/domain/entities/tag.dart';
import 'package:billora/src/features/tags/domain/repositories/tags_repository.dart';
import 'package:billora/src/features/tags/data/datasources/tags_remote_datasource.dart';
import 'package:billora/src/features/tags/data/models/tag_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TagsRepository)
class TagsRepositoryImpl implements TagsRepository {
  final TagsRemoteDataSource remoteDataSource;

  TagsRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<Tag>> getAllTags() async {
    try {
      final tags = await remoteDataSource.getAllTags();
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Tag> createTag({
    required String name,
    required String color,
  }) async {
    try {
      final tag = await remoteDataSource.createTag(
        name: name,
        color: color,
      );
      return Right(tag);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateTag(Tag tag) async {
    try {
      await remoteDataSource.updateTag(tag as TagModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTag(String tagId) async {
    try {
      await remoteDataSource.deleteTag(tagId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Tag>> searchTags(String query) async {
    try {
      final tags = await remoteDataSource.searchTags(query);
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> incrementTagUsage(String tagId) async {
    try {
      await remoteDataSource.incrementTagUsage(tagId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Tag>> getMostUsedTags({int limit = 10}) async {
    try {
      final tags = await remoteDataSource.getMostUsedTags(limit: limit);
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> syncTags() async {
    try {
      await remoteDataSource.syncTags();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 